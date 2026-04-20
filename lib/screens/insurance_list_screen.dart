import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/insurance.dart';
import '../services/insurance_service.dart';
import '../theme/app_theme.dart';

class InsuranceListScreen extends StatefulWidget {
  const InsuranceListScreen({super.key});

  @override
  State<InsuranceListScreen> createState() => _InsuranceListScreenState();
}

class _InsuranceListScreenState extends State<InsuranceListScreen> {
  List<Insurance> _insurances = [];
  bool _loading = true;

  static final _dateFmt = DateFormat('d. M. yyyy', 'cs');
  static final _currencyFmt = NumberFormat('#,##0', 'cs');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final insurances = await InsuranceService.instance.getAllInsurances();
      if (mounted) setState(() { _insurances = insurances; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteInsurance(Insurance ins) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteInsuranceTitle),
        content: Text(l10n.deleteInsuranceConfirm(ins.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await InsuranceService.instance.deleteInsurance(ins.id);
      _loadData();
    }
  }

  double get _totalAnnualPremium =>
      _insurances.fold(0.0, (sum, ins) => sum + (ins.annualPremium ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final total = _totalAnnualPremium;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.insuranceTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/insurance/add').then((_) => _loadData()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _insurances.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          itemCount: _insurances.length,
                          itemBuilder: (_, i) => _buildInsuranceCard(_insurances[i], isDark),
                        ),
                      ),
                    ),
                    if (total > 0)
                      _buildTotalBar(total, isDark),
                  ],
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
            Icon(Icons.security_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              l10n.noInsurance,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noInsuranceHint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  context.push('/insurance/add').then((_) => _loadData()),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.add),
              label: Text(l10n.addInsurance),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceCard(Insurance ins, bool isDark) {
    final now = DateTime.now();
    final isExpired = ins.expiryDate.isBefore(now);
    final daysLeft = ins.expiryDate.difference(now).inDays;
    final isExpiringSoon = !isExpired && daysLeft <= 60;

    final Color expiryColor = isExpired
        ? AppColors.danger
        : isExpiringSoon
            ? AppColors.warning
            : Colors.grey.shade600;

    final l10n = AppLocalizations.of(context);
    final String chipLabel;
    final Color chipColor;
    final Color chipBg;
    if (isExpired) {
      chipLabel = l10n.insuranceExpired;
      chipColor = AppColors.danger;
      chipBg = AppColors.dangerBg;
    } else if (isExpiringSoon) {
      chipLabel = l10n.insuranceExpiringSoon;
      chipColor = AppColors.warning;
      chipBg = const Color(0xFFFFF3E0);
    } else {
      chipLabel = l10n.insuranceActive;
      chipColor = AppColors.success;
      chipBg = AppColors.primaryBg;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(ins.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        confirmDismiss: (_) async {
          await _deleteInsurance(ins);
          return false; // We handle deletion ourselves
        },
        child: InkWell(
          onTap: () =>
              context.push('/insurance/${ins.id}').then((_) => _loadData()),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.cardBorderColor, width: 0.5),
            ),
            child: Row(
              children: [
                Text(ins.type.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ins.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: chipBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              chipLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: chipColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ins.insuranceCompany} · ${ins.policyNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.subtitleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 12, color: expiryColor),
                          const SizedBox(width: 4),
                          Text(
                            isExpired
                                ? l10n.insuranceExpiredOn(_dateFmt.format(ins.expiryDate))
                                : l10n.insuranceValidUntil(_dateFmt.format(ins.expiryDate)),
                            style: TextStyle(
                              fontSize: 12,
                              color: expiryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (ins.annualPremium != null) ...[
                            const SizedBox(width: 12),
                            Text(
                              '${_currencyFmt.format(ins.annualPremium)} Kč/rok',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.subtitleColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: Color(0xFF9E9E9E)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBar(double total, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border(
          top: BorderSide(color: context.cardBorderColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).totalAnnualCost,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              '${NumberFormat('#,##0', 'cs').format(total)} Kč',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
