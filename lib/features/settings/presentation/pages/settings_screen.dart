import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/widgets/btl_bottom_nav.dart';
import '../widgets/premium_settings_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.onNavTap});

  final ValueChanged<int>? onNavTap;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  int _navIndex = 3;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  // Toggle state demo for Notifications switch
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

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
                                'Settings',
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
                          // 1. Profile Header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              child: PremiumProfileHeader(
                                name: 'Mohamed Ashraf Kadri',
                                initials: 'MA',
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
                                    onTap: () {},
                                  ),
                                  PremiumSettingsTile(
                                    icon: Icons.people_outline_rounded,
                                    title: 'Beneficiaries',
                                    subtitle: 'Manage your saved recipients',
                                    onTap: () {},
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
                                    subtitle: 'Version 1.0.0',
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
                                onTap: () {},
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
}
