import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';
import '../theme/app_theme.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  List<Trip> _trips = [];
  bool _loading = true;

  static final _dateFmt = DateFormat('d. M. yyyy', 'cs');

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);
    final trips = await TripService.instance.getAllTrips();
    if (mounted) setState(() {
      _trips = trips;
      _loading = false;
    });
  }

  Future<void> _deleteTrip(Trip trip) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTrip),
        content: Text(l10n.deleteTripConfirm(trip.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await TripService.instance.deleteTrip(trip.id);
      await _loadTrips();
    }
  }

  Color _statusColor(TripStatus status) => switch (status) {
        TripStatus.planning  => AppColors.subtitleGray,
        TripStatus.packing   => const Color(0xFF1565C0),
        TripStatus.onTrip    => AppColors.success,
        TripStatus.completed => AppColors.subtitleGray,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).tripsTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push('/trips/add').then((_) => _loadTrips()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadTrips,
              child: _trips.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: _trips.length,
                      itemBuilder: (_, i) => _buildTripCard(_trips[i]),
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🌍',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTrips,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noTripsHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  context.push('/trips/add').then((_) => _loadTrips()),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addTrip),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(trip.status);

    return Dismissible(
      key: ValueKey(trip.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      confirmDismiss: (_) async {
        await _deleteTrip(trip);
        return false; // We handle deletion manually
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () =>
                context.push('/trips/${trip.id}').then((_) => _loadTrips()),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
                  width: 0.5,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trip.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: statusColor.withAlpha(77), width: 0.5),
                        ),
                        child: Text(
                          '${trip.status.emoji} ${trip.status.label}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (trip.destination != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trip.destination!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (trip.departureDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trip.returnDate != null
                              ? '${_dateFmt.format(trip.departureDate!)} – ${_dateFmt.format(trip.returnDate!)}'
                              : _dateFmt.format(trip.departureDate!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (trip.totalCount > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).packingProgress(trip.packedCount, trip.totalCount),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '${(trip.packedCount / trip.totalCount * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: trip.totalCount > 0
                                      ? trip.packedCount /
                                          trip.totalCount
                                      : 0,
                                  backgroundColor: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.cardBorder,
                                  valueColor:
                                      const AlwaysStoppedAnimation(
                                    AppColors.primary,
                                  ),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
