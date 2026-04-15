import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/gear_item.dart';
import '../models/maintenance_rule.dart';
import '../models/maintenance_log.dart';
import '../models/usage_log.dart';
import '../services/igc_parser.dart';
import '../services/gpx_parser.dart';
import '../services/maintenance_service.dart';
import '../theme/app_theme.dart';
import '../widgets/maintenance_badge.dart';
import '../widgets/photo_picker.dart';

/// Globální přehled všeho vybavení, které potřebuje servis.
class MaintenanceOverviewScreen extends StatefulWidget {
  const MaintenanceOverviewScreen({super.key});

  @override
  State<MaintenanceOverviewScreen> createState() =>
      _MaintenanceOverviewScreenState();
}

class _MaintenanceOverviewScreenState
    extends State<MaintenanceOverviewScreen> {
  final _db = DatabaseHelper.instance;
  final _maintenanceService = MaintenanceService();

  List<_ItemWithStatus> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final gearItems = await _db.getGearItems(status: GearStatus.active);
    final result = <_ItemWithStatus>[];

    for (final item in gearItems) {
      final results =
          await _maintenanceService.getStatusForItem(item.id!);
      final hasIssue = results.any(
        (r) =>
            r.status == MaintenanceStatus.overdue ||
            r.status == MaintenanceStatus.warning,
      );
      if (hasIssue) {
        result.add(_ItemWithStatus(item: item, results: results));
      }
    }

    result.sort((a, b) {
      final aHasOverdue =
          a.results.any((r) => r.status == MaintenanceStatus.overdue);
      final bHasOverdue =
          b.results.any((r) => r.status == MaintenanceStatus.overdue);
      if (aHasOverdue != bHasOverdue) return aHasOverdue ? -1 : 1;
      return a.item.name.compareTo(b.item.name);
    });

    if (mounted) {
      setState(() {
        _items = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.maintenanceOverview)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 80,
                          color: Colors.green.shade300),
                      const SizedBox(height: 16),
                      Text(
                        l10n.allGoodTitle,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.allGoodSubtitle),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    itemBuilder: (_, i) => _ItemCard(
                      data: _items[i],
                      onTap: () =>
                          context.push('/gear/${_items[i].item.id}').then((_) => _loadData()),
                      onLogMaintenance: (item, ruleId) =>
                          _openLogScreen(item, ruleId),
                    ),
                  ),
                ),
    );
  }

  Future<void> _openLogScreen(GearItem item, int ruleId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddMaintenanceLogScreen(
          gearItemId: item.id!,
          initialRuleId: ruleId,
        ),
      ),
    );
    _loadData();
  }
}

class _ItemWithStatus {
  final GearItem item;
  final List<MaintenanceStatusResult> results;

  const _ItemWithStatus({required this.item, required this.results});
}

class _ItemCard extends StatelessWidget {
  final _ItemWithStatus data;
  final VoidCallback onTap;
  final void Function(GearItem item, int ruleId) onLogMaintenance;

  const _ItemCard({
    required this.data,
    required this.onTap,
    required this.onLogMaintenance,
  });

  @override
  Widget build(BuildContext context) {
    final hasOverdue =
        data.results.any((r) => r.status == MaintenanceStatus.overdue);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    hasOverdue ? Icons.warning : Icons.info_outline,
                    color: hasOverdue ? Colors.red : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.item.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 8),
              ...data.results
                  .where((r) => r.status != MaintenanceStatus.ok)
                  .map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          MaintenanceBadge(
                              status: r.status, compact: true),
                          const SizedBox(width: 8),
                          Expanded(child: Text(r.rule.name)),
                          if (r.rule.id != null)
                            TextButton(
                              onPressed: () =>
                                  onLogMaintenance(data.item, r.rule.id!),
                              child: const Text('Zapsat servis'),
                            ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────── ADD MAINTENANCE LOG SCREEN ─────────────────────────

class AddMaintenanceLogScreen extends StatefulWidget {
  final int gearItemId;
  final int? initialRuleId;

  const AddMaintenanceLogScreen({
    super.key,
    required this.gearItemId,
    this.initialRuleId,
  });

  @override
  State<AddMaintenanceLogScreen> createState() =>
      _AddMaintenanceLogScreenState();
}

class _AddMaintenanceLogScreenState extends State<AddMaintenanceLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper.instance;
  final _maintenanceService = MaintenanceService();

  final _performedByCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  List<MaintenanceRule> _rules = [];
  int? _selectedRuleId;
  DateTime _performedDate = DateTime.now();
  bool _loading = false;
  String? _photoPath;

  static final _dateFormat = DateFormat('d. M. yyyy');

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    final rules = await _db.getRulesForItem(widget.gearItemId);
    if (mounted) {
      setState(() {
        _rules = rules;
        if (_selectedRuleId == null && widget.initialRuleId != null) {
          _selectedRuleId = widget.initialRuleId;
        }
      });
    }
  }

  @override
  void dispose() {
    _performedByCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    await _maintenanceService.logMaintenance(
      gearItemId: widget.gearItemId,
      ruleId: _selectedRuleId,
      performedDate: _performedDate,
      performedBy: _performedByCtrl.text.trim().isEmpty
          ? null
          : _performedByCtrl.text.trim(),
      cost: _costCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_costCtrl.text.trim()),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      photoPath: _photoPath,
    );

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.logService),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_rules.isNotEmpty)
              DropdownButtonFormField<int?>(
                value: _selectedRuleId,
                decoration: const InputDecoration(
                  labelText: 'Pravidlo (volitelné)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('–')),
                  ..._rules.map(
                    (r) => DropdownMenuItem(value: r.id, child: Text(r.name)),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedRuleId = v),
              ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _performedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _performedDate = picked);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.performedDate,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today, size: 18),
                ),
                child: Text(_dateFormat.format(_performedDate)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _performedByCtrl,
              decoration: InputDecoration(
                labelText: l10n.performedBy,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '${l10n.cost} (Kč)',
                border: const OutlineInputBorder(),
                suffixText: 'Kč',
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                  return 'Zadej číslo';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.notes,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Foto dokladu / štítku',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            PhotoPicker(
              photoPath: _photoPath,
              onChanged: (path) => setState(() => _photoPath = path),
              height: 160,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────── EDIT MAINTENANCE LOG SCREEN ────────────────────────

class EditMaintenanceLogScreen extends StatefulWidget {
  final MaintenanceLog log;

  const EditMaintenanceLogScreen({super.key, required this.log});

  @override
  State<EditMaintenanceLogScreen> createState() =>
      _EditMaintenanceLogScreenState();
}

class _EditMaintenanceLogScreenState extends State<EditMaintenanceLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper.instance;

  final _performedByCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  List<MaintenanceRule> _rules = [];
  int? _selectedRuleId;
  DateTime _performedDate = DateTime.now();
  bool _loading = false;
  String? _photoPath;

  static final _dateFormat = DateFormat('d. M. yyyy');

  @override
  void initState() {
    super.initState();
    final log = widget.log;
    _performedDate  = log.performedDate;
    _selectedRuleId = log.ruleId;
    _photoPath      = log.photoPath;
    _performedByCtrl.text = log.performedBy ?? '';
    _costCtrl.text        = log.cost != null ? log.cost!.toStringAsFixed(0) : '';
    _notesCtrl.text       = log.notes ?? '';
    _loadRules();
  }

  Future<void> _loadRules() async {
    final rules = await _db.getRulesForItem(widget.log.gearItemId);
    if (mounted) setState(() => _rules = rules);
  }

  @override
  void dispose() {
    _performedByCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final updated = MaintenanceLog(
      id:            widget.log.id,
      gearItemId:    widget.log.gearItemId,
      ruleId:        _selectedRuleId,
      performedDate: _performedDate,
      performedBy:   _performedByCtrl.text.trim().isEmpty
                         ? null : _performedByCtrl.text.trim(),
      cost:          _costCtrl.text.trim().isEmpty
                         ? null : double.tryParse(_costCtrl.text.trim()),
      notes:         _notesCtrl.text.trim().isEmpty
                         ? null : _notesCtrl.text.trim(),
      nextDueDate:   widget.log.nextDueDate,
      photoPath:     _photoPath,
    );

    await _db.updateMaintenanceLog(updated);
    if (mounted) Navigator.of(context).pop(true); // true = saved
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upravit záznam servisu'),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Uložit'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_rules.isNotEmpty)
              DropdownButtonFormField<int?>(
                value: _selectedRuleId,
                decoration: const InputDecoration(
                  labelText: 'Pravidlo (volitelné)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('–')),
                  ..._rules.map(
                    (r) => DropdownMenuItem(value: r.id, child: Text(r.name)),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedRuleId = v),
              ),
            if (_rules.isNotEmpty) const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _performedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _performedDate = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Datum provedení',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                ),
                child: Text(_dateFormat.format(_performedDate)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _performedByCtrl,
              decoration: const InputDecoration(
                labelText: 'Kdo provedl',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cena (Kč)',
                border: OutlineInputBorder(),
                suffixText: 'Kč',
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                  return 'Zadej číslo';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Poznámky',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Foto dokladu / štítku',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            PhotoPicker(
              photoPath: _photoPath,
              onChanged: (path) => setState(() => _photoPath = path),
              height: 160,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────── ADD MAINTENANCE RULE SCREEN ────────────────────────

class AddMaintenanceRuleScreen extends StatefulWidget {
  final int gearItemId;

  const AddMaintenanceRuleScreen({super.key, required this.gearItemId});

  @override
  State<AddMaintenanceRuleScreen> createState() =>
      _AddMaintenanceRuleScreenState();
}

class _AddMaintenanceRuleScreenState
    extends State<AddMaintenanceRuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper.instance;

  final _nameCtrl = TextEditingController();
  final _triggerValueCtrl = TextEditingController();
  final _warningBeforeCtrl = TextEditingController(text: '0');

  TriggerType _triggerType = TriggerType.date;
  bool _isSafetyCritical = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _triggerValueCtrl.dispose();
    _warningBeforeCtrl.dispose();
    super.dispose();
  }

  String get _triggerUnit {
    switch (_triggerType) {
      case TriggerType.date:
        return 'dní';
      case TriggerType.usageHours:
        return 'hodin';
      case TriggerType.usageDistance:
        return 'km';
      case TriggerType.usageCount:
        return 'použití';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final rule = MaintenanceRule(
      gearItemId: widget.gearItemId,
      name: _nameCtrl.text.trim(),
      triggerType: _triggerType,
      triggerValue: double.parse(_triggerValueCtrl.text.trim()),
      warningBefore: double.parse(_warningBeforeCtrl.text.trim()),
      isSafetyCritical: _isSafetyCritical,
    );

    await _db.insertMaintenanceRule(rule);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addMaintenanceRule),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: '${l10n.ruleName} *',
                border: const OutlineInputBorder(),
                hintText: 'např. Kontrola lana, Výměna mazání',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Zadej název' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TriggerType>(
              value: _triggerType,
              decoration: const InputDecoration(
                labelText: 'Typ spouštěče',
                border: OutlineInputBorder(),
              ),
              items: TriggerType.values
                  .map((t) =>
                      DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) => setState(() => _triggerType = v ?? _triggerType),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _triggerValueCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Interval *',
                border: const OutlineInputBorder(),
                suffixText: _triggerUnit,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Zadej hodnotu';
                if (double.tryParse(v) == null) return 'Zadej číslo';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _warningBeforeCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Varování před',
                border: const OutlineInputBorder(),
                suffixText: _triggerUnit,
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                  return 'Zadej číslo';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _isSafetyCritical,
              onChanged: (v) => setState(() => _isSafetyCritical = v),
              title: Text(l10n.safetyeCritical),
              subtitle: const Text(
                  'Toto pravidlo je klíčové pro bezpečné použití vybavení.'),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────── ADD USAGE LOG SCREEN ───────────────────────────────

class AddUsageLogScreen extends StatefulWidget {
  final int gearItemId;

  const AddUsageLogScreen({super.key, required this.gearItemId});

  @override
  State<AddUsageLogScreen> createState() => _AddUsageLogScreenState();
}

class _AddUsageLogScreenState extends State<AddUsageLogScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _db          = DatabaseHelper.instance;

  final _durationCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  DateTime    _date    = DateTime.now();
  UsageSource _source  = UsageSource.manual;
  String?     _importedFileName;   // shown in the import banner
  bool        _loading = false;

  static final _dateFormat = DateFormat('d. M. yyyy');

  @override
  void dispose() {
    _durationCtrl.dispose();
    _distanceCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  // ── File import ─────────────────────────────────────────────────────────

  Future<void> _onSourceChanged(UsageSource? v) async {
    if (v == null) return;
    if (v == UsageSource.igc) {
      setState(() => _source = v);
      await _importIgc();
    } else if (v == UsageSource.gpx) {
      setState(() => _source = v);
      await _importGpx();
    } else {
      setState(() {
        _source = v;
        _importedFileName = null;
      });
    }
  }

  Future<void> _importIgc() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['igc'],
        withData: true,
      );
    } catch (_) {}

    if (result == null || result.files.isEmpty) {
      // Cancelled – revert source
      setState(() { _source = UsageSource.manual; _importedFileName = null; });
      return;
    }

    final bytes = result.files.first.bytes;
    final name  = result.files.first.name;
    if (bytes == null) {
      setState(() { _source = UsageSource.manual; _importedFileName = null; });
      return;
    }

    final content = utf8.decode(bytes, allowMalformed: true);
    final flight  = IgcParser.parse(content);

    if (flight == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nepodařilo se načíst IGC soubor.')),
        );
      }
      setState(() { _source = UsageSource.manual; _importedFileName = null; });
      return;
    }

    // Autofill fields
    setState(() {
      _date = flight.flightDate;
      _durationCtrl.text = flight.durationMinutes.toString();
      if (_locationCtrl.text.isEmpty) {
        _locationCtrl.text = 'IGC import';
      }
      _importedFileName = name;
    });
  }

  Future<void> _importGpx() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gpx'],
        withData: true,
      );
    } catch (_) {}

    if (result == null || result.files.isEmpty) {
      setState(() { _source = UsageSource.manual; _importedFileName = null; });
      return;
    }

    final bytes = result.files.first.bytes;
    final name  = result.files.first.name;
    if (bytes == null) {
      setState(() { _source = UsageSource.manual; _importedFileName = null; });
      return;
    }

    final content  = utf8.decode(bytes, allowMalformed: true);
    final activity = GpxParser.parse(content);

    // Autofill whatever was parsed
    setState(() {
      if (activity.date != null) _date = activity.date!;
      if (activity.durationMinutes != null) {
        _durationCtrl.text = activity.durationMinutes.toString();
      }
      if (activity.distanceKm != null) {
        _distanceCtrl.text =
            activity.distanceKm!.toStringAsFixed(1);
      }
      if (_locationCtrl.text.isEmpty) {
        _locationCtrl.text =
            activity.trackName?.isNotEmpty == true
                ? activity.trackName!
                : 'GPX import';
      }
      _importedFileName = name;
    });
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final log = UsageLog(
      gearItemId: widget.gearItemId,
      date: _date,
      durationMinutes: _durationCtrl.text.isNotEmpty
          ? int.tryParse(_durationCtrl.text)
          : null,
      distanceKm: _distanceCtrl.text.isNotEmpty
          ? double.tryParse(_distanceCtrl.text)
          : null,
      location: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      source: _source,
    );

    await _db.insertUsageLog(log);
    if (mounted) context.pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addActivity),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Import banner ─────────────────────────────────────────────
            if (_importedFileName != null) ...[
              _ImportBanner(
                fileName: _importedFileName!,
                source: _source,
                onClear: () => setState(() {
                  _source            = UsageSource.manual;
                  _importedFileName  = null;
                  _durationCtrl.clear();
                  _distanceCtrl.clear();
                  _locationCtrl.clear();
                  _date = DateTime.now();
                }),
              ),
              const SizedBox(height: 12),
            ],

            // ── Datum ─────────────────────────────────────────────────────
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: Theme.of(ctx)
                          .colorScheme
                          .copyWith(primary: AppColors.primary),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.dateLabel,
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                ),
                child: Text(_dateFormat.format(_date)),
              ),
            ),
            const SizedBox(height: 12),

            // ── Délka ─────────────────────────────────────────────────────
            TextFormField(
              controller: _durationCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.durationLabel,
                suffixText: 'min',
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty && int.tryParse(v) == null) {
                  return 'Zadej celé číslo';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── Vzdálenost ────────────────────────────────────────────────
            TextFormField(
              controller: _distanceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.distanceLabel,
                suffixText: 'km',
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                  return 'Zadej číslo';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── Místo ─────────────────────────────────────────────────────
            TextFormField(
              controller: _locationCtrl,
              decoration: InputDecoration(labelText: l10n.locationLabel),
            ),
            const SizedBox(height: 12),

            // ── Zdroj ─────────────────────────────────────────────────────
            DropdownButtonFormField<UsageSource>(
              value: _source,
              decoration: const InputDecoration(labelText: 'Zdroj'),
              items: UsageSource.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Row(children: [
                          _sourceIcon(s),
                          const SizedBox(width: 8),
                          Text(s.label),
                        ]),
                      ))
                  .toList(),
              onChanged: _onSourceChanged,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sourceIcon(UsageSource s) {
    final (icon, color) = switch (s) {
      UsageSource.manual => (Icons.edit_outlined,       AppColors.subtitleGray),
      UsageSource.strava => (Icons.directions_run,      const Color(0xFFFC4C02)),
      UsageSource.garmin => (Icons.watch_outlined,      const Color(0xFF006EBF)),
      UsageSource.gpx    => (Icons.route_outlined,      const Color(0xFF5C6BC0)),
      UsageSource.igc    => (Icons.flight_outlined,     const Color(0xFF00897B)),
    };
    return Icon(icon, size: 16, color: color);
  }
}

// ─── Import banner ────────────────────────────────────────────────────────────

class _ImportBanner extends StatelessWidget {
  final String      fileName;
  final UsageSource source;
  final VoidCallback onClear;

  const _ImportBanner({
    required this.fileName,
    required this.source,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, label) = switch (source) {
      UsageSource.igc => (
          const Color(0xFF00897B),
          const Color(0xFFE0F2F1),
          'IGC',
        ),
      UsageSource.gpx => (
          const Color(0xFF5C6BC0),
          const Color(0xFFEDE7F6),
          'GPX',
        ),
      _ => (AppColors.primary, AppColors.primaryBg, 'Soubor'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Importováno z $label',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
                Text(
                  fileName,
                  style: TextStyle(
                      fontSize: 11,
                      color: color.withOpacity(0.8)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 16, color: color),
            onPressed: onClear,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
