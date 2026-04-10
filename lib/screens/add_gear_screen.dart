import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../database/database_helper.dart';
import '../models/category.dart';
import '../models/gear_item.dart';

class AddGearScreen extends StatefulWidget {
  /// Pokud je zadáno, jde o editaci existujícího vybavení.
  final int? gearItemId;

  const AddGearScreen({super.key, this.gearItemId});

  @override
  State<AddGearScreen> createState() => _AddGearScreenState();
}

class _AddGearScreenState extends State<AddGearScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  List<Category> _categories = [];
  int? _selectedCategoryId;
  GearStatus _status = GearStatus.active;
  DateTime? _manufacturedDate;
  DateTime? _purchaseDate;
  String? _photoPath;
  bool _loading = false;
  bool _isEdit = false;
  GearItem? _existingItem;

  static final _dateFormat = DateFormat('d. M. yyyy');

  @override
  void initState() {
    super.initState();
    _isEdit = widget.gearItemId != null;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _db.getCategories();
    if (_isEdit) {
      final item = await _db.getGearItemById(widget.gearItemId!);
      if (item != null) {
        _existingItem = item;
        _nameCtrl.text = item.name;
        _brandCtrl.text = item.brand ?? '';
        _modelCtrl.text = item.model ?? '';
        _serialCtrl.text = item.serialNumber ?? '';
        _notesCtrl.text = item.notes ?? '';
        _selectedCategoryId = item.categoryId;
        _status = item.status;
        _manufacturedDate = item.manufacturedDate;
        _purchaseDate = item.purchaseDate;
        _photoPath = item.photoPath;
      }
    }
    if (mounted) {
      setState(() {
        _categories = cats;
        if (!_isEdit && cats.isNotEmpty) {
          _selectedCategoryId ??= cats.first.id;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _serialCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _photoPath = picked.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vyber kategorii.')),
      );
      return;
    }
    setState(() => _loading = true);

    final item = GearItem(
      id: _existingItem?.id,
      name: _nameCtrl.text.trim(),
      categoryId: _selectedCategoryId!,
      brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim().isEmpty ? null : _modelCtrl.text.trim(),
      serialNumber:
          _serialCtrl.text.trim().isEmpty ? null : _serialCtrl.text.trim(),
      manufacturedDate: _manufacturedDate,
      purchaseDate: _purchaseDate,
      status: _status,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      photoPath: _photoPath,
    );

    if (_isEdit) {
      await _db.updateGearItem(item);
    } else {
      await _db.insertGearItem(item);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Upravit vybavení' : 'Přidat vybavení'),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _save, child: const Text('Uložit')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPhotoSection(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Název *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Zadej název' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Kategorie *',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _brandCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Značka',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _modelCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _serialCtrl,
              decoration: const InputDecoration(
                labelText: 'Sériové číslo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDateField('Rok výroby', _manufacturedDate,
                    (d) => setState(() => _manufacturedDate = d))),
                const SizedBox(width: 12),
                Expanded(child: _buildDateField('Datum koupě', _purchaseDate,
                    (d) => setState(() => _purchaseDate = d))),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<GearStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Stav',
                border: OutlineInputBorder(),
              ),
              items: GearStatus.values
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return GestureDetector(
      onTap: _pickPhoto,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          image: _photoPath != null
              ? DecorationImage(
                  image: FileImage(File(_photoPath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _photoPath == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(
                    'Přidat fotku',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton.filled(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _photoPath = null),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? value,
    void Function(DateTime?) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onChanged(null),
                )
              : const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          value != null ? _dateFormat.format(value) : '–',
          style: value == null
              ? TextStyle(color: Theme.of(context).colorScheme.outline)
              : null,
        ),
      ),
    );
  }
}
