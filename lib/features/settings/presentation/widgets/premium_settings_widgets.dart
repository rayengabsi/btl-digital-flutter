import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Premium Profile Header
// ═══════════════════════════════════════════════════════════════════════════════
class PremiumProfileHeader extends StatelessWidget {
  const PremiumProfileHeader({
    super.key,
    required this.name,
    required this.initials,
    this.onTap,
  });

  final String name;
  final String initials;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Large circular profile picture
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTypography.h4.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Name and Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: AppTypography.h6.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.primaryGreen,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.primaryGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'BTL Premium',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Arrow
          Icon(
            Icons.chevron_right_rounded,
            color: onTap == null
                ? AppColors.textSecondary.withValues(alpha: 0.3)
                : AppColors.textSecondary,
            size: 24,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      child: content,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Premium Settings Section
// ═══════════════════════════════════════════════════════════════════════════════
class PremiumSettingsSection extends StatelessWidget {
  const PremiumSettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: _buildSeparatedChildren(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSeparatedChildren() {
    final List<Widget> separated = [];
    for (int i = 0; i < children.length; i++) {
      separated.add(children[i]);
      if (i < children.length - 1) {
        separated.add(
          Padding(
            padding: const EdgeInsets.only(left: 64),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.divider.withValues(alpha: 0.5),
            ),
          ),
        );
      }
    }
    return separated;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Premium Settings Tile
// ═══════════════════════════════════════════════════════════════════════════════
class PremiumSettingsTile extends StatefulWidget {
  const PremiumSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  State<PremiumSettingsTile> createState() => _PremiumSettingsTileState();
}

class _PremiumSettingsTileState extends State<PremiumSettingsTile> {
  bool _isHovered = false;

  bool get _disabled => widget.onTap == null;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _disabled
                  ? AppColors.textSecondary.withValues(alpha: 0.1)
                  : _isHovered
                      ? AppColors.primaryGreen.withValues(alpha: 0.12)
                      : AppColors.primaryGreen.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              widget.icon,
              color: _disabled
                  ? AppColors.textSecondary
                  : AppColors.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: _disabled
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (widget.trailing != null)
            widget.trailing!
          else
            Icon(
              Icons.chevron_right_rounded,
              color: _disabled
                  ? AppColors.textSecondary.withValues(alpha: 0.4)
                  : AppColors.textSecondary,
              size: 20,
            ),
        ],
      ),
    );

    if (_disabled) {
      return Opacity(
        opacity: 0.55,
        child: content,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hovering) => setState(() => _isHovered = hovering),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        highlightColor: AppColors.primaryGreen.withValues(alpha: 0.05),
        splashColor: AppColors.primaryGreen.withValues(alpha: 0.1),
        child: content,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Elegant Logout Button
// ═══════════════════════════════════════════════════════════════════════════════
class ElegantLogoutButton extends StatelessWidget {
  const ElegantLogoutButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 48),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          highlightColor: AppColors.primaryRed.withValues(alpha: 0.05),
          splashColor: AppColors.primaryRed.withValues(alpha: 0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              border: Border.all(
                color: AppColors.primaryRed.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: AppColors.primaryRed.withValues(alpha: 0.9),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Log Out',
                  style: AppTypography.buttonLarge.copyWith(
                    color: AppColors.primaryRed.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
