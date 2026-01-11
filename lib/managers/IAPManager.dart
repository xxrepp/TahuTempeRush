import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'CurrencyManager.dart';

/// Manages in-app purchases for Beans and Remove Ads
class IAPManager {
  static final IAPManager _instance = IAPManager._internal();
  factory IAPManager() => _instance;
  IAPManager._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  bool _isPremium = false;
  static const String _premiumKey = 'remove_ads_purchased';

  // Product IDs (customize for your app)
  static const String productBeansSmall = 'beans_small_pack';
  static const String productBeansLarge = 'beans_large_pack';
  static const String productRemoveAds = 'remove_ads';

  List<ProductDetails> _products = [];
  bool get isPremium => _isPremium;

  /// Initialize IAP system
  Future<void> init() async {
    // Check if IAP is available
    final bool available = await _iap.isAvailable();
    if (!available) {
      print('In-App Purchases not available');
      return;
    }

    // Load premium status
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print('Purchase error: $error'),
    );

    // Load products
    await _loadProducts();
  }

  /// Load available products from stores
  Future<void> _loadProducts() async {
    const Set<String> productIds = {
      productBeansSmall,
      productBeansLarge,
      productRemoveAds,
    };

    final ProductDetailsResponse response = await _iap.queryProductDetails(productIds);
    
    if (response.error != null) {
      print('Error loading products: ${response.error}');
      return;
    }

    _products = response.productDetails;
    print('Loaded ${_products.length} products');
  }

  /// Handle purchase updates
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Verify and deliver purchase
        await _deliverProduct(purchase);
        
        // Complete purchase
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        print('Purchase error: ${purchase.error}');
      }
    }
  }

  /// Deliver purchased product to user
  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    switch (purchase.productID) {
      case productBeansSmall:
        await CurrencyManager().addBeans(100);
        print('Delivered 100 Beans');
        break;
      case productBeansLarge:
        await CurrencyManager().addBeans(500);
        print('Delivered 500 Beans');
        break;
      case productRemoveAds:
        _isPremium = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_premiumKey, true);
        print('Ads removed - Premium activated');
        break;
    }
  }

  /// Purchase a product
  Future<void> buyProduct(String productId) async {
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found'),
    );

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    
    if (productId == productRemoveAds) {
      // Non-consumable
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      // Consumable (Beans)
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    }
  }

  /// Restore previous purchases (for non-consumables)
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  List<ProductDetails> get products => _products;

  void dispose() {
    _subscription?.cancel();
  }
}
