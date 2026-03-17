import 'package:purchases_flutter/purchases_flutter.dart';

enum PurchaseResult { success, cancelled, error }

class SubscriptionService {
  static final instance = SubscriptionService._();
  SubscriptionService._();

  bool _isPro = false;
  bool get isPro => _isPro;

  DateTime? _proExpiresAt;
  DateTime? get proExpiresAt => _proExpiresAt;

  static const String _monthlyProductId = 'rentmate_pro_monthly';
  static const String _annualProductId = 'rentmate_pro_annual';
  static const String _taxReportProductId = 'rentmate_tax_report_onetime';

  static const String _entitlementId = 'pro';

  Future<void> initialize(String userId) async {
    final apiKey = const String.fromEnvironment(
      'REVENUECAT_API_KEY',
      defaultValue: '',
    );

    if (apiKey.isEmpty) {
      // RevenueCat not configured — default to free tier
      _isPro = false;
      return;
    }

    final configuration = PurchasesConfiguration(apiKey)..appUserID = userId;
    await Purchases.configure(configuration);
    await checkEntitlements();
  }

  Future<void> checkEntitlements() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[_entitlementId];
      _isPro = entitlement?.isActive ?? false;

      if (_isPro && entitlement?.expirationDate != null) {
        _proExpiresAt = DateTime.tryParse(entitlement!.expirationDate!);
      } else {
        _proExpiresAt = null;
      }
    } catch (_) {
      // On error, keep current state
    }
  }

  Future<PurchaseResult> purchaseMonthly() async {
    return _purchase(_monthlyProductId);
  }

  Future<PurchaseResult> purchaseAnnual() async {
    return _purchase(_annualProductId);
  }

  Future<PurchaseResult> purchaseOneTimeTaxReport() async {
    return _purchase(_taxReportProductId);
  }

  Future<PurchaseResult> _purchase(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final packages = offerings.current?.availablePackages ?? [];

      StoreProduct? product;
      for (final pkg in packages) {
        if (pkg.storeProduct.identifier == productId) {
          product = pkg.storeProduct;
          break;
        }
      }

      if (product == null) {
        return PurchaseResult.error;
      }

      await Purchases.purchaseStoreProduct(product);
      await checkEntitlements();
      return PurchaseResult.success;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled;
      }
      return PurchaseResult.error;
    } catch (_) {
      return PurchaseResult.error;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
      await checkEntitlements();
    } catch (_) {
      // Silently fail
    }
  }
}
