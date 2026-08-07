import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../beneficiaries/presentation/pages/beneficiaries_page.dart';
import '../../../home/presentation/widgets/btl_bottom_nav.dart';
import '../../../settings/presentation/widgets/premium_settings_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, this.onNavTap});

  final ValueChanged<int>? onNavTap;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  int _navIndex = 3;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
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

  void _onLogout() {
    ref.read(authControllerProvider.notifier).logout();
    context.goNamed('login');
  }

  void _openBeneficiaries() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BeneficiariesPage()),
    );
  }

  void _goToAccounts() {
    if (widget.onNavTap != null) {
      widget.onNavTap!(1);
    } else {
      setState(() => _navIndex = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    final authState = ref.watch(authControllerProvider);
    final (name, initials) = _identityFrom(authState);

    return Scaffold(
      backgroundColor: Colors.transparent,
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
                    // ── Header ─────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile',
                                style: AppTypography.h3.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage your account and preferences',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          
                          // Notification bell icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Body ───────────────────────────────────────────
                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // 1. Profile Header (Compact Hub)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              child: PremiumProfileHeader(
                                name: name,
                                initials: initials,
                                onTap: () {},
                              ),
                            ),
                          ),

                          // 2. Account Section
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: PremiumSettingsSection(
                                title: 'Account',
                                children: [
                                  PremiumSettingsTile(
                                    icon: Icons.person_outline_rounded,
                                    title: 'Personal Information',
                                    subtitle: 'Update your personal details',
                                    onTap: () {},
                                  ),
                                  PremiumSettingsTile(
                                    icon: Icons.shield_outlined,
                                    title: 'Security',
                                    subtitle: 'Password, biometrics, 2FA',
                                    onTap: () {},
                                  ),
                                  PremiumSettingsTile(
                                    icon: Icons.credit_card_outlined,
                                    title: 'Bank Accounts & Cards',
                                    subtitle: 'Manage your accounts and cards',
                                    onTap: _goToAccounts,
                                  ),
                                  PremiumSettingsTile(
                                    icon: Icons.people_outline_rounded,
                                    title: 'Beneficiaries',
                                    subtitle: 'Manage your saved recipients',
                                    onTap: _openBeneficiaries,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 3. Preferences Section
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: PremiumSettingsSection(
                                title: 'Preferences',
                                children: [
                                  PremiumSettingsTile(
                                    icon: Icons.notifications_none_rounded,
                                    title: 'Notifications',
                                    subtitle: 'Manage alerts and preferences',
                                    trailing: Switch.adaptive(
                                      value: _notificationsEnabled,
                                      activeTrackColor: AppColors.primaryGreen,
                                      onChanged: (val) {
                                        setState(() {
                                          _notificationsEnabled = val;
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _notificationsEnabled = !_notificationsEnabled;
                                      });
                                    },
                                  ),
                                  PremiumSettingsTile(
                                    icon: Icons.dark_mode_outlined,
                                    title: 'Appearance',
                                    subtitle: 'Theme, language, currency',
                                    onTap: () {},
                                  ),
                                  PremiumSettingsTile(
                                    icon: Icons.language_rounded,
                                    title: 'Language',
                                    subtitle: 'English',
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 4. Support Section
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: PremiumSettingsSection(
                                title: 'Support',
                                children: [
                                  PremiumSettingsTile(
                                    icon: Icons.help_outline_rounded,
                                    title: 'Help Center',
                                    subtitle: 'Get help with your account',
                                    onTap: () {},
                                  ),
                                  PremiumSettingsTile(
                                    icon: Icons.headset_mic_outlined,
                                    title: 'Live Chat',
                                    subtitle: 'Speak with our support team',
                                    onTap: () {},
                                  ),
                                  PremiumSettingsTile(
                                    icon: Icons.mail_outline_rounded,
                                    title: 'Contact Us',
                                    subtitle: 'Send us an email or message',
                                    onTap: () {},
                                  ),
                                  PremiumSettingsTile(
                                    icon: Icons.quiz_outlined,
                                    title: 'FAQ',
                                    subtitle: 'Frequently asked questions',
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 5. Legal Section
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: PremiumSettingsSection(
                                title: 'Legal',
                                children: [
                                  PremiumSettingsTile(
                                    icon: Icons.gavel_rounded,
                                    title: 'Privacy Policy',
                                    subtitle: 'How we manage your data',
                                    onTap: () {},
                                  ),
                                  PremiumSettingsTile(
                                    icon: Icons.description_outlined,
                                    title: 'Terms & Conditions',
                                    subtitle: 'Legal agreements and terms',
                                    onTap: () {},
                                  ),
                                  PremiumSettingsTile(
                                    icon: Icons.info_outline_rounded,
                                    title: 'About BTL Digital',
                                    subtitle: 'Version ${AppStrings.appVersion}',
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 6. Logout Button
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: ElegantLogoutButton(
                                onTap: _onLogout,
                              ),
                            ),
                          ),

                          // Clearance for Bottom Nav
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 100),
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

  (String, String) _identityFrom(AuthState auth) {
    final first = auth is AuthAuthenticated ? auth.firstName : '';
    final last = auth is AuthAuthenticated ? auth.lastName : '';
    final email = auth is AuthAuthenticated ? auth.email : '';

    final name = [first, last].where((e) => e.trim().isNotEmpty).join(' ');
    final displayName = name.trim().isNotEmpty ? name : email.trim();
    final usable = displayName.isNotEmpty ? displayName : 'User';

    String initials;
    if (first.isNotEmpty && last.isNotEmpty) {
      initials = '${first[0]}${last[0]}'.toUpperCase();
    } else {
      initials = usable.isNotEmpty ? usable[0].toUpperCase() : 'U';
    }
    return (displayName, initials);
  }
}
