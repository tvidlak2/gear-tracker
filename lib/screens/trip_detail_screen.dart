import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/gear_item.dart';
import '../models/trip.dart';
import '../services/maintenance_service.dart';
import '../services/trip_service.dart';
import '../theme/app_theme.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  Trip? _trip;
  bool _loading = true;

  // gear items for this trip (full GearItem objects)
  List<GearItem> _gearItems = [];
  // maintenance status per gear item id
  Map<int, MaintenanceStatus> _maintenanceStatus = {};

  static final _dateFmt = DateFormat('d. M. yyyy', 'cs');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final trip = await TripService.instance.getTripById(widget.tripId);
      if (trip == null) {
        if (mounted) context.pop();
        return;
      }

      // Load full gear item details
      final db = DatabaseHelper.instance;
      final svc = MaintenanceService();
      final gearItems = <GearItem>[];
      final statusMap = <int, MaintenanceStatus>{};

      for (final tgi in trip.gearItems) {
        final intId = int.tryParse(tgi.gearItemId);
        if (intId == null) continue;
        final gi = await db.getGearItemById(intId);
        if (gi == null) continue;
        gearItems.add(gi);
        final status = await svc.getWorstStatusForItem(intId);
        statusMap[intId] = status;
      }

      if (mounted) {
        setState(() {
          _trip = trip;
          _gearItems = gearItems;
          _maintenanceStatus = statusMap;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _togglePacked(String gearItemId, bool isPacked) async {
    await TripService.instance.updateGearPackedState(
      widget.tripId,
      gearItemId,
      isPacked,
    );
    await _loadData();
  }

  Future<void> _addGearItems() async {
    if (_trip == null) return;

    // Load all active gear items
    final allGear = await DatabaseHelper.instance
        .getGearItems(status: GearStatus.active);

    // Currently selected gear item IDs
    final selectedIds =
        _trip!.gearItems.map((g) => g.gearItemId).toSet();

    if (!mounted) return;

    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GearSelectSheet(
        allGear: allGear,
        selectedIds: Set<String>.from(selectedIds),
      ),
    );

    if (result == null || !mounted) return;

    // Build updated gear items list
    final existingMap = {
      for (final g in _trip!.gearItems) g.gearItemId: g
    };

    final newGearItems = result.map((id) {
      return existingMap[id] ?? TripGearItem(gearItemId: id);
    }).toList();

    final updatedTrip = _trip!.copyWith(gearItems: newGearItems);
    await TripService.instance.saveTrip(updatedTrip);
    await _loadData();
  }

  void _shareChecklist() {
    if (_trip == null) return;
    final trip = _trip!;

    final buf = StringBuffer();
    buf.writeln('📋 ${trip.name}');
    if (trip.destination != null) buf.write(' – ${trip.destination}');
    buf.writeln();

    if (trip.departureDate != null) {
      buf.write('📅 ${_dateFmt.format(trip.departureDate!)}');
      if (trip.returnDate != null) {
        buf.write(' – ${_dateFmt.format(trip.returnDate!)}');
      }
      buf.writeln();
    }

    buf.writeln();
    buf.writeln('Gear:');

    for (final gi in _gearItems) {
      final tgi = trip.gearItems.firstWhere(
        (t) => t.gearItemId == gi.id?.toString(),
        orElse: () => TripGearItem(gearItemId: ''),
      );
      final status = gi.id != null
          ? (_maintenanceStatus[gi.id!] ?? MaintenanceStatus.ok)
          : MaintenanceStatus.ok;

      if (status == MaintenanceStatus.overdue) {
        buf.writeln('⚠️ ${gi.name} – vyžaduje servis');
      } else if (tgi.isPacked) {
        buf.writeln('✅ ${gi.name} (zabaleno)');
      } else {
        buf.writeln('⬜ ${gi.name}');
      }
    }

    buf.writeln();
    buf.writeln('Vytvořeno v OutdoorGearTracker');

    Share.share(buf.toString());
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
    if (_loading) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : const Color(0xFFF6F6F6),
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final trip = _trip!;
    final overdueGear = _gearItems
        .where((gi) =>
            gi.id != null &&
            _maintenanceStatus[gi.id!] == MaintenanceStatus.overdue)
        .toList();
    final warningGear = _gearItems
        .where((gi) =>
            gi.id != null &&
            _maintenanceStatus[gi.id!] == MaintenanceStatus.warning)
        .toList();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(
          trip.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context
                .push('/trips/${trip.id}/edit', extra: trip)
                .then((_) => _loadData()),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareChecklist,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            // Header card
            _buildHeaderCard(trip, isDark),
            const SizedBox(height: 12),

            // Maintenance warnings
            if (overdueGear.isNotEmpty || warningGear.isNotEmpty) ...[
              _buildWarningsSection(overdueGear, warningGear, isDark),
              const SizedBox(height: 12),
            ],

            // Gear checklist
            _buildGearSection(trip, isDark),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: _shareChecklist,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.share_outlined),
            label: Text(
              AppLocalizations.of(context).shareChecklist,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Trip trip, bool isDark) {
    final statusColor = _statusColor(trip.status);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: statusColor.withAlpha(77), width: 0.5),
                ),
                child: Text(
                  '${trip.status.emoji} ${trip.status.label}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (trip.destination != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.subtitleGray),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    trip.destination!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
          if (trip.departureDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.subtitleGray),
                const SizedBox(width: 6),
                Text(
                  trip.returnDate != null
                      ? '${_dateFmt.format(trip.departureDate!)} – ${_dateFmt.format(trip.returnDate!)}'
                      : _dateFmt.format(trip.departureDate!),
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (trip.notes != null && trip.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text(
              trip.notes!,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarningsSection(
    List<GearItem> overdueGear,
    List<GearItem> warningGear,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            AppLocalizations.of(context).tripWarnings,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        ...overdueGear.map(
          (gi) => _buildWarningCard(
            gi.name,
            AppLocalizations.of(context).tripGearOverdue,
            AppColors.danger,
            isDark ? AppColors.dangerBgDark : const Color(0xFFFCEBEB),
            isDark,
          ),
        ),
        ...warningGear.map(
          (gi) => _buildWarningCard(
            gi.name,
            AppLocalizations.of(context).tripGearWarning,
            AppColors.warning,
            isDark ? AppColors.warningBgDark : const Color(0xFFFAEEDA),
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningCard(
    String name,
    String message,
    Color accentColor,
    Color bgColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: accentColor),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                          Text(
                            message,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGearSection(Trip trip, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).gearChecklist(trip.packedCount, trip.totalCount),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addGearItems,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(AppLocalizations.of(context).add),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary),
                ),
              ],
            ),
          ),
          if (trip.gearItems.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                AppLocalizations.of(context).noGearInTrip,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...trip.gearItems.map((tgi) {
              final intId = int.tryParse(tgi.gearItemId);
              final gi = intId != null
                  ? _gearItems
                      .where((g) => g.id == intId)
                      .firstOrNull
                  : null;

              if (gi == null) return const SizedBox.shrink();

              final mStatus = intId != null
                  ? (_maintenanceStatus[intId] ?? MaintenanceStatus.ok)
                  : MaintenanceStatus.ok;
              final dotColor = switch (mStatus) {
                MaintenanceStatus.ok      => AppColors.success,
                MaintenanceStatus.warning => AppColors.warning,
                MaintenanceStatus.overdue => AppColors.danger,
              };

              return Column(
                children: [
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  CheckboxListTile(
                    value: tgi.isPacked,
                    onChanged: (v) => _togglePacked(
                      tgi.gearItemId,
                      v ?? false,
                    ),
                    activeColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 2),
                    title: Text(
                      gi.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: tgi.isPacked
                            ? TextDecoration.lineThrough
                            : null,
                        color: tgi.isPacked
                            ? Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                            : null,
                      ),
                    ),
                    secondary: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

// ── Gear select bottom sheet ──────────────────────────────────────────────────

class _GearSelectSheet extends StatefulWidget {
  final List<GearItem> allGear;
  final Set<String> selectedIds;

  const _GearSelectSheet({
    required this.allGear,
    required this.selectedIds,
  });

  @override
  State<_GearSelectSheet> createState() => _GearSelectSheetState();
}

class _GearSelectSheetState extends State<_GearSelectSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              AppLocalizations.of(context).selectGearTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: widget.allGear.length,
              itemBuilder: (_, i) {
                final gear = widget.allGear[i];
                final id = gear.id?.toString() ?? '';
                final selected = _selected.contains(id);
                return CheckboxListTile(
                  value: selected,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selected.add(id);
                    } else {
                      _selected.remove(id);
                    }
                  }),
                  activeColor: AppColors.primary,
                  title: Text(gear.name,
                      style: const TextStyle(fontSize: 14)),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _selected),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppLocalizations.of(context).confirmSelection),
            ),
          ),
        ],
      ),
    );
  }
}
