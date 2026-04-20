/// Google Play Billing in-app purchase service.
///
/// Usage:
///   await PurchaseService.instance.init();
///   final premium = await PurchaseService.instance.isPremium();
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Product IDs ─────────────────────────────────────────────────────────────

const kProductMonthly  = 'gear_tracker_monthly';
const kProductAnnual   = 'gear_tracker_annual';
const kProductLifetime = 'gear_tracker_lifetime';

const _kProductIds = <String>{kProductMonthly, kProductAnnual, kProductLifetime};
const _kPremiumKey = 'is_premium';

// ─── Service ─────────────────────────────────────────────────────────────────

class PurchaseService {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  StreamSubscription<List<PurchaseDetails>>? _subscription; // cancelled in dispose()
  bool _initialized = false;

  /// Completer resolved by the purchase stream for the in-flight operation.
  Completer<bool>? _purchaseCompleter;

  /// Emits [true] whenever premium status changes (purchase / restore).
  final _premiumController = StreamController<bool>.broadcast();
  Stream<bool> get premiumStream => _premiumController.stream;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) { _initialized = true; return; }

    try {
      final available = await InAppPurchase.instance.isAvailable();
      if (!available) {
        debugPrint('PurchaseService: Store not available');
        _initialized = true;
        return;
      }

      _subscription = InAppPurchase.instance.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (Object e) => debugPrint('PurchaseService stream error: $e'),
      );

      _initialized = true;
      debugPrint('PurchaseService: initialized');
    } catch (e) {
      debugPrint('PurchaseService init failed (non-fatal): $e');
    }
  }

  /// Call when the app is shutting down (optional – service is a singleton).
  void dispose() {
    _subscription?.cancel();
    _premiumController.close();
  }

  // ── Purchase stream handler ───────────────────────────────────────────────

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _setPremium(true);
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
          _resolvePurchase(true);

        case PurchaseStatus.error:
          final msg = purchase.error?.message ?? 'Nákup se nezdařil.';
          debugPrint('PurchaseService error: $msg');
          final c = _purchaseCompleter;
          _purchaseCompleter = null;
          if (c != null && !c.isCompleted) {
            c.completeError(PurchaseException(msg));
          }

        case PurchaseStatus.canceled:
          _resolvePurchase(false);

        case PurchaseStatus.pending:
          break; // waiting – nothing to do
      }
    }
  }

  void _resolvePurchase(bool success) {
    final c = _purchaseCompleter;
    _purchaseCompleter = null;
    if (c != null && !c.isCompleted) c.complete(success);
  }

  // ── Premium status ────────────────────────────────────────────────────────

  /// Returns [true] if the user has an active Premium entitlement.
  /// Reads from SharedPreferences — fast, no network call.
  Future<bool> isPremium() async {
    if (kIsWeb) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPremiumKey) ?? false;
  }

  Future<void> _setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPremiumKey, value);
    _premiumController.add(value);
  }

  // ── Products ──────────────────────────────────────────────────────────────

  /// Queries product details from Google Play.
  /// Returns an empty list if unavailable (no network, sandbox, etc.).
  Future<List<ProductDetails>> getProducts() async {
    if (kIsWeb || !_initialized) return const [];
    try {
      final response = await InAppPurchase.instance
          .queryProductDetails(_kProductIds);
      if (response.error != null) {
        debugPrint('PurchaseService.getProducts error: ${response.error}');
      }
      return response.productDetails;
    } catch (e) {
      debugPrint('PurchaseService.getProducts error: $e');
      return const [];
    }
  }

  // ── Purchase ──────────────────────────────────────────────────────────────

  /// Initiates a purchase for [product].
  /// Returns [true] on success, [false] if the user cancelled.
  /// Throws [PurchaseException] with a user-friendly message on error.
  Future<bool> purchaseProduct(ProductDetails product) async {
    if (kIsWeb || !_initialized) return false;
    _purchaseCompleter = Completer<bool>();
    try {
      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      return await _purchaseCompleter!.future;
    } catch (e) {
      _purchaseCompleter = null;
      throw PurchaseException('Nákup se nezdařil: $e');
    }
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  /// Restores previous purchases.
  /// Returns [true] if premium was restored.
  Future<bool> restorePurchases() async {
    if (kIsWeb || !_initialized) return false;
    _purchaseCompleter = Completer<bool>();
    try {
      await InAppPurchase.instance.restorePurchases();
      // Restored events arrive asynchronously via purchaseStream.
      // Wait up to 6 s; if nothing arrives, no active purchases exist.
      return await _purchaseCompleter!.future
          .timeout(const Duration(seconds: 6), onTimeout: () => false);
    } catch (e) {
      debugPrint('PurchaseService.restorePurchases error: $e');
      throw PurchaseException('Obnovení nákupů se nezdařilo: $e');
    } finally {
      _purchaseCompleter = null;
    }
  }
}

// ─── Exception ───────────────────────────────────────────────────────────────

class PurchaseException implements Exception {
  final String message;
  const PurchaseException(this.message);
  @override String toString() => message;
}

// ─── Free limits ─────────────────────────────────────────────────────────────

/// Free tier constraints. Change here to adjust limits app-wide.
abstract final class FreeLimit {
  static const int  maxGear            = 5;
  static const int  activityHistoryDays = 90;
}
