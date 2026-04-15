import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../models/gear_item.dart';
import '../services/maintenance_service.dart';
import '../widgets/gear_card.dart';

class GearListScreen extends StatefulWidget {
  const GearListScreen({super.key});

  @override
  State<GearListScreen> createState() => _GearListScreenState();
}

class _GearListScreenState extends State<GearListScreen> {
  final _db = DatabaseHelper.instance;
  final _maintenanceService = MaintenanceService();

  List<GearItem> _items = [];
  List<Category> _categories = [];
  Map<int, MaintenanceStatus> _statusMap = {};
  Map<int, Category> _categoryMap = {};

  GearStatus? _filterStatus;
  int? _filterCategoryId;
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final items = await _db.getGearItems(
      status: _filterStatus,
      categoryId: _filterCategoryId,
    );
    final categories = await _db.getCategories();
    final categoryMap = {for (final c in categories) c.id!: c};
    final statusMap = <int, MaintenanceStatus>{};
    for (final item in items) {
      if (item.id != null) {
        statusMap[item.id!] =
            await _maintenanceService.getWorstStatusForItem(item.id!);
      }
    }
    if (mounted) {
      setState(() {
        _items = items;
        _categories = categories;
        _categoryMap = categoryMap;
        _statusMap = statusMap;
        _loading = false;
      });
    }
  }

  List<GearItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final q = _searchQuery.toLowerCase();
    return _items.where((i) {
      return i.name.toLowerCase().contains(q) ||
          (i.brand?.toLowerCase().contains(q) ?? false) ||
          (i.model?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myGear),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: SearchBar(
              hintText: 'Hledat vybavení…',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          if (_filterStatus != null || _filterCategoryId != null)
            _buildActiveFilters(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? Center(child: Text(l10n.noData))
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                          itemCount: _filteredItems.length,
                          itemBuilder: (_, i) {
                            final item = _filteredItems[i];
                            return GearCard(
                              item: item,
                              category: _categoryMap[item.categoryId],
                              maintenanceStatus:
                                  _statusMap[item.id] ?? MaintenanceStatus.ok,
                              onTap: () => context
                                  .push('/gear/${item.id}')
                                  .then((_) => _loadData()),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/gear/add').then((_) => _loadData()),
        icon: const Icon(Icons.add),
        label: Text(l10n.add),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Wrap(
        spacing: 8,
        children: [
          if (_filterStatus != null)
            Chip(
              label: Text(_filterStatus!.label),
              onDeleted: () => setState(() {
                _filterStatus = null;
                _loadData();
              }),
            ),
          if (_filterCategoryId != null)
            Chip(
              label: Text(
                _categoryMap[_filterCategoryId]?.name ?? 'Kategorie',
              ),
              onDeleted: () => setState(() {
                _filterCategoryId = null;
                _loadData();
              }),
            ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => _FilterSheet(
        categories: _categories,
        selectedStatus: _filterStatus,
        selectedCategoryId: _filterCategoryId,
        onApply: (status, categoryId) {
          setState(() {
            _filterStatus = status;
            _filterCategoryId = categoryId;
          });
          _loadData();
        },
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final List<Category> categories;
  final GearStatus? selectedStatus;
  final int? selectedCategoryId;
  final void Function(GearStatus? status, int? categoryId) onApply;

  const _FilterSheet({
    required this.categories,
    required this.selectedStatus,
    required this.selectedCategoryId,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  GearStatus? _status;
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    _status = widget.selectedStatus;
    _categoryId = widget.selectedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtrovat', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(l10n.gearStatus, style: Theme.of(context).textTheme.labelLarge),
          Wrap(
            spacing: 8,
            children: GearStatus.values.map((s) {
              return ChoiceChip(
                label: Text(s.label),
                selected: _status == s,
                onSelected: (v) =>
                    setState(() => _status = v ? s : null),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(l10n.gearCategory, style: Theme.of(context).textTheme.labelLarge),
          Wrap(
            spacing: 8,
            children: widget.categories.map((c) {
              return ChoiceChip(
                label: Text(c.name),
                selected: _categoryId == c.id,
                onSelected: (v) =>
                    setState(() => _categoryId = v ? c.id : null),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  widget.onApply(null, null);
                  Navigator.pop(context);
                },
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  widget.onApply(_status, _categoryId);
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context).apply),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
