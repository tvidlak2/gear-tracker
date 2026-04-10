import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/gear_item.dart';
import '../models/usage_log.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final _db = DatabaseHelper.instance;

  List<_ActivityEntry> _entries = [];
  bool _loading = true;

  static final _dateFmt = DateFormat('d. M. yyyy');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final logs = await _db.getUsageLogs();
    final gearItems = await _db.getGearItems();
    final gearMap = {for (final g in gearItems) g.id!: g};

    final entries = logs
        .map((l) => _ActivityEntry(log: l, gear: gearMap[l.gearItemId]))
        .toList();
    entries.sort((a, b) => b.log.date.compareTo(a.log.date));

    if (mounted) setState(() { _entries = entries; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aktivity')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(child: Text('Zatím žádné aktivity.'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                    itemCount: _entries.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final e = _entries[i];
                      final l = e.log;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 4),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondaryContainer,
                          child: Icon(
                            Icons.directions_run,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                        title: Text(
                          e.gear?.name ?? 'Neznámé vybavení',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text([
                          if (l.durationMinutes != null)
                            '${(l.durationMinutes! / 60).toStringAsFixed(1)} h',
                          if (l.distanceKm != null)
                            '${l.distanceKm!.toStringAsFixed(1)} km',
                          if (l.location != null) l.location!,
                        ].join(' · ')),
                        trailing: Text(
                          _dateFmt.format(l.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _ActivityEntry {
  final UsageLog log;
  final GearItem? gear;
  const _ActivityEntry({required this.log, required this.gear});
}
