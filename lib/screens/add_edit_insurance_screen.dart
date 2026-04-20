import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/gear_item.dart';
import '../models/insurance.dart';
import '../services/insurance_service.dart';
import '../theme/app_theme.dart';
import '../widgets/photo_picker.dart';

class AddEditInsuranceScreen extends StatefulWidget {
  /// Existing insurance (edit mode) — null means create new.
  final Insurance? insurance;

  /// Pre-selected gear item ID (when opened from GearDetailScreen).
  final String? preselectedGearId;

  const AddEditInsuranceScreen({
    super.key,
    this.insurance,
    this.preselectedGearId,
  });

  @override
  State<AddEditInsuranceScreen> createState() => _AddEditInsuranceScreenState();
}

class _AddEditInsuranceScreenState extends State<AddEditInsuranceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl      = TextEditingController();
  final _companyCtrl   = TextEditingController();
  final _policyCtrl    = TextEditingController();
  final _premiumCtrl   = TextEditingController();
  final _coverageCtrl  = TextEditingController();
  final _notesCtrl     = TextEditingController();

  InsuranceType _type = InsuranceType.gearInsurance;
  DateTime? _startDate;
  DateTime? _expiryDate;
  String? _photoPath;
  List<String> _selectedGearIds = [];

  List<GearItem> _allGear = [];
  bool _loading = false;

  static final _dateFmt = DateFormat('d. M. yyyy', 'cs');

  bool get _isEdit => widget.insurance != null;

  @override
  void initState() {
    super.initState();
    _loadGear();
    if (_isEdit) {
      final ins = widget.insurance!;
      _nameCtrl.text    = ins.name;
      _companyCtrl.text = ins.insuranceCompany;
      _policyCtrl.text  = ins.policyNumber;
      if (ins.annualPremium != null) {
        _premiumCtrl.text = ins.annualPremium!.toStringAsFixed(0);
      }
      if (ins.coverageAmount != null) {
        _coverageCtrl.text = ins.coverageAmount!.toStringAsFixed(0);
      }
      _notesCtrl.text = ins.notes ?? '';
      _type = ins.type;
      _startDate = ins.startDate;
      _expiryDate = ins.expiryDate;
      _photoPath = ins.photoPath;
      _selectedGearIds = List.from(ins.gearItemIds);
    } else if (widget.preselectedGearId != null) {
      _selectedGearIds = [widget.preselectedGearId!];
    }
  }

  Future<void> _loadGear() async {
    final items = await DatabaseHelper.instance.getGearItems(status: GearStatus.active);
    if (mounted) setState(() => _allGear = items);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _policyCtrl.dispose();
    _premiumCtrl.dispose();
    _coverageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final now = DateTime.now();
    final initial = isExpiry
        ? (_expiryDate ?? now.add(const Duration(days: 365)))
        : (_startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2060),
    );
    if (picked != null) {
      setState(() {
        if (isExpiry) {
          _expiryDate = picked;
        } else {
          _startDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).expiryDateRequired)),
      );
      return;
    }
    setState(() => _loading = true);

    try {
      final Insurance ins;
      if (_isEdit) {
        ins = widget.insurance!.copyWith(
          name: _nameCtrl.text.trim(),
          type: _type,
          insuranceCompany: _companyCtrl.text.trim(),
          policyNumber: _policyCtrl.text.trim(),
          startDate: _startDate ?? widget.insurance!.startDate,
          expiryDate: _expiryDate!,
          annualPremium: _premiumCtrl.text.isEmpty
              ? null
              : double.tryParse(_premiumCtrl.text),
          coverageAmount: _coverageCtrl.text.isEmpty
              ? null
              : double.tryParse(_coverageCtrl.text),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          photoPath: _photoPath,
          gearItemIds: _selectedGearIds,
        );
      } else {
        ins = Insurance.create(
          name: _nameCtrl.text.trim(),
          type: _type,
          insuranceCompany: _companyCtrl.text.trim(),
          policyNumber: _policyCtrl.text.trim(),
          startDate: _startDate ?? DateTime.now(),
          expiryDate: _expiryDate!,
          annualPremium: _premiumCtrl.text.isEmpty
              ? null
              : double.tryParse(_premiumCtrl.text),
          coverageAmount: _coverageCtrl.text.isEmpty
              ? null
              : double.tryParse(_coverageCtrl.text),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          photoPath: _photoPath,
          gearItemIds: _selectedGearIds,
        );
      }

      await InsuranceService.instance.saveInsurance(ins);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editInsuranceTitle : l10n.newInsuranceTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            // ── Základní info ──────────────────────────────────────────────
            _buildSectionLabel(l10n.basicInfoSection),
            const SizedBox(height: 10),
            _buildCard([
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.insuranceNameLabel,
                  hintText: l10n.insuranceNameHint,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.insuranceNameRequired : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<InsuranceType>(
                value: _type,
                decoration: InputDecoration(labelText: l10n.insuranceTypeLabel),
                items: InsuranceType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Row(
                            children: [
                              Text(t.emoji),
                              const SizedBox(width: 8),
                              Text(t.label),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _companyCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.insuranceCompanyLabel,
                  hintText: l10n.insuranceCompanyHint,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.insuranceCompanyRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _policyCtrl,
                decoration: InputDecoration(
                  labelText: l10n.policyNumberLabel,
                  hintText: l10n.policyNumberHint,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.policyNumberRequired : null,
              ),
            ]),

            // ── Data ──────────────────────────────────────────────────────
            const SizedBox(height: 20),
            _buildSectionLabel(l10n.validitySection),
            const SizedBox(height: 10),
            _buildCard([
              _buildDateRow(
                label: l10n.insuranceStartDate,
                value: _startDate,
                onTap: () => _pickDate(isExpiry: false),
              ),
              const Divider(height: 1),
              _buildDateRow(
                label: '${l10n.insuranceExpiryDate} *',
                value: _expiryDate,
                onTap: () => _pickDate(isExpiry: true),
                required: true,
              ),
            ]),

            // ── Finanční info ─────────────────────────────────────────────
            const SizedBox(height: 20),
            _buildSectionLabel(l10n.financialSection),
            const SizedBox(height: 10),
            _buildCard([
              TextFormField(
                controller: _premiumCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.annualPremiumLabel,
                  hintText: l10n.optionalHint,
                  suffixText: 'Kč/rok',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _coverageCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.coverageAmountLabel,
                  hintText: l10n.optionalHint,
                  suffixText: 'Kč',
                ),
              ),
            ]),

            // ── Poznámky a foto ───────────────────────────────────────────
            const SizedBox(height: 20),
            _buildSectionLabel(l10n.notes),
            const SizedBox(height: 10),
            _buildCard([
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Volitelné poznámky…',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionLabel(l10n.contractPhoto),
            const SizedBox(height: 10),
            PhotoPicker(
              photoPath: _photoPath,
              onChanged: (path) => setState(() => _photoPath = path),
              height: 160,
            ),

            // ── Propojené vybavení ────────────────────────────────────────
            if (_allGear.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSectionLabel(l10n.linkedGearSection),
              const SizedBox(height: 10),
              _buildCard(
                _allGear.map((gear) {
                  final selected =
                      _selectedGearIds.contains(gear.id.toString());
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: selected,
                    title: Text(gear.name,
                        style: const TextStyle(fontSize: 14)),
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      setState(() {
                        final id = gear.id.toString();
                        if (v == true) {
                          _selectedGearIds.add(id);
                        } else {
                          _selectedGearIds.remove(id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF757575),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDateRow({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool required = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value != null
                        ? _dateFmt.format(value)
                        : required
                            ? AppLocalizations.of(context).selectDateRequired
                            : AppLocalizations.of(context).selectDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: value != null ? null : const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            if (value != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => setState(() {
                  if (required) {
                    // Don't clear required expiry date
                  }
                }),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : Colors.white,
        border: Border(
          top: BorderSide(color: context.cardBorderColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(AppLocalizations.of(context).cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _loading ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isEdit ? AppLocalizations.of(context).save : AppLocalizations.of(context).addInsurance),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
