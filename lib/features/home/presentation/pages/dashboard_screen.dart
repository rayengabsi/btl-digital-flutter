import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../accounts/presentation/pages/accounts_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../transfers/presentation/pages/transfers_page.dart';
import '../widgets/btl_bottom_nav.dart';
import '../widgets/btl_drawer.dart';
import '../widgets/transactions_card.dart';
import '../widgets/wallet_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _navIndex = 0;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // Entry fade
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Entry slide-up
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // When a non-Home tab is selected, delegate fully to that screen
    // (which carries its own background + bottom nav).
    if (_navIndex == 1) {
      return AccountsPage(onNavTap: (i) => setState(() => _navIndex = i));
    }

    if (_navIndex == 2) {
      return TransfersPage(onNavTap: (i) => setState(() => _navIndex = i));
    }

    if (_navIndex == 3) {
      return ProfilePage(onNavTap: (i) => setState(() => _navIndex = i));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: BtlDrawer(
        onProfileTap: () => setState(() => _navIndex = 3),
      ),
      body: Stack(
        children: [
          // ── Background image ────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/dashboard_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── Scrollable content ──────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // Header
                          SliverToBoxAdapter(
                            child: _DashboardHeader(),
                          ),

                          // Wallet card
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: const WalletCard(),
                            ),
                          ),

                          // Gap
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 24),
                          ),

                          // Transactions card
                          const SliverToBoxAdapter(
                            child: TransactionsCard(),
                          ),

                          // Bottom spacing so last card clears the nav bar
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 112),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Floating bottom navigation ──────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BtlBottomNav(
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu button
          Builder(
            builder: (ctx) => _CircleButton(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: const Icon(
                Icons.menu_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),

          // Notification button with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              _CircleButton(
                onTap: () {},
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Reusable circle button ───────────────────────────────────────────────────
class _CircleButton extends StatefulWidget {
  const _CircleButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

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
    _scale = _ctrl;
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
        scale: _scale,
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
