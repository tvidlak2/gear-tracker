import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../l10n/app_localizations.dart';
import '../services/annual_report_service.dart';

class AnnualReportScreen extends StatefulWidget {
  const AnnualReportScreen({super.key});

  @override
  State<AnnualReportScreen> createState() => _AnnualReportScreenState();
}

class _AnnualReportScreenState extends State<AnnualReportScreen> {
  final int _currentYear = DateTime.now().year;
  late int _selectedYear;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedYear = _currentYear;
  }

  Future<void> _generateReport() async {
    setState(() {
      _loading = true;
      _error   = null;
    });

    try {
      final data    = await AnnualReportService.instance.collectData(_selectedYear);
      final pdfBytes = await AnnualReportService.instance.generatePdf(data);

      if (!mounted) return;

      await Printing.sharePdf(
        bytes:    pdfBytes,
        filename: 'OutdoorGearTracker_Report_$_selectedYear.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      if (mounted) setState(() => _error = AppLocalizations.of(context).reportError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final tt  = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.annualReportTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Info card ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: cs.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      l10n.annualReportPdfTitle,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.reportContains,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                ...[
                  l10n.reportItemActivities,
                  l10n.reportItemGearStats,
                  l10n.reportItemMonthly,
                  l10n.reportItemServiceHistory,
                  l10n.reportItemInsurance,
                  l10n.reportItemNextYear,
                ].map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 14, color: cs.primary),
                        const SizedBox(width: 8),
                        Text(item, style: tt.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Year selector ──────────────────────────────────────────────────
          Text(
            l10n.selectYear,
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _YearTile(
            year:       _currentYear,
            label:      l10n.currentYearLabel,
            selected:   _selectedYear == _currentYear,
            onTap:      () => setState(() => _selectedYear = _currentYear),
          ),
          const SizedBox(height: 6),
          _YearTile(
            year:       _currentYear - 1,
            label:      l10n.lastYearLabel,
            selected:   _selectedYear == _currentYear - 1,
            onTap:      () => setState(() => _selectedYear = _currentYear - 1),
          ),
          const SizedBox(height: 6),
          _YearTile(
            year:       _currentYear - 2,
            label:      l10n.twoYearsAgoLabel,
            selected:   _selectedYear == _currentYear - 2,
            onTap:      () => setState(() => _selectedYear = _currentYear - 2),
          ),

          const SizedBox(height: 32),

          // ── Error message ──────────────────────────────────────────────────
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: cs.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: cs.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Generate button ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _generateReport,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: Text(
                _loading
                    ? l10n.generatingReport
                    : l10n.generateReport(_selectedYear),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            l10n.reportShareHint,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Year selector tile ────────────────────────────────────────────────────────

class _YearTile extends StatelessWidget {
  final int year;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _YearTile({
    required this.year,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? cs.primaryContainer
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? cs.primary : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0)),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? cs.primary : cs.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  year.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selected ? cs.primary : cs.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
