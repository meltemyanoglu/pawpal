import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/pet_provider.dart';

class AccessoryShopScreen extends ConsumerWidget {
  const AccessoryShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petProvider);
    if (pet == null) return const SizedBox.shrink();

    final items = Constants.accessoryPrices.entries.toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8F0), Color(0xFFF4EFFE), Color(0xFFFFF0F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: AppTheme.textDark),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Accessory Shop',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 24),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💰', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '${pet.coins}',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFFFFB800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Equipped indicator
              if (pet.equippedAccessory != null &&
                  pet.equippedAccessory!.isNotEmpty)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Wearing: ${Constants.accessoryNames[pet.equippedAccessory] ?? ''}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () =>
                            ref.read(petProvider.notifier).equipAccessory(null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Remove',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: AppTheme.textMid,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),

              // Shop grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final id = items[index].key;
                    final price = items[index].value;
                    final owned = pet.ownedAccessories.contains(id);
                    final equipped = pet.equippedAccessory == id;
                    final canAfford = pet.coins >= price;

                    return _ShopItemCard(
                      id: id,
                      price: price,
                      owned: owned,
                      equipped: equipped,
                      canAfford: canAfford,
                      index: index,
                      onBuy: () {
                        HapticFeedback.mediumImpact();
                        ref.read(petProvider.notifier).buyAccessory(id, price);
                      },
                      onEquip: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(petProvider.notifier)
                            .equipAccessory(equipped ? null : id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopItemCard extends StatefulWidget {
  final String id;
  final int price;
  final bool owned, equipped, canAfford;
  final int index;
  final VoidCallback onBuy, onEquip;

  const _ShopItemCard({
    required this.id,
    required this.price,
    required this.owned,
    required this.equipped,
    required this.canAfford,
    required this.index,
    required this.onBuy,
    required this.onEquip,
  });

  @override
  State<_ShopItemCard> createState() => _ShopItemCardState();
}

class _ShopItemCardState extends State<_ShopItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _scale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = Constants.accessoryNames[widget.id] ?? widget.id;
    final emoji = Constants.accessoryEmojis[widget.id] ?? '🎁';

    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: widget.equipped
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 42)),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),

            // Action button
            GestureDetector(
              onTap: widget.owned ? widget.onEquip : (widget.canAfford ? widget.onBuy : null),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: widget.owned
                      ? (widget.equipped
                          ? const LinearGradient(
                              colors: [Color(0xFFC3A8F5), Color(0xFF9B7FE8)])
                          : const LinearGradient(
                              colors: [Color(0xFF4CD97B), Color(0xFF38B060)]))
                      : (widget.canAfford
                          ? const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryDark])
                          : const LinearGradient(
                              colors: [Color(0xFFCCCCCC), Color(0xFFAAAAAA)])),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.owned
                        ? (widget.equipped ? 'Wearing' : 'Equip')
                        : '💰 ${widget.price}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
