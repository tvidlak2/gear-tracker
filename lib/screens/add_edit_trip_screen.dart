import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class AddEditTripScreen extends StatefulWidget {
  final Trip? trip;

  const AddEditTripScreen({super.key, this.trip});

  @override
  State<AddEditTripScreen> createState() => _AddEditTripScreenState();
}

class _AddEditTripScreenState extends State<AddEditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _departureDate;
  DateTime? _returnDate;
  TripStatus _status = TripStatus.planning;
  bool _saving = false;

  bool get _isEdit => widget.trip != null;

  static final _dateFmt = DateFormat('d. M. yyyy', 'cs');

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      final t = widget.trip!;
      _nameCtrl.text = t.name;
      _destinationCtrl.text = t.destination ?? '';
      _notesCtrl.text = t.notes ?? '';
      _departureDate = t.departureDate;
      _returnDate = t.returnDate;
      _status = t.status;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _destinationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isDeparture}) async {
    final initial = isDeparture
        ? (_departureDate ?? DateTime.now())
        : (_returnDate ?? _departureDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('cs'),
    );
    if (picked == null) return;

    setState(() {
      if (isDeparture) {
        _departureDate = picked;
        // Reset return date if it's before departure
        if (_returnDate != null && _returnDate!.isBefore(picked)) {
          _returnDate = null;
        }
      } else {
        _returnDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final Trip trip;
      if (_isEdit) {
        trip = widget.trip!.copyWith(
          name: _nameCtrl.text.trim(),
          destination: _destinationCtrl.text.trim().isEmpty
              ? null
              : _destinationCtrl.text.trim(),
          departureDate: _departureDate,
          returnDate: _returnDate,
          status: _status,
          notes:
              _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
      } else {
        trip = Trip.create(
          name: _nameCtrl.text.trim(),
          destination: _destinationCtrl.text.trim().isEmpty
              ? null
              : _destinationCtrl.text.trim(),
          departureDate: _departureDate,
          returnDate: _returnDate,
          status: _status,
          notes:
              _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
      }

      await TripService.instance.saveTrip(trip);

      // Schedule reminder notification 3 days before departure
      try {
        await NotificationService.instance.scheduleTripReminder(trip);
      } catch (_) {
        // Notifications are optional
      }

      if (mounted) context.pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(_isEdit ? AppLocalizations.of(context).editTripTitle : AppLocalizations.of(context).newTripTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _buildSection(
              AppLocalizations.of(context).basicInfoSection,
              [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).tripNameLabel,
                    hintText: AppLocalizations.of(context).tripNameHint,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? AppLocalizations.of(context).tripNameRequired : null,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _destinationCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).destinationLabel,
                    hintText: AppLocalizations.of(context).destinationHint,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              AppLocalizations.of(context).dateSection,
              [
                _DateField(
                  label: AppLocalizations.of(context).departureDateLabel,
                  date: _departureDate,
                  fmt: _dateFmt,
                  onTap: () => _pickDate(isDeparture: true),
                  onClear: () => setState(() => _departureDate = null),
                ),
                const SizedBox(height: 14),
                _DateField(
                  label: AppLocalizations.of(context).returnDateLabel,
                  date: _returnDate,
                  fmt: _dateFmt,
                  enabled: true,
                  onTap: () => _pickDate(isDeparture: false),
                  onClear: () => setState(() => _returnDate = null),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              AppLocalizations.of(context).tripStatusSection,
              [
                DropdownButtonFormField<TripStatus>(
                  value: _status,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context).tripStatusLabel),
                  items: TripStatus.values
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text('${s.emoji} ${s.label}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              AppLocalizations.of(context).notes,
              [
                TextFormField(
                  controller: _notesCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).notes,
                    hintText: 'Tipy, trasy, ubytování...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    AppLocalizations.of(context).saveTripButton,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.subtitleGray,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateFormat fmt;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final bool enabled;

  const _DateField({
    required this.label,
    required this.date,
    required this.fmt,
    required this.onTap,
    required this.onClear,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: date != null
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          date != null ? fmt.format(date!) : AppLocalizations.of(context).notSelected,
          style: TextStyle(
            color: date != null
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
