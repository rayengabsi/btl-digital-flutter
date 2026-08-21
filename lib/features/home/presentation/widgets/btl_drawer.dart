import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';

class BtlDrawer extends ConsumerWidget {
  const BtlDrawer({super.key, this.onProfileTap});

  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final (name, initials) = _identityFrom(authState);

    return Drawer(
      backgroundColor: AppColors.white,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header (Compact Profile Section) ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: _DrawerProfileHeader(
                name: name,
                initials: initials,
                onTap: () {
                  Navigator.of(context).pop();
                  if (onProfileTap != null) onProfileTap!();
                },
              ),
            ),

            // ── Scrollable Menu ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // MAIN MENU
                    _DrawerSectionHeader(title: 'MAIN MENU'),
                    _DrawerMenuItem(
                      icon: Icons.grid_view_rounded,
                      title: 'Dashboard',
                      onTap: () => Navigator.of(context).pop(),
                    ),

                    const SizedBox(height: 20),

                    // SERVICES
                    _DrawerSectionHeader(title: 'SERVICES'),
                    _DrawerMenuItem(
                      icon: Icons.currency_exchange_rounded,
                      title: 'Currency Exchange',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/currencies');
                      },
                    ),

                    const SizedBox(height: 20),

                    // MORE
                    _DrawerSectionHeader(title: 'MORE'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.primaryGreen,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'App Version',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppStrings.appVersion,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Log Out
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        ref.read(authControllerProvider.notifier).logout();
                        context.goNamed('login');
                      },
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                          border: Border.all(
                            color: AppColors.primaryRed.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: AppColors.primaryRed.withValues(alpha: 0.9),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Log Out',
                              style: AppTypography.buttonMedium.copyWith(
                                color: AppColors.primaryRed.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.primaryRed.withValues(alpha: 0.6),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Identity helpers ────────────────────────────────────────────────────────
(String, String) _identityFrom(AuthState auth) {
  final first = auth is AuthAuthenticated ? auth.firstName : '';
  final last = auth is AuthAuthenticated ? auth.lastName : '';
  final email = auth is AuthAuthenticated ? auth.email : '';

  final name = [first, last].where((e) => e.trim().isNotEmpty).join(' ');
  final displayName = name.trim().isNotEmpty ? name : email.trim();

  String initials;
  if (first.isNotEmpty && last.isNotEmpty) {
    initials = '${first[0]}${last[0]}'.toUpperCase();
  } else {
    initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
  }
  return (displayName, initials);
}

// ─── Compact Header Widget ───────────────────────────────────────────────────
class _DrawerProfileHeader extends StatelessWidget {
  const _DrawerProfileHeader({
    required this.name,
    required this.initials,
    required this.onTap,
  });

  final String name;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTypography.h5.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name + Badge + View Profile
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.primaryGreen,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.primaryGreen,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'BTL Premium',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View profile',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────
class _DrawerSectionHeader extends StatelessWidget {
  const _DrawerSectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ─── Menu Item ───────────────────────────────────────────────────────────────
class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}