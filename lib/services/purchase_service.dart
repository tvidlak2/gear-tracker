/// RevenueCat in-app purchases / subscription service.
///
/// Usage:
///   await PurchaseService.instance.init();
///   final premium = await PurchaseService.instance.isPremium();
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kApiKeyAndroid = 'appl_test_POxajuhkhtPOQNJYRZlMwZvwlgM';

/// Entitlement identifier configured in RevenueCat dashboard.
const kPremiumEntitlement = 'premium';

// ─── Service ─────────────────────────────────────────────────────────────────

class PurchaseService {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  bool _initialized = false;

  /// Stream that emits [true] whenever the premium status might have changed.
  /// Widgets can listen to this to rebuild when a purchase completes.
  final _premiumController = StreamController<bool>.broadcast();
  Stream<bool> get premiumStream => _premiumController.stream;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) { _initialized = true; return; }

    try {
      await Purchases.setLogLevel(LogLevel.warn);

      final config = PurchasesConfiguration(_kApiKeyAndroid);
      await Purchases.configure(config);

      // Forward CustomerInfo updates to our stream
      Purchases.addCustomerInfoUpdateListener((info) {
        _premiumController.add(_isActive(info));
      });

      _initialized = true;
      debugPrint('PurchaseService: initialized');
    } catch (e) {
      debugPrint('PurchaseService init failed (non-fatal): $e');
    }
  }

  // ── Premium status ────────────────────────────────────────────────────────

  /// Returns [true] if the user has an active Premium entitlement.
  /// Never throws — returns false on any error so the app keeps working.
  Future<bool> isPremium() async {
    if (kIsWeb || !_initialized) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return _isActive(info);
    } catch (e) {
      debugPrint('PurchaseService.isPremium error: $e');
      return false;
    }
  }

  static bool _isActive(CustomerInfo info) =>
      info.entitlements.active.containsKey(kPremiumEntitlement);

  // ── Offerings ─────────────────────────────────────────────────────────────

  /// Returns the current offerings from RevenueCat.
  /// Returns null if unavailable (no network, not initialized, etc.).
  Future<Offerings?> getOfferings() async {
    if (kIsWeb || !_initialized) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('PurchaseService.getOfferings error: $e');
      return null;
    }
  }

  // ── Purchase ──────────────────────────────────────────────────────────────

  /// Initiates a purchase for [package].
  /// Returns [true] on success, [false] if the user cancelled.
  /// Throws a [PurchaseException] with a user-friendly message on error.
  Future<bool> purchasePackage(Package package) async {
    if (kIsWeb || !_initialized) return false;
    try {
      final result = await Purchases.purchasePackage(package);
      final active = _isActive(result.customerInfo);
      _premiumController.add(active);
      return active;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) return false;
      throw PurchaseException(_errorMessage(code));
    } catch (e) {
      throw PurchaseException('Nákup se nezdařil: $e');
    }
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  /// Restores previous purchases.
  /// Returns [true] if premium was restored.
  Future<bool> restorePurchases() async {
    if (kIsWeb || !_initialized) return false;
    try {
      final info = await Purchases.restorePurchases();
      final active = _isActive(info);
      _premiumController.add(active);
      return active;
    } catch (e) {
      debugPrint('PurchaseService.restorePurchases error: $e');
      throw PurchaseException('Obnovení nákupů se nezdařilo: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _errorMessage(PurchasesErrorCode code) {
    return switch (code) {
      PurchasesErrorCode.purchaseNotAllowedError =>
          'Nákupy jsou na tomto zařízení zakázány.',
      PurchasesErrorCode.purchaseInvalidError =>
          'Neplatný nákup. Zkus to znovu.',
      PurchasesErrorCode.networkError =>
          'Chyba sítě. Zkontroluj připojení a zkus znovu.',
      PurchasesErrorCode.insufficientPermissionsError =>
          'Nedostatečná oprávnění pro nákup.',
      _ => 'Nákup se nezdařil (${code.name}). Zkus to znovu.',
    };
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
