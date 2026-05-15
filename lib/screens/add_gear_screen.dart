import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../models/gear_item.dart';
import '../models/maintenance_rule.dart';
import '../theme/app_theme.dart';
import '../utils/app_logger.dart';
import '../widgets/category_icon.dart';
import '../widgets/photo_picker.dart';

// ─── Draft rule (editable before saving) ─────────────────────────────────────

class _DraftRule {
  String      name;
  TriggerType triggerType;
  double      triggerValue;
  double      warningBefore;
  bool        isSafetyCritical;

  _DraftRule({
    required this.name,
    required this.triggerType,
    required this.triggerValue,
    required this.warningBefore,
    this.isSafetyCritical = false,
  });

  _DraftRule copyWith({
    String? name,
    TriggerType? triggerType,
    double? triggerValue,
    double? warningBefore,
    bool? isSafetyCritical,
  }) => _DraftRule(
    name: name ?? this.name,
    triggerType: triggerType ?? this.triggerType,
    triggerValue: triggerValue ?? this.triggerValue,
    warningBefore: warningBefore ?? this.warningBefore,
    isSafetyCritical: isSafetyCritical ?? this.isSafetyCritical,
  );
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AddGearScreen extends StatefulWidget {
  /// Pokud je zadáno, jde o editaci existujícího vybavení.
  final int? gearItemId;

  const AddGearScreen({super.key, this.gearItemId});

  @override
  State<AddGearScreen> createState() => _AddGearScreenState();
}

class _AddGearScreenState extends State<AddGearScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _db        = DatabaseHelper.instance;

  final _nameCtrl        = TextEditingController();
  final _brandCtrl       = TextEditingController();
  final _modelCtrl       = TextEditingController();
  final _serialCtrl      = TextEditingController();
  final _notesCtrl       = TextEditingController();
  final _purchasePriceCtrl = TextEditingController();

  List<Category>   _categories          = [];
  bool             _isLoadingCategories = true;
  String?          _categoryLoadError;   // null = OK, jinak detail výjimky
  bool             _isReseeding         = false;
  int?             _selectedCatId;
  GearStatus       _status           = GearStatus.active;
  DateTime?        _manufacturedDate;
  DateTime?        _purchaseDate;
  List<_DraftRule> _draftRules       = [];
  bool             _loading          = false;
  bool             _isEdit           = false;
  GearItem?        _existingItem;
  String?          _photoPath;

  // Warranty fields
  DateTime? _warrantyExpiryDate;
  final _warrantyNotesCtrl = TextEditingController();
  String?   _warrantyPhotoPath;

  static final _dateFmt = DateFormat('d. M. yyyy');

  @override
  void initState() {
    super.initState();
    _isEdit = widget.gearItemId != null;
    _loadData();
  }

  Future<void> _loadData() async {
    // Kategorie se načítají nezávisle — vlastní timeout a error stav, aby
    // selhání jejich loadu nezablokovalo zbytek formuláře (a naopak).
    _loadCategories();

    if (_isEdit) {
      final item = await _db.getGearItemById(widget.gearItemId!);
      if (item != null) {
        _existingItem      = item;
        _nameCtrl.text     = item.name;
        _brandCtrl.text    = item.brand ?? '';
        _modelCtrl.text    = item.model ?? '';
        _serialCtrl.text   = item.serialNumber ?? '';
        _notesCtrl.text    = item.notes ?? '';
        _selectedCatId     = item.categoryId;
        _status            = item.status;
        _manufacturedDate  = item.manufacturedDate;
        _purchaseDate          = item.purchaseDate;
        if (item.purchasePrice != null) {
          _purchasePriceCtrl.text = item.purchasePrice!.round().toString();
        }
        _photoPath             = item.photoPath;
        _warrantyExpiryDate    = item.warrantyExpiryDate;
        _warrantyNotesCtrl.text = item.warrantyNotes ?? '';
        _warrantyPhotoPath     = item.warrantyPhotoPath;
        // Load existing rules for edit mode
        final rules = await _db.getRulesForItem(item.id!);
        _draftRules = rules.map((r) => _DraftRule(
          name: r.name,
          triggerType: r.triggerType,
          triggerValue: r.triggerValue,
          warningBefore: r.warningBefore,
          isSafetyCritical: r.isSafetyCritical,
        )).toList();
      }
      if (mounted) setState(() {});
    }
  }

  /// Defenzivní načtení kategorií. Stavový automat:
  /// loading → loaded / empty / error. Po timeoutu nebo výjimce vždy
  /// přejde do error stavu — spinner nikdy nezůstane viset napořád.
  Future<void> _loadCategories() async {
    await AppLogger.instance.info('AddGearScreen: loading categories');
    if (mounted) {
      setState(() {
        _isLoadingCategories = true;
        _categoryLoadError   = null;
      });
    }
    try {
      final cats = await _db
          .getCategories()
          .timeout(const Duration(seconds: 8));
      await AppLogger.instance
          .info('AddGearScreen: loaded ${cats.length} categories');
      if (!mounted) return;
      setState(() {
        _categories          = cats;
        _isLoadingCategories = false;
      });
    } catch (e, st) {
      await AppLogger.instance.error(e, st);
      if (!mounted) return;
      setState(() {
        _categoryLoadError   = e.toString();
        _isLoadingCategories = false;
      });
    }
  }

  /// Obnoví výchozí kategorie (force reseed) a znovu načte sekci.
  /// Po dokončení informuje uživatele SnackBarem o výsledku.
  Future<void> _reseedCategories() async {
    if (_isReseeding) return;
    await AppLogger.instance
        .info('User triggered manual reseed from AddGearScreen');
    setState(() {
      _isReseeding         = true;
      _isLoadingCategories = true;   // během reseedu drž spinner
      _categoryLoadError   = null;
    });

    ({int inserted, int failed}) result;
    try {
      result = await _db.reseedCategories(force: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categoryLoadError   = e.toString();
        _isLoadingCategories = false;
        _isReseeding         = false;
      });
      return;
    }

    if (!mounted) return;
    _isReseeding = false;
    await _loadCategories();
    if (!mounted) return;
    final msg = result.failed > 0
        ? 'Načteno ${result.inserted} kategorií, ${result.failed} se nepodařilo'
        : 'Načteno ${result.inserted} kategorií';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _brandCtrl.dispose(); _modelCtrl.dispose();
    _serialCtrl.dispose(); _notesCtrl.dispose(); _warrantyNotesCtrl.dispose();
    _purchasePriceCtrl.dispose();
    super.dispose();
  }

  // ── Default rules per category icon ───────────────────────────────────────

  static List<_DraftRule> _defaultRulesFor(String icon) => switch (icon) {
    'rope' => [
      _DraftRule(
        name: 'Roční prohlídka lana',
        triggerType: TriggerType.date,
        triggerValue: 365, warningBefore: 30, isSafetyCritical: true,
      ),
      _DraftRule(
        name: 'Výměna po 10 letech',
        triggerType: TriggerType.date,
        triggerValue: 3650, warningBefore: 90, isSafetyCritical: true,
      ),
    ],
    'harness' => [
      _DraftRule(
        name: 'Tříletá bezpečnostní prohlídka',
        triggerType: TriggerType.date,
        triggerValue: 1095, warningBefore: 60, isSafetyCritical: true,
      ),
    ],
    'helmet' => [
      _DraftRule(
        name: 'Roční prohlídka přilby',
        triggerType: TriggerType.date,
        triggerValue: 365, warningBefore: 30, isSafetyCritical: true,
      ),
    ],
    'belay' => [
      _DraftRule(
        name: 'Roční prohlídka jistítka',
        triggerType: TriggerType.date,
        triggerValue: 365, warningBefore: 30, isSafetyCritical: true,
      ),
    ],
    'carabiner' => [
      _DraftRule(
        name: 'Roční prohlídka karabin',
        triggerType: TriggerType.date,
        triggerValue: 365, warningBefore: 30, isSafetyCritical: true,
      ),
    ],
    'ice_axe' => [
      _DraftRule(
        name: 'Sezonní prohlídka cepínu',
        triggerType: TriggerType.date,
        triggerValue: 180, warningBefore: 30, isSafetyCritical: true,
      ),
    ],
    'crampons' => [
      _DraftRule(
        name: 'Sezonní prohlídka mačků',
        triggerType: TriggerType.date,
        triggerValue: 180, warningBefore: 30, isSafetyCritical: true,
      ),
    ],
    'skis' => [
      _DraftRule(
        name: 'Servis a seřízení vázání',
        triggerType: TriggerType.date,
        triggerValue: 180, warningBefore: 30, isSafetyCritical: false,
      ),
    ],
    'bike' => [
      _DraftRule(
        name: 'Servis po 1 000 km',
        triggerType: TriggerType.usageDistance,
        triggerValue: 1000, warningBefore: 100, isSafetyCritical: false,
      ),
      _DraftRule(
        name: 'Přemazání řetězu',
        triggerType: TriggerType.usageDistance,
        triggerValue: 250, warningBefore: 30, isSafetyCritical: false,
      ),
    ],
    'tent' => [
      _DraftRule(
        name: 'Impregnace stanu',
        triggerType: TriggerType.date,
        triggerValue: 365, warningBefore: 30, isSafetyCritical: false,
      ),
    ],
    'sleeping_bag' => [
      _DraftRule(
        name: 'Praní spacáku',
        triggerType: TriggerType.date,
        triggerValue: 365, warningBefore: 30, isSafetyCritical: false,
      ),
    ],
    _ => [],
  };

  void _onCategorySelected(Category cat) {
    final changed = _selectedCatId != cat.id;
    setState(() {
      // Add to list if it doesn't exist yet (e.g. freshly created custom category)
      if (!_categories.any((c) => c.id == cat.id)) {
        _categories = [..._categories, cat];
      }
      _selectedCatId = cat.id;
      if (changed && !_isEdit) {
        _draftRules = _defaultRulesFor(cat.icon);
      }
    });
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCatId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vyber kategorii.')),
      );
      return;
    }
    setState(() => _loading = true);

    final priceText = _purchasePriceCtrl.text.trim();
    final purchasePrice = priceText.isNotEmpty ? double.tryParse(priceText) : null;

    final item = GearItem(
      id: _existingItem?.id,
      name: _nameCtrl.text.trim(),
      categoryId: _selectedCatId!,
      brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim().isEmpty ? null : _modelCtrl.text.trim(),
      serialNumber: _serialCtrl.text.trim().isEmpty ? null : _serialCtrl.text.trim(),
      manufacturedDate: _manufacturedDate,
      purchaseDate: _purchaseDate,
      purchasePrice: purchasePrice,
      status: _status,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      photoPath: _photoPath,
      warrantyExpiryDate: _warrantyExpiryDate,
      warrantyNotes: _warrantyNotesCtrl.text.trim().isEmpty ? null : _warrantyNotesCtrl.text.trim(),
      warrantyPhotoPath: _warrantyPhotoPath,
    );

    if (_isEdit) {
      await _db.updateGearItem(item);
      // Pravidla v edit módu neměníme automaticky (zachovej existující)
    } else {
      final gearId = await _db.insertGearItem(item);
      for (final draft in _draftRules) {
        await _db.insertMaintenanceRule(MaintenanceRule(
          gearItemId: gearId,
          name: draft.name,
          triggerType: draft.triggerType,
          triggerValue: draft.triggerValue,
          warningBefore: draft.warningBefore,
          isSafetyCritical: draft.isSafetyCritical,
        ));
      }
    }

    if (mounted) context.pop();
  }

  // ── Edit rule dialog ──────────────────────────────────────────────────────

  Future<void> _editRule(int index) async {
    final rule = _draftRules[index];
    final nameCtrl  = TextEditingController(text: rule.name);
    final valueCtrl = TextEditingController(
        text: rule.triggerValue.toInt().toString());
    final warnCtrl  = TextEditingController(
        text: rule.warningBefore.toInt().toString());
    var   type      = rule.triggerType;
    var   safety    = rule.isSafetyCritical;

    final l10n = AppLocalizations.of(context);
    final saved = await showDialog<_DraftRule>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(l10n.edit + ' ' + l10n.ruleName.toLowerCase()),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                      labelText: l10n.ruleName, isDense: true),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<TriggerType>(
                  value: type,
                  decoration: const InputDecoration(
                      labelText: 'Typ', isDense: true),
                  items: TriggerType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.label,
                                style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) => setD(() => type = v ?? type),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: valueCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Interval',
                        isDense: true,
                        suffixText: _unitLabel(type),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: warnCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Varování před',
                        isDense: true,
                        suffixText: _unitLabel(type),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: safety,
                  title: Text(l10n.safetyeCritical,
                      style: const TextStyle(fontSize: 13)),
                  activeColor: AppColors.primary,
                  onChanged: (v) => setD(() => safety = v ?? safety),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () => Navigator.pop(
                ctx,
                _DraftRule(
                  name: nameCtrl.text.trim().isEmpty ? rule.name : nameCtrl.text.trim(),
                  triggerType: type,
                  triggerValue: double.tryParse(valueCtrl.text) ?? rule.triggerValue,
                  warningBefore: double.tryParse(warnCtrl.text) ?? rule.warningBefore,
                  isSafetyCritical: safety,
                ),
              ),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (saved != null) {
      setState(() => _draftRules[index] = saved);
    }
  }

  static String _unitLabel(TriggerType t) => switch (t) {
    TriggerType.date          => 'dní',
    TriggerType.usageHours    => 'h',
    TriggerType.usageDistance => 'km',
    TriggerType.usageCount    => '×',
  };

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editGearTitle : l10n.addGearTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            // ── Foto sekce ──────────────────────────────────────────────────
            PhotoPicker(
              photoPath: _photoPath,
              onChanged: (path) => setState(() => _photoPath = path),
              height: 200,
            ),
            const SizedBox(height: 20),
            _buildCategorySection(),
            const SizedBox(height: 20),
            _buildBasicInfoSection(),
            const SizedBox(height: 20),
            _buildDatesSection(),
            const SizedBox(height: 20),
            _buildNotesSection(),
            const SizedBox(height: 20),
            _buildWarrantySection(),
            if (!_isEdit) ...[
              const SizedBox(height: 20),
              _buildRulesSection(),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Category grid ─────────────────────────────────────────────────────────

  // Preferred quick-access order by icon name
  static const _quickIconOrder = [
    'paraglider', 'rope', 'bike', 'harness', 'helmet', 'carabiner',
    'skis', 'ice_axe', 'belay', 'crampons', 'backpack', 'sleeping_bag', 'tent',
  ];

  Widget _buildCategorySection() {
    final l10n = AppLocalizations.of(context);

    // ── Stavový automat sekce Kategorie ───────────────────────────────────
    // loading → error → empty → loaded. Spinner žije POUZE ve stavu loading;
    // po timeoutu/výjimce vždy spadneme do error stavu (viz _loadCategories).
    if (_isLoadingCategories) {
      return _categorySectionFrame(
        l10n,
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_categoryLoadError != null) {
      return _categorySectionFrame(l10n, _buildCategoryErrorBox());
    }
    if (_categories.isEmpty) {
      return _categorySectionFrame(l10n, _buildCategoryEmptyBox());
    }

    // Sort by preferred order; unrecognised icons go last
    final sorted = [..._categories]..sort((a, b) {
        final ai = _quickIconOrder.indexOf(a.icon);
        final bi = _quickIconOrder.indexOf(b.icon);
        return (ai == -1 ? 999 : ai).compareTo(bi == -1 ? 999 : bi);
      });

    final quickCats = sorted.take(6).toList();
    final otherCats = sorted.skip(6).toList();

    // Promote selected-from-others into the quick grid as a 7th tile
    if (_selectedCatId != null) {
      final idx = otherCats.indexWhere((c) => c.id == _selectedCatId);
      if (idx >= 0) {
        quickCats.add(otherCats.removeAt(idx));
      }
    }

    final selectedInOthers = _selectedCatId != null &&
        otherCats.any((c) => c.id == _selectedCatId);
    final moreLabel = selectedInOthers
        ? otherCats.firstWhere((c) => c.id == _selectedCatId).name
        : 'Další kategorie';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(l10n.gearCategory),
        const SizedBox(height: 10),
        // 2 rows × 3 tiles
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 80,
          ),
          itemCount: quickCats.length,
          itemBuilder: (_, i) {
            final cat = quickCats[i];
            return _CategoryTile(
              category: cat,
              selected: cat.id == _selectedCatId,
              onTap: () => _onCategorySelected(cat),
            );
          },
        ),
        if (otherCats.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showMoreCategoriesSheet(otherCats),
              icon: Icon(
                selectedInOthers
                    ? Icons.check_circle_rounded
                    : Icons.expand_more_rounded,
                size: 18,
                color: selectedInOthers ? AppColors.primary : null,
              ),
              label: Text(
                moreLabel,
                style: TextStyle(
                  fontSize: 13,
                  color: selectedInOthers ? AppColors.primary : null,
                  fontWeight: selectedInOthers ? FontWeight.w600 : null,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.subtitleColor,
                side: BorderSide(
                  color: selectedInOthers
                      ? AppColors.primary
                      : context.cardBorderColor,
                  width: selectedInOthers ? 1.5 : 0.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                backgroundColor:
                    selectedInOthers ? AppColors.primaryBg : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Společný rámec sekce (label + obsah) pro loading / error / empty stavy.
  Widget _categorySectionFrame(AppLocalizations l10n, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(l10n.gearCategory),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  // Recovery tlačítka sdílená error i empty stavem.
  // "Zkusit znovu" = hlavní akce (primární barva), "Obnovit výchozí
  // kategorie" = sekundární (tlumený styl). Reseed tlačítko je disabled,
  // dokud běží — ochrana proti dvojímu spuštění.
  Widget _categoryRecoveryButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _loadCategories,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Zkusit znovu'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isReseeding ? null : _reseedCategories,
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Obnovit výchozí kategorie'),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.subtitleColor,
              side: BorderSide(color: context.cardBorderColor),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  // Error stav: něco selhalo při načítání kategorií.
  Widget _buildCategoryErrorBox() {
    final detail = _categoryLoadError ?? '';
    final shortDetail =
        detail.length > 200 ? '${detail.substring(0, 200)}…' : detail;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorderColor, width: 0.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 32, color: AppColors.primary),
          const SizedBox(height: 8),
          const Text(
            'Nepodařilo se načíst kategorie.',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Theme(
            data: Theme.of(context)
                .copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: Text(
                'Detail chyby',
                style: TextStyle(fontSize: 12, color: context.subtitleColor),
              ),
              children: [
                SelectableText(
                  shortDetail,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: context.subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _categoryRecoveryButtons(),
        ],
      ),
    );
  }

  // Empty stav: load proběhl, ale 0 kategorií.
  Widget _buildCategoryEmptyBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(Icons.category_outlined,
              size: 32, color: context.subtitleColor),
          const SizedBox(height: 8),
          Text(
            'Žádné kategorie nejsou k dispozici.',
            style: TextStyle(fontSize: 13, color: context.subtitleColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          _categoryRecoveryButtons(),
        ],
      ),
    );
  }

  void _showMoreCategoriesSheet(List<Category> others) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoreCategoriesSheet(
        categories: others,
        selectedId: _selectedCatId,
        onSelect: (cat) {
          Navigator.pop(context);
          _onCategorySelected(cat);
        },
      ),
    );
  }

  // ── Basic info ────────────────────────────────────────────────────────────

  Widget _buildBasicInfoSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Základní informace'),
        const SizedBox(height: 10),
        _Card(
          children: [
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: '${l10n.gearName} *',
                hintText: 'např. Mammut Crag Classic 9.5',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Zadej název' : null,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _brandCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l10n.gearBrand),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _modelCtrl,
                  decoration: InputDecoration(labelText: l10n.gearModel),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _serialCtrl,
              decoration: InputDecoration(
                labelText: l10n.gearSerialNumber,
                hintText: 'volitelné',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Dates ─────────────────────────────────────────────────────────────────

  Widget _buildDatesSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Datum a stav'),
        const SizedBox(height: 10),
        _Card(
          children: [
            Row(children: [
              Expanded(child: _DateField(
                label: l10n.gearManufacturedDate,
                value: _manufacturedDate,
                onChanged: (d) => setState(() => _manufacturedDate = d),
                dateFmt: _dateFmt,
              )),
              const SizedBox(width: 12),
              Expanded(child: _DateField(
                label: l10n.gearPurchaseDate,
                value: _purchaseDate,
                onChanged: (d) => setState(() => _purchaseDate = d),
                dateFmt: _dateFmt,
              )),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _purchasePriceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Pořizovací cena (Kč)',
                hintText: 'volitelné',
                suffixText: 'Kč',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<GearStatus>(
              value: _status,
              decoration: InputDecoration(labelText: l10n.gearStatus),
              items: GearStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
          ],
        ),
      ],
    );
  }

  // ── Notes ─────────────────────────────────────────────────────────────────

  Widget _buildNotesSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(l10n.gearNotes),
        const SizedBox(height: 10),
        _Card(
          children: [
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
          ],
        ),
      ],
    );
  }

  // ── Warranty ──────────────────────────────────────────────────────────────

  Widget _buildWarrantySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Záruka'),
        const SizedBox(height: 10),
        _Card(
          children: [
            // Date picker row
            InkWell(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _warrantyExpiryDate ?? now,
                  firstDate: now.subtract(const Duration(days: 3650)),
                  lastDate: now.add(const Duration(days: 7300)),
                );
                if (picked != null) {
                  setState(() => _warrantyExpiryDate = picked);
                }
              },
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
                          const Text(
                            'Platnost záruky do',
                            style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _warrantyExpiryDate != null
                                ? _dateFmt.format(_warrantyExpiryDate!)
                                : 'Vybrat datum',
                            style: TextStyle(
                              fontSize: 14,
                              color: _warrantyExpiryDate != null ? null : const Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_warrantyExpiryDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _warrantyExpiryDate = null),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            TextFormField(
              controller: _warrantyNotesCtrl,
              decoration: const InputDecoration(
                labelText: 'Poznámky k záruce',
                hintText: 'číslo dokladu, prodejce…',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Foto záručního listu',
                style: TextStyle(fontSize: 12, color: const Color(0xFF757575)),
              ),
            ),
            const SizedBox(height: 6),
            PhotoPicker(
              photoPath: _warrantyPhotoPath,
              onChanged: (path) => setState(() => _warrantyPhotoPath = path),
              height: 120,
            ),
          ],
        ),
      ],
    );
  }

  // ── Maintenance rules ─────────────────────────────────────────────────────

  Widget _buildRulesSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionLabel(l10n.maintenancePlan),
            TextButton.icon(
              onPressed: () {
                setState(() => _draftRules.add(_DraftRule(
                  name: 'Nové pravidlo',
                  triggerType: TriggerType.date,
                  triggerValue: 365,
                  warningBefore: 30,
                )));
                // otevři dialog na nový záznam
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _editRule(_draftRules.length - 1),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(l10n.add, style: const TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_selectedCatId == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.cardBorderColor, width: 0.5),
            ),
            child: Text(
              'Po výběru kategorie se zobrazí výchozí plán údržby.',
              style: TextStyle(fontSize: 13, color: context.subtitleColor),
              textAlign: TextAlign.center,
            ),
          )
        else if (_draftRules.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.cardBorderColor, width: 0.5),
            ),
            child: Text(
              'Žádná pravidla. Tapni + pro přidání.',
              style: TextStyle(fontSize: 13, color: context.subtitleColor),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...List.generate(_draftRules.length, (i) {
            final rule = _draftRules[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _RuleCard(
                rule: rule,
                onEdit: () => _editRule(i),
                onRemove: () => setState(() => _draftRules.removeAt(i)),
              ),
            );
          }),
      ],
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : Colors.white,
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
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _loading ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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
                      : Text(_isEdit ? l10n.save : l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category tile ────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final Category     category;
  final bool         selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor   = selected ? AppColors.primaryBg
        : (context.isDark ? AppColors.darkCard : Colors.white);
    final iconColor = selected ? AppColors.primary : _iconAccentColor(category.icon);
    final textColor = selected ? AppColors.primary : context.subtitleColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : context.cardBorderColor,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CategoryIcon(iconName: category.icon, size: 22, color: iconColor),
                  const SizedBox(height: 5),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Checkmark badge
            if (selected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Color _iconAccentColor(String icon) => switch (icon) {
    'rope'       => const Color(0xFFE8A020),
    'bike'       => const Color(0xFF378ADD),
    'harness'    => const Color(0xFF7F77DD),
    'skis'       => const Color(0xFF7F77DD),
    'paraglider' => const Color(0xFF1D9E75),
    _            => const Color(0xFF9E9E9E),
  };
}

// ─── More categories bottom sheet ────────────────────────────────────────────

class _MoreCategoriesSheet extends StatefulWidget {
  final List<Category>           categories;
  final int?                     selectedId;
  final void Function(Category)  onSelect;

  const _MoreCategoriesSheet({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  State<_MoreCategoriesSheet> createState() => _MoreCategoriesSheetState();
}

class _MoreCategoriesSheetState extends State<_MoreCategoriesSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Ask for custom name, then create a synthetic Category and call onSelect
  Future<void> _addCustomCategory(BuildContext ctx) async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Vlastní kategorie'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Název kategorie',
            isDense: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(AppLocalizations.of(ctx).confirm),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      // Insert the new category into DB and return it
      final db  = DatabaseHelper.instance;
      final id  = await db.insertCategory(
        Category(name: name, icon: 'star', sport: 'vlastní'),
      );
      widget.onSelect(
        Category(id: id, name: name, icon: 'star', sport: 'vlastní'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.categories
        : widget.categories
            .where((c) =>
                c.name.toLowerCase().contains(_query.toLowerCase()) ||
                c.sport.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.cardBorderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Všechny kategorie',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: false,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Hledat kategorii…',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 44, minHeight: 44),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.50,
            ),
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Žádná kategorie nenalezena.',
                      style: TextStyle(
                          fontSize: 13, color: context.subtitleColor),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length + 1, // +1 for custom entry
                    itemBuilder: (_, i) {
                      // Last item = "+ Vlastní kategorie"
                      if (i == filtered.length) {
                        return ListTile(
                          leading: Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: context.isDark
                                  ? AppColors.darkSurface
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.add_rounded,
                                size: 20, color: AppColors.primary),
                          ),
                          title: const Text(
                            '+ Vlastní kategorie',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          subtitle: Text(
                            'Zadej libovolný název',
                            style: TextStyle(
                                fontSize: 12, color: context.subtitleColor),
                          ),
                          onTap: () => _addCustomCategory(context),
                        );
                      }

                      final cat      = filtered[i];
                      final selected = cat.id == widget.selectedId;
                      return ListTile(
                        leading: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryBg
                                : (context.isDark
                                    ? AppColors.darkSurface
                                    : const Color(0xFFF5F5F5)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CategoryIcon(
                            iconName: cat.icon, size: 20,
                            color: selected
                                ? AppColors.primary
                                : context.subtitleColor,
                          ),
                        ),
                        title: Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? AppColors.primary : null,
                          ),
                        ),
                        subtitle: Text(
                          cat.sport,
                          style: TextStyle(
                              fontSize: 12, color: context.subtitleColor),
                        ),
                        trailing: selected
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary, size: 20)
                            : null,
                        onTap: () => widget.onSelect(cat),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Draft rule card ──────────────────────────────────────────────────────────

class _RuleCard extends StatelessWidget {
  final _DraftRule  rule;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _RuleCard({
    required this.rule,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final intervalText = _intervalText(rule);

    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorderColor, width: 0.5),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            rule.isSafetyCritical
                ? Icons.shield_outlined
                : Icons.build_outlined,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          rule.name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          intervalText,
          style: TextStyle(fontSize: 11, color: context.subtitleColor),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 18, color: context.subtitleColor),
              onPressed: onEdit,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: Icon(Icons.close_rounded,
                  size: 18, color: context.subtitleColor),
              onPressed: onRemove,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  static String _intervalText(_DraftRule r) => switch (r.triggerType) {
    TriggerType.date =>
        'každých ${r.triggerValue.toInt()} dní'
        '  ·  varování ${r.warningBefore.toInt()} dní předem',
    TriggerType.usageHours =>
        'každých ${r.triggerValue.toStringAsFixed(0)} h'
        '  ·  varování ${r.warningBefore.toStringAsFixed(0)} h předem',
    TriggerType.usageDistance =>
        'každých ${r.triggerValue.toStringAsFixed(0)} km'
        '  ·  varování ${r.warningBefore.toStringAsFixed(0)} km předem',
    TriggerType.usageCount =>
        'každých ${r.triggerValue.toInt()}×'
        '  ·  varování ${r.warningBefore.toInt()}× předem',
  };
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorderColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String                    label;
  final DateTime?                 value;
  final void Function(DateTime?)  onChanged;
  final DateFormat                dateFmt;

  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.dateFmt,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: Theme.of(ctx).colorScheme.copyWith(
                    primary: AppColors.primary,
                  ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () => onChanged(null),
                )
              : const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          value != null ? dateFmt.format(value!) : '–',
          style: value == null
              ? TextStyle(color: context.subtitleColor)
              : null,
        ),
      ),
    );
  }
}
