import 'package:flutter/material.dart';
import '../game/TahuTempeGame.dart';
import '../managers/CurrencyManager.dart';
import '../managers/IAPManager.dart';
import '../game/components/Player.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shop overlay for skins and bean purchases
class ShopMenu extends StatefulWidget {
  final TahuTempeGame game;

  const ShopMenu({super.key, required this.game});

  @override
  State<ShopMenu> createState() => _ShopMenuState();
}

class _ShopMenuState extends State<ShopMenu> {
  final List<int> skinPrices = [0, 50, 100, 150, 200]; // Beans required
  List<bool> ownedSkins = [true, false, false, false, false];
  int currentBeans = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load owned skins
    final prefs = await SharedPreferences.getInstance();
    final owned = prefs.getStringList('owned_skins') ?? ['0'];
    
    setState(() {
      for (int i = 0; i < ownedSkins.length; i++) {
        ownedSkins[i] = owned.contains(i.toString());
      }
      currentBeans = CurrencyManager().balance;
    });
  }

  Future<void> _buySkin(int index) async {
    if (ownedSkins[index]) {
      // Already owned, just equip
      widget.game.player.setSkin(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Skin ${index + 1} equipped!')),
      );
      return;
    }

    // Check if can afford
    final price = skinPrices[index];
    final success = await CurrencyManager().spendBeans(price);

    if (success) {
      // Mark as owned
      ownedSkins[index] = true;
      final prefs = await SharedPreferences.getInstance();
      final owned = List<String>.generate(
        ownedSkins.length,
        (i) => ownedSkins[i] ? i.toString() : '',
      ).where((s) => s.isNotEmpty).toList();
      await prefs.setStringList('owned_skins', owned);

      // Equip skin
      widget.game.player.setSkin(index);

      setState(() {
        currentBeans = CurrencyManager().balance;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchased and equipped Skin ${index + 1}!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough Beans!')),
        );
      }
    }
  }

  void _buyBeans(String productId) async {
    try {
      await IAPManager().buyProduct(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase initiated...')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      widget.game.overlays.remove('Shop');
                      widget.game.overlays.add('MainMenu');
                    },
                  ),
                  const Text(
                    'SHOP',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.brown,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$currentBeans',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Skins Section
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Player Skins',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Skin Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: Player.skinColors.length,
                    itemBuilder: (context, index) {
                      return _buildSkinCard(index);
                    },
                  ),

                  const SizedBox(height: 40),

                  // Bean Packs Section
                  const Text(
                    'Buy Beans',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildBeanPack('Small Pack', '100 Beans', IAPManager.productBeansSmall),
                  const SizedBox(height: 12),
                  _buildBeanPack('Large Pack', '500 Beans', IAPManager.productBeansLarge),
                  
                  const SizedBox(height: 40),

                  // Remove Ads
                  _buildRemoveAdsButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinCard(int index) {
    final owned = ownedSkins[index];
    final price = skinPrices[index];

    return GestureDetector(
      onTap: () => _buySkin(index),
      child: Container(
        decoration: BoxDecoration(
          color: Player.skinColors[index].withOpacity(0.3),
          border: Border.all(
            color: owned ? Colors.green : Colors.white54,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Player.skinColors[index],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              owned ? 'OWNED' : '$price Beans',
              style: TextStyle(
                color: owned ? Colors.green : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeanPack(String title, String amount, String productId) {
    return ElevatedButton(
      onPressed: () => _buyBeans(productId),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown,
        padding: const EdgeInsets.all(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveAdsButton() {
    final isPremium = IAPManager().isPremium;

    return ElevatedButton(
      onPressed: isPremium
          ? null
          : () => _buyBeans(IAPManager.productRemoveAds),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPremium ? Colors.grey : Colors.purple,
        padding: const EdgeInsets.all(16),
      ),
      child: Text(
        isPremium ? 'ADS REMOVED ✓' : 'Remove Ads',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
