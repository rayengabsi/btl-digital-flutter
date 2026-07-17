import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/widgets/btl_bottom_nav.dart';

// ─── Transaction model ────────────────────────────────────────────────────────
class _Tx {
  const _Tx({
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.icon,
  });
  final String title;
  final String date;
  final String amount;
  final bool isIncome;
  final IconData icon;
}

// ─── Per-card transaction data ────────────────────────────────────────────────
const _cardTransactions = [
  // Card 1 – First Card
  [
    _Tx(
      title: 'Salary',
      date: 'Today, 08:30 AM',
      amount: '+2,500.00 TND',
      isIncome: true,
      icon: Icons.south_rounded,
    ),
    _Tx(
      title: 'Netflix Subscription',
      date: 'Yesterday, 10:15 PM',
      amount: '-29.99 TND',
      isIncome: false,
      icon: Icons.receipt_long_outlined,
    ),
    _Tx(
      title: 'Carrefour Market',
      date: 'May 17, 2025',
      amount: '-78.60 TND',
      isIncome: false,
      icon: Icons.shopping_cart_outlined,
    ),
    _Tx(
      title: 'Ooredoo Recharge',
      date: 'May 16, 2025',
      amount: '-10.00 TND',
      isIncome: false,
      icon: Icons.phone_android_outlined,
    ),
  ],
  // Card 2 – Second Card
  [
    _Tx(
      title: 'Freelance Payment',
      date: 'Today, 11:00 AM',
      amount: '+1,200.00 TND',
      isIncome: true,
      icon: Icons.south_rounded,
    ),
    _Tx(
      title: 'Spotify Premium',
      date: 'Yesterday, 09:00 AM',
      amount: '-12.99 TND',
      isIncome: false,
      icon: Icons.music_note_outlined,
    ),
    _Tx(
      title: 'Monoprix',
      date: 'May 15, 2025',
      amount: '-54.30 TND',
      isIncome: false,
      icon: Icons.shopping_bag_outlined,
    ),
    _Tx(
      title: 'ATM Withdrawal',
      date: 'May 14, 2025',
      amount: '-200.00 TND',
      isIncome: false,
      icon: Icons.atm_outlined,
    ),
  ],
];

// ─── Quick action model ───────────────────────────────────────────────────────
class _Action {
  const _Action({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

const _quickActions = [
  _Action(icon: Icons.north_east_rounded, label: 'Send'),
  _Action(icon: Icons.south_west_rounded, label: 'Request'),
  _Action(icon: Icons.ac_unit_rounded, label: 'Freeze'),
  _Action(icon: Icons.remove_red_eye_outlined, label: 'View Details'),
];

// ─── Card image assets ────────────────────────────────────────────────────────
const _cardImages = [
  'assets/images/cards/card_first.png',
  'assets/images/cards/card_second.png',
];

// ═══════════════════════════════════════════════════════════════════════════════
// Cards Screen
// ═══════════════════════════════════════════════════════════════════════════════
class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key, this.onNavTap});

  /// When set, nav taps are forwarded to the parent (DashboardScreen).
  final ValueChanged<int>? onNavTap;

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> with TickerProviderStateMixin {
  // Bottom nav – start on Cards tab (index 1)
  int _navIndex = 1;

  // Page controller with viewport fraction so next card peeks in
  late final PageController _pageCtrl;

  // Which card is currently active
  int _activeCard = 0;

  // Fade animation for the transaction list
  late AnimationController _txFadeCtrl;
  late Animation<double> _txFade;

  // Entry animations
  late AnimationController _entryFadeCtrl;
  late Animation<double> _entryFade;
  late AnimationController _entrySlideCtrl;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();

    _pageCtrl = PageController(viewportFraction: 0.88);
    _pageCtrl.addListener(_onPageScroll);

    // Transaction list fade
    _txFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1.0,
    );
    _txFade = CurvedAnimation(parent: _txFadeCtrl, curve: Curves.easeInOut);

    // Entry animations
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

  // Called on every page scroll tick
  void _onPageScroll() {
    final page = _pageCtrl.page ?? 0;
    final newIndex = page.round();
    if (newIndex != _activeCard) {
      _switchCard(newIndex);
    }
  }

  Future<void> _switchCard(int newIndex) async {
    // Fade out
    await _txFadeCtrl.reverse();
    setState(() => _activeCard = newIndex);
    // Fade in
    await _txFadeCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Background ──────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/dashboard_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── Scrollable content ──────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // Header
                          SliverToBoxAdapter(child: _buildHeader(context)),

                          // Card carousel
                          SliverToBoxAdapter(child: _buildCardCarousel()),

                          // Quick actions
                          SliverToBoxAdapter(child: _buildQuickActions()),

                          // Deposit button
                          SliverToBoxAdapter(child: _buildDepositButton()),

                          // Recent transactions
                          SliverToBoxAdapter(child: _buildTransactions()),

                          // Nav clearance
                          const SliverToBoxAdapter(child: SizedBox(height: 112)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Floating bottom nav ─────────────────────────────────────
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

  // ── Header ────────────────────────────────────────────────────────────────
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
              ),
            ],
          ),
          _CircleBtn(
            onTap: () {},
            child: const Icon(Icons.add_rounded, color: AppColors.textPrimary, size: 22),
          ),
        ],
      ),
    );
  }

  // ── Card carousel ─────────────────────────────────────────────────────────
  Widget _buildCardCarousel() {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 4),
      child: SizedBox(
        height: 210,
        child: PageView.builder(
          controller: _pageCtrl,
          itemCount: _cardImages.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _pageCtrl,
              builder: (context, child) {
                double scale = 1.0;
                if (_pageCtrl.position.hasContentDimensions) {
                  final page = _pageCtrl.page ?? 0;
                  final diff = (page - index).abs();
                  // Cards that are not active scale down slightly
                  scale = (1.0 - (diff * 0.06)).clamp(0.90, 1.0);
                }
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    _cardImages[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Quick actions ─────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _quickActions.map((a) => _ActionBtn(action: a)).toList(),
      ),
    );
  }

  // ── Deposit button ────────────────────────────────────────────────────────
  Widget _buildDepositButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: GestureDetector(
        onTap: () {},
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
            style: AppTypography.buttonLarge.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ── Transactions ──────────────────────────────────────────────────────────
  Widget _buildTransactions() {
    final txList = _cardTransactions[_activeCard];

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
              // Section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: AppTypography.h6.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Animated transaction list
              FadeTransition(
                opacity: _txFade,
                child: Column(
                  children: txList.asMap().entries.map((entry) {
                    final i = entry.key;
                    final tx = entry.value;
                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        _TxRow(tx: tx),
                        if (i < txList.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Divider(
                              height: 1,
                              color: AppColors.divider,
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Transaction row ──────────────────────────────────────────────────────────
class _TxRow extends StatelessWidget {
  const _TxRow({required this.tx});
  final _Tx tx;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: tx.isIncome
                ? AppColors.primaryGreen.withValues(alpha: 0.08)
                : AppColors.textSecondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            tx.icon,
            size: 22,
            color: tx.isIncome ? AppColors.primaryGreen : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tx.title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                tx.date,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Text(
          tx.amount,
          style: AppTypography.bodyMedium.copyWith(
            color: tx.isIncome ? AppColors.primaryGreen : const Color(0xFF111827),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ─── Quick action button ──────────────────────────────────────────────────────
class _ActionBtn extends StatefulWidget {
  const _ActionBtn({required this.action});
  final _Action action;

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                widget.action.icon,
                color: AppColors.primaryGreen,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.action.label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
