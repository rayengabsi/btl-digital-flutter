import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/widgets/btl_bottom_nav.dart';
import '../../data/models/account_transaction_model.dart';
import '../../data/models/customer_account_model.dart';
import '../providers/accounts_provider.dart';


// ─── Card image assets ────────────────────────────────────────────────────────
const _cardImages = [
  'assets/images/Cards/card_first.png',
  'assets/images/Cards/card_second.png',
];

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

  late AnimationController _txFadeCtrl;
  late Animation<double> _txFade;

  late AnimationController _entryFadeCtrl;
  late Animation<double> _entryFade;
  late AnimationController _entrySlideCtrl;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();

    _pageCtrl = PageController(viewportFraction: 0.80);
    _pageCtrl.addListener(_onPageScroll);

    _txFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1.0,
    );
    _txFade = CurvedAnimation(parent: _txFadeCtrl, curve: Curves.easeInOut);

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
    _txFadeCtrl.dispose();
    _entryFadeCtrl.dispose();
    _entrySlideCtrl.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    final page = _pageCtrl.page ?? 0;
    final newIndex = page.round();
    if (newIndex != _activeCardIndex) {
      _switchCard(newIndex);
    }
  }

  Future<void> _switchCard(int newIndex) async {
    await _txFadeCtrl.reverse();
    setState(() => _activeCardIndex = newIndex);
    await _txFadeCtrl.forward();
  }

  void _fetchTransactionsForAccount(CustomerAccount account) {
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 365));
    final fromStr =
        "${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}";
    final toStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    ref.read(transactionSearchNotifierProvider.notifier).startSearch(
          iban: account.iban,
          fromDate: fromStr,
          toDate: toStr,
        );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final accountsAsync = ref.watch(customerAccountsProvider);

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
                      child: accountsAsync.when(
                        data: (accounts) {
                          if (accounts.isNotEmpty &&
                              _activeCardIndex < accounts.length) {
                            final currentIban = accounts[_activeCardIndex].iban;
                            final currentTxState =
                                ref.watch(transactionSearchNotifierProvider);

                            if (currentTxState.iban != currentIban &&
                                !currentTxState.isLoading) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _fetchTransactionsForAccount(accounts[_activeCardIndex]);
                              });
                            }
                          }

                          return CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(child: _buildHeader(context)),
                              SliverToBoxAdapter(
                                child: _buildCardCarousel(accounts),
                              ),
                              SliverToBoxAdapter(
                                child: _buildTransactionsSection(accounts),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 112),
                              ),
                            ],
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryGreen),
                        ),
                        error: (err, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    size: 48, color: AppColors.primaryRed),
                                const SizedBox(height: 12),
                                Text(
                                  'Unable to load customer accounts',
                                  style: AppTypography.h3,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => ref.refresh(customerAccountsProvider),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Accounts & Cards',
                style: AppTypography.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Live accounts and transactions',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          _CircleBtn(
            onTap: () => ref.refresh(customerAccountsProvider),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardCarousel(List<CustomerAccount> accounts) {
    final count = accounts.isEmpty ? 1 : accounts.length;

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: SizedBox(
        height: 220,
        child: PageView.builder(
          controller: _pageCtrl,
          itemCount: count,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final account = accounts.isNotEmpty ? accounts[index] : null;
            final cardImg = _cardImages[index % _cardImages.length];

            return AnimatedBuilder(
              animation: _pageCtrl,
              builder: (context, child) {
                double scale = 1.0;
                if (_pageCtrl.position.hasContentDimensions) {
                  final page = _pageCtrl.page ?? 0.0;
                  final diff = (page - index).abs().clamp(0.0, 1.0);
                  scale = 1.0 - (diff * 0.04);
                }
                return Transform.scale(scale: scale, child: child);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(cardImg, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    ),
                    if (account != null)
                      Positioned(
                        left: 20,
                        top: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  account.productName,
                                  style: AppTypography.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    account.currencyId,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Balance',
                                  style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  account.availableBalance != null
                                      ? '${account.currencyId} ${account.availableBalance!.toStringAsFixed(3)}'
                                      : 'N/A',
                                  style: AppTypography.h2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              account.iban,
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white70,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(List<CustomerAccount> accounts) {
    final txState = ref.watch(transactionSearchNotifierProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Statement',
                    style: AppTypography.h6.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  if (txState.isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (txState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 18,
                            color: AppColors.primaryRed,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              txState.errorMessage!,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primaryRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref
                            .read(transactionSearchNotifierProvider.notifier)
                            .loadNextPage(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (txState.transactions.isEmpty && !txState.isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No transactions found for this period.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                FadeTransition(
                  opacity: _txFade,
                  child: Column(
                    children: [
                      ...txState.transactions.asMap().entries.map((entry) {
                        final i = entry.key;
                        final tx = entry.value;
                        return Column(
                          children: [
                            _RealTxRow(tx: tx),
                            if (i < txState.transactions.length - 1)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1, color: AppColors.divider),
                              ),
                          ],
                        );
                      }),
                      if (txState.transactions.length < txState.totalSize)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextButton(
                            onPressed: () {
                              ref
                                  .read(transactionSearchNotifierProvider.notifier)
                                  .loadNextPage();
                            },
                            child: const Text('Load More Transactions'),
                          ),
                        ),
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

class _RealTxRow extends StatelessWidget {
  const _RealTxRow({required this.tx});

  final AccountTransaction tx;

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.creditAmount != null && tx.creditAmount! > 0;
    final amountText = isCredit
        ? '+${tx.creditAmount!.toStringAsFixed(3)}'
        : tx.debitAmount != null
            ? '-${tx.debitAmount!.toStringAsFixed(3)}'
            : '0.000';

    final title = tx.narratives.isNotEmpty ? tx.narratives.first : tx.transactionCode;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isCredit
                ? AppColors.primaryGreen.withValues(alpha: 0.08)
                : AppColors.textSecondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
            size: 22,
            color: isCredit ? AppColors.primaryGreen : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '${tx.bookingDate} • ${tx.transactionReference}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Text(
          amountText,
          style: AppTypography.bodyMedium.copyWith(
            color: isCredit ? AppColors.primaryGreen : const Color(0xFF111827),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

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
