import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/utils/amount_formatter.dart';
import '../../../home/presentation/widgets/btl_bottom_nav.dart';
import '../../data/models/account_transaction_model.dart';
import '../../data/models/payment_card_model.dart';
import '../providers/cards_providers.dart';
import '../widgets/bank_card.dart';
import '../widgets/card_details_sheet.dart';

class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key, this.onNavTap});

  final ValueChanged<int>? onNavTap;

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen>
    with TickerProviderStateMixin {
  int _navIndex = 1;
  late final PageController _pageCtrl;
  int _activeCardIndex = 0;

  late AnimationController _entryFadeCtrl;
  late Animation<double> _entryFade;
  late AnimationController _entrySlideCtrl;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();

    _pageCtrl = PageController(viewportFraction: 0.80);
    _pageCtrl.addListener(_onPageScroll);

    _entryFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entryFade = CurvedAnimation(parent: _entryFadeCtrl, curve: Curves.easeOut);

    _entrySlideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrySlideCtrl, curve: Curves.easeOut));

    _entryFadeCtrl.forward();
    _entrySlideCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.removeListener(_onPageScroll);
    _pageCtrl.dispose();
    _entryFadeCtrl.dispose();
    _entrySlideCtrl.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    final page = _pageCtrl.page ?? 0;
    final newIndex = page.round();
    if (newIndex != _activeCardIndex) {
      setState(() => _activeCardIndex = newIndex);
    }
  }

  void _showDemoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onFreezeAction(PaymentCard card) async {
    final frozen = ref.read(frozenCardsProvider);
    if (frozen.contains(card.id)) {
      toggleFrozenCard(ref, card.id);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Freeze card?'),
        content: const Text(
          'This is a demo/static card. Freezing only updates the local '
          'status — no bank action is performed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Freeze'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      toggleFrozenCard(ref, card.id);
    }
  }

  void _openDetails(PaymentCard card) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CardDetailsSheet(card: card),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final cardsAsync = ref.watch(cardsProvider);
    final frozenIds = ref.watch(frozenCardsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/dashboard_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Column(
                  children: [
                    Expanded(
                      child: cardsAsync.when(
                        data: (cards) => CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(child: _buildHeader(context)),
                            SliverToBoxAdapter(
                              child: _buildCardCarousel(
                                cards,
                                frozenIds,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: _buildQuickActions(cards, frozenIds),
                            ),
                            SliverToBoxAdapter(
                              child: _buildDepositButton(),
                            ),
                            SliverToBoxAdapter(
                              child: _buildTransactionsSection(),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 112),
                            ),
                          ],
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        error: (err, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 48,
                                  color: AppColors.primaryRed,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Unable to load cards',
                                  style: AppTypography.h3,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () =>
                                      ref.refresh(cardsProvider),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BtlBottomNav(
              currentIndex: _navIndex,
              onTap: (i) {
                if (widget.onNavTap != null) {
                  widget.onNavTap!(i);
                } else {
                  setState(() => _navIndex = i);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Cards',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your cards and accounts',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _CircleBtn(
            onTap: () {
              _showDemoMessage('Adding a new card is not available in the '
                  'demo version yet.');
            },
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardCarousel(List<PaymentCard> cards, Set<String> frozenIds) {
    final count = cards.isEmpty ? 1 : cards.length;

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: SizedBox(
        height: 234,
        child: PageView.builder(
          controller: _pageCtrl,
          itemCount: count,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final card = cards.isNotEmpty ? cards[index] : null;

            return AnimatedBuilder(
              animation: _pageCtrl,
              builder: (context, child) {
                double scale = 1.0;
                if (_pageCtrl.position.hasContentDimensions) {
                  final page = _pageCtrl.page ?? 0.0;
                  final diff = (page - index).abs().clamp(0.0, 1.0);
                  scale = 1.0 - (diff * 0.045);
                }
                return Transform.scale(scale: scale, child: child);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: BankCard(
                  card: card ??
                      const PaymentCard(
                        id: 'CARD-0000',
                        bankName: 'BTL Bank',
                        cardType: 'VISA',
                        cardHolder: '',
                        maskedNumber: '',
                        fullNumber: '',
                        expiry: '',
                        balance: 0,
                        imagePath: 'assets/images/Cards/card_first.png',
                      ),
                  isFrozen: card != null && frozenIds.contains(card.id),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActions(List<PaymentCard> cards, Set<String> frozenIds) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }
    final active = cards[_activeCardIndex.clamp(0, cards.length - 1)];
    final activeFrozen = frozenIds.contains(active.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          _QuickAction(
            icon: Icons.north_east_rounded,
            label: 'Send',
            onTap: () => _showDemoMessage(
                'Send is not connected to the backend yet.'),
          ),
          _QuickAction(
            icon: Icons.south_west_rounded,
            label: 'Request',
            onTap: () => _showDemoMessage(
                'Request is not connected to the backend yet.'),
          ),
          _QuickAction(
            icon: Icons.ac_unit_rounded,
            label: activeFrozen ? 'Unfreeze' : 'Freeze',
            onTap: () => _onFreezeAction(active),
          ),
          _QuickAction(
            icon: Icons.visibility_outlined,
            label: 'View Details',
            onTap: () => _openDetails(active),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: GestureDetector(
        onTap: () => _showDemoMessage(
            'Deposit is not connected to the backend yet.'),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            'Deposit',
            style: AppTypography.buttonLarge.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsSection() {
    final txAsync = ref.watch(cardTransactionsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent Transactions',
                      style: AppTypography.h6.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.tune_rounded,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              txAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Unable to load transactions.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                data: (transactions) => Column(
                  children: [
                    for (var i = 0; i < transactions.length; i++) ...[
                      const SizedBox(height: 4),
                      _TxRow(transaction: transactions[i]),
                      if (i < transactions.length - 1) ...[
                        const SizedBox(height: 12),
                        Divider(height: 1, color: AppColors.divider),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Quick action ─────────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppColors.primaryGreen, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Transaction row ──────────────────────────────────────────────────────────
class _TxRow extends StatelessWidget {
  const _TxRow({required this.transaction});

  final AccountTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit =
        transaction.creditAmount != null && transaction.creditAmount! > 0;
    final rawAmount = isCredit
        ? (transaction.creditAmount ?? 0.0)
        : (transaction.debitAmount ?? 0.0);
    final sign = isCredit ? '+' : '-';
    final amountText = '$sign${formatAmountWithComma(rawAmount)} TND';
    final title = transaction.narratives.isNotEmpty
        ? transaction.narratives.first
        : transaction.transactionCode;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _iconFor(transaction),
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                transaction.bookingDate,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          amountText,
          style: AppTypography.bodyMedium.copyWith(
            color: isCredit ? AppColors.primaryGreen : AppColors.primaryRed,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

IconData _iconFor(AccountTransaction transaction) {
  final isCredit =
      transaction.creditAmount != null && transaction.creditAmount! > 0;
  switch (transaction.iconName) {
    case 'salary':
      return Icons.south_west_rounded;
    case 'receipt':
      return Icons.receipt_long_rounded;
    case 'shopping':
      return Icons.shopping_cart_rounded;
    case 'mobile':
      return Icons.phone_android_rounded;
    default:
      return isCredit ? Icons.south_west_rounded : Icons.north_east_rounded;
  }
}

// ─── Reusable circle button ───────────────────────────────────────────────────
class _CircleBtn extends StatefulWidget {
  const _CircleBtn({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_CircleBtn> createState() => _CircleBtnState();
}

class _CircleBtnState extends State<_CircleBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}