/// GearTracker Premium paywall screen.
///
/// Shown when a free-tier limit is hit, or when the user taps "Upgrade".
/// Uses [PurchaseService] for RevenueCat operations.
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/purchase_service.dart';
import '../theme/app_theme.dart';

// ─── Colours / tokens ────────────────────────────────────────────────────────

const _kGold        = Color(0xFFD4AF37);
const _kGoldLight   = Color(0xFFFFF8E1);
const _kGoldBorder  = Color(0xFFE0C840);

// ─── Screen ──────────────────────────────────────────────────────────────────

class PaywallScreen extends StatefulWidget {
  /// Optional headline shown above the benefits list (e.g. "Přidej více vybavení").
  final String? contextMessage;

  const PaywallScreen({super.key, this.contextMessage});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final _svc = PurchaseService.instance;

  // ── State ─────────────────────────────────────────────────────────────────
  Offerings? _offerings;
  bool       _loading        = true;
  bool       _purchasing     = false;
  String?    _error;
  int        _selectedIndex  = 1;   // default: yearly (index 1 in _plans)

  // ── Static plan definitions (shown when RC is unavailable / loading) ───────
  static const _plans = [
    _Plan(id: 'monthly',  label: 'Měsíčně',  price: '1,99 EUR', period: '/ měs.',  badge: null,            highlight: false),
    _Plan(id: 'annual',   label: 'Ročně',    price: '12,99 EUR', period: '/ rok',   badge: 'Nejoblíbenější', highlight: true),
    _Plan(id: 'lifetime', label: 'Navždy',   price: '29,90 EUR', period: '',        badge: null,            highlight: false),
  ];

  // Benefits list
  static const _benefits = [
    _Benefit(icon: Icons.backpack_outlined,     title: 'Neomezené vybavení',           subtitle: 'Free: max 5 kusů'),
    _Benefit(icon: Icons.history_rounded,        title: 'Kompletní historie aktivit',   subtitle: 'Free: pouze 90 dní'),
    _Benefit(icon: Icons.cloud_upload_outlined,  title: 'Cloud záloha',                 subtitle: 'Zálohuj data do cloudu'),
    _Benefit(icon: Icons.bar_chart_rounded,      title: 'Pokročilé statistiky',         subtitle: 'Detailní grafy a přehledy'),
    _Benefit(icon: Icons.share_outlined,         title: 'Sdílení s instruktorem',       subtitle: 'Exportuj data instruktorovi'),
  ];

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() { _loading = true; _error = null; });
    try {
      final o = await _svc.getOfferings();
      if (mounted) setState(() { _offerings = o; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the RevenueCat [Package] for [plan], or null if unavailable.
  Package? _packageFor(_Plan plan) {
    final current = _offerings?.current;
    if (current == null) return null;
    return switch (plan.id) {
      'monthly'  => current.monthly,
      'annual'   => current.annual,
      'lifetime' => current.lifetime,
      _          => null,
    };
  }

  /// Returns the display price. Uses RC price string when available,
  /// otherwise falls back to the static string in [_Plan].
  String _displayPrice(_Plan plan) {
    final pkg = _packageFor(plan);
    if (pkg != null) {
      return pkg.storeProduct.priceString;
    }
    return plan.price;
  }

  Future<void> _purchase() async {
    final plan = _plans[_selectedIndex];
    final pkg  = _packageFor(plan);

    // If RevenueCat returned a real package, use it.
    // Otherwise show a dev/test message.
    if (pkg == null) {
      _showSnack('Nákup zatím není dostupný – nakonfiguruj produkt v RevenueCat dashboardu.');
      return;
    }

    setState(() { _purchasing = true; _error = null; });
    try {
      final success = await _svc.purchasePackage(pkg);
      if (mounted) {
        if (success) {
          _showSnack('🎉 Premium aktivováno! Děkujeme za podporu.');
          Navigator.of(context).pop(true);   // return true = premium unlocked
        }
      }
    } on PurchaseException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() { _purchasing = true; _error = null; });
    try {
      final restored = await _svc.restorePurchases();
      if (mounted) {
        if (restored) {
          _showSnack('✅ Nákupy obnoveny!');
          Navigator.of(context).pop(true);
        } else {
          _showSnack('Žádné předchozí nákupy nenalezeny.');
        }
      }
    } on PurchaseException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cs     = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8F6F1),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Scrollable content ─────────────────────────────────────────
            CustomScrollView(
              slivers: [
                // App bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  pinned: false,
                  leading: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  actions: [
                    TextButton(
                      onPressed: _purchasing ? null : _restore,
                      child: const Text('Obnovit nákupy',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Crown + heading ────────────────────────────────
                        const SizedBox(height: 4),
                        const Center(
                          child: Text('👑', style: TextStyle(fontSize: 52)),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'GearTracker Premium',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Bez omezení. Bezpečnost bez kompromisů.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: cs.onSurfaceVariant,
                          ),
                        ),

                        // ── Context message (optional) ─────────────────────
                        if (widget.contextMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _kGoldLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _kGoldBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    color: _kGold, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.contextMessage!,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF5D4A00)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // ── Benefits ──────────────────────────────────────
                        _BenefitsList(benefits: _benefits),

                        const SizedBox(height: 28),

                        // ── Plan selector ─────────────────────────────────
                        ..._plans.asMap().entries.map((e) {
                          final i    = e.key;
                          final plan = e.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _PlanTile(
                              plan:     plan,
                              price:    _displayPrice(plan),
                              selected: _selectedIndex == i,
                              onTap:    () => setState(() => _selectedIndex = i),
                            ),
                          );
                        }),

                        // ── Error ─────────────────────────────────────────
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13, color: cs.error),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ── Buy button ────────────────────────────────────
                        FilledButton(
                          onPressed: _purchasing ? null : _purchase,
                          style: FilledButton.styleFrom(
                            backgroundColor: _kGold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          child: _purchasing
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black),
                                )
                              : Text(
                                  'Získat Premium – ${_displayPrice(_plans[_selectedIndex])}',
                                ),
                        ),

                        const SizedBox(height: 12),

                        // ── Maybe later ───────────────────────────────────
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'Možná později',
                              style: TextStyle(
                                  color: cs.onSurfaceVariant, fontSize: 14),
                            ),
                          ),
                        ),

                        // ── Legal fine print ──────────────────────────────
                        const SizedBox(height: 8),
                        Text(
                          'Předplatné se automaticky obnovuje, pokud ho nezrušíš '
                          'alespoň 24 hodin před koncem období. '
                          'Správa předplatného: Nastavení Google Play.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurfaceVariant.withAlpha(160)),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Loading overlay ────────────────────────────────────────────
            if (_loading)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: const ColoredBox(
                    color: Colors.transparent,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Benefits list ────────────────────────────────────────────────────────────

class _Benefit {
  final IconData icon;
  final String   title;
  final String   subtitle;
  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _BenefitsList extends StatelessWidget {
  final List<_Benefit> benefits;
  const _BenefitsList({required this.benefits});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        children: benefits.map((b) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _kGoldLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(b.icon, color: _kGold, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(b.subtitle,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 20),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Plan tile ────────────────────────────────────────────────────────────────

class _Plan {
  final String  id;
  final String  label;
  final String  price;
  final String  period;
  final String? badge;
  final bool    highlight;
  const _Plan({
    required this.id,
    required this.label,
    required this.price,
    required this.period,
    required this.badge,
    required this.highlight,
  });
}

class _PlanTile extends StatelessWidget {
  final _Plan  plan;
  final String price;
  final bool   selected;
  final VoidCallback onTap;

  const _PlanTile({
    required this.plan,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final borderColor  = selected
        ? _kGold
        : (isDark ? AppColors.darkBorder : AppColors.cardBorder);
    final bgColor = selected
        ? (isDark ? const Color(0xFF2C2500) : _kGoldLight)
        : (isDark ? AppColors.darkCard : Colors.white);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: selected ? 1.8 : 0.7,
          ),
        ),
        child: Row(
          children: [
            // Radio dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _kGold : Colors.grey.shade400,
                  width: selected ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Label
            Expanded(
              child: Text(
                plan.label,
                style: TextStyle(
                  fontWeight:
                      plan.highlight ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),

            // Badge
            if (plan.badge != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kGold,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  plan.badge!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                if (plan.period.isNotEmpty)
                  Text(
                    plan.period,
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Premium gate overlay ─────────────────────────────────────────────────────

/// Wraps [child] with a blur + "Premium" lock badge overlay.
/// Tapping the overlay opens the [PaywallScreen].
///
/// Usage:
/// ```dart
/// PremiumGate(
///   isPremium: _isPremium,
///   contextMessage: 'Odemkni pokročilé grafy',
///   child: MyChartWidget(),
/// )
/// ```
class PremiumGate extends StatelessWidget {
  final bool     isPremium;
  final Widget   child;
  final String?  contextMessage;
  final VoidCallback? onUnlocked;

  const PremiumGate({
    super.key,
    required this.isPremium,
    required this.child,
    this.contextMessage,
    this.onUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    if (isPremium) return child;

    return Stack(
      children: [
        // Blurred child
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: IgnorePointer(child: child),
        ),

        // Lock overlay
        Positioned.fill(
          child: Material(
            color: Colors.black.withAlpha(60),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) =>
                        PaywallScreen(contextMessage: contextMessage),
                  ),
                );
                if (result == true) onUnlocked?.call();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _kGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded,
                            color: Colors.black, size: 16),
                        SizedBox(width: 6),
                        Text('Premium',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Klepni pro odemknutí',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
