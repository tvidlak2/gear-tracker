import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/gear_item.dart';
import '../models/insurance.dart';
import '../services/insurance_service.dart';
import '../theme/app_theme.dart';

class InsuranceDetailScreen extends StatefulWidget {
  final String insuranceId;
  const InsuranceDetailScreen({super.key, required this.insuranceId});

  @override
  State<InsuranceDetailScreen> createState() => _InsuranceDetailScreenState();
}

class _InsuranceDetailScreenState extends State<InsuranceDetailScreen> {
  Insurance? _insurance;
  List<GearItem> _linkedGear = [];
  bool _loading = true;

  static final _dateFmt     = DateFormat('d. M. yyyy', 'cs');
  static final _currencyFmt = NumberFormat('#,##0', 'cs');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final all = await InsuranceService.instance.getAllInsurances();
      final ins = all.where((i) => i.id == widget.insuranceId).firstOrNull;
      if (ins == null) {
        if (mounted) context.pop();
        return;
      }

      // Load linked gear items
      final linkedGear = <GearItem>[];
      for (final gearId in ins.gearItemIds) {
        final parsed = int.tryParse(gearId);
        if (parsed != null) {
          final g = await DatabaseHelper.instance.getGearItemById(parsed);
          if (g != null) linkedGear.add(g);
        }
      }

      if (mounted) {
        setState(() {
          _insurance = ins;
          _linkedGear = linkedGear;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final ins = _insurance!;
    final now = DateTime.now();
    final isExpired = ins.expiryDate.isBefore(now);
    final daysLeft = ins.expiryDate.difference(now).inDays;
    final isExpiringSoon = !isExpired && daysLeft <= 60;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color expiryColor = isExpired
        ? AppColors.danger
        : isExpiringSoon
            ? AppColors.warning
            : AppColors.success;

    return Scaffold(
      appBar: AppBar(
        title: Text(ins.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context
                .push('/insurance/${ins.id}/edit')
                .then((_) => _loadData()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header card ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.cardBorderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ins.type.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  ins.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ins.insuranceCompany,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.subtitleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Smlouva: ${ins.policyNumber}',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.subtitleColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Info section ───────────────────────────────────────────────
          _buildSectionLabel('Detaily pojistky'),
          const SizedBox(height: 10),
          _buildInfoCard([
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Datum začátku',
              value: _dateFmt.format(ins.startDate),
            ),
            const Divider(height: 1),
            _buildInfoRow(
              icon: Icons.event_outlined,
              label: 'Datum vypršení',
              value: isExpired
                  ? 'Vypršela ${_dateFmt.format(ins.expiryDate)}'
                  : 'Do ${_dateFmt.format(ins.expiryDate)}',
              valueColor: expiryColor,
            ),
            if (ins.annualPremium != null) ...[
              const Divider(height: 1),
              _buildInfoRow(
                icon: Icons.payments_outlined,
                label: 'Roční pojistné',
                value: '${_currencyFmt.format(ins.annualPremium)} Kč/rok',
              ),
            ],
            if (ins.coverageAmount != null) ...[
              const Divider(height: 1),
              _buildInfoRow(
                icon: Icons.shield_outlined,
                label: 'Pojistná částka',
                value: '${_currencyFmt.format(ins.coverageAmount)} Kč',
              ),
            ],
          ], isDark: isDark),

          if (ins.notes != null && ins.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionLabel('Poznámky'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorderColor, width: 0.5),
              ),
              child: Text(
                ins.notes!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],

          // ── Contract photo ─────────────────────────────────────────────
          if (ins.photoPath != null &&
              !kIsWeb &&
              File(ins.photoPath!).existsSync()) ...[
            const SizedBox(height: 16),
            _buildSectionLabel('Foto smlouvy'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showFullScreenPhoto(context, ins.photoPath!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(ins.photoPath!),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],

          // ── Linked gear ─────────────────────────────────────────────────
          if (_linkedGear.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionLabel('Propojené vybavení'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorderColor, width: 0.5),
              ),
              child: Column(
                children: _linkedGear.asMap().entries.map((entry) {
                  final i = entry.key;
                  final g = entry.value;
                  final isLast = i == _linkedGear.length - 1;
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.backpack_outlined, size: 20),
                        title: Text(g.name, style: const TextStyle(fontSize: 14)),
                        onTap: () => context.push('/gear/${g.id}'),
                        trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                      ),
                      if (!isLast)
                        Divider(
                          height: 0,
                          indent: 56,
                          color: context.cardBorderColor,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ── Action buttons ─────────────────────────────────────────────
          _buildSectionLabel('Akce'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: ins.insuranceCompany));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Název pojišťovny zkopírován'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('Kontakt', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final dateStr = _dateFmt.format(ins.expiryDate);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Připomínka: Prodloužení pojistky ${ins.name} do $dateStr. '
                          'Otevři Kalendář v telefonu.',
                        ),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: const Text('Připomínka', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children, {required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorderColor, width: 0.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF757575)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenPhoto(BuildContext context, String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(File(path)),
            ),
          ),
        ),
      ),
    );
  }
}
