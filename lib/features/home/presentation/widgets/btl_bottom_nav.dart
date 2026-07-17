import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

// ─── Nav item model ───────────────────────────────────────────────────────────
class _NavItem {
  const _NavItem({
    required this.label,
    required this.iconActive,
    required this.iconInactive,
  });

  final String label;
  final IconData iconActive;
  final IconData iconInactive;
}

const List<_NavItem> _navItems = [
  _NavItem(
    label: 'Home',
    iconActive: Icons.home_rounded,
    iconInactive: Icons.home_outlined,
  ),
  _NavItem(
    label: 'Cards',
    iconActive: Icons.credit_card_rounded,
    iconInactive: Icons.credit_card_outlined,
  ),
  _NavItem(
    label: 'Transfer',
    iconActive: Icons.swap_horiz_rounded,
    iconInactive: Icons.swap_horiz_rounded,
  ),
  _NavItem(
    label: 'Settings',
    iconActive: Icons.settings_rounded,
    iconInactive: Icons.settings_outlined,
  ),
];

// ─── Widget ───────────────────────────────────────────────────────────────────
class BtlBottomNav extends StatelessWidget {
  const BtlBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _navItems.length,
            (i) => _NavButton(
              item: _navItems[i],
              isSelected: i == currentIndex,
              onTap: () => onTap(i),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Individual nav button ────────────────────────────────────────────────────
class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.85,
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
    final color = widget.isSelected ? AppColors.primaryGreen : const Color(0xFF9CA3AF);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  widget.isSelected
                      ? widget.item.iconActive
                      : widget.item.iconInactive,
                  key: ValueKey(widget.isSelected),
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.label,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w400,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: 3,
                width: widget.isSelected ? 20 : 0,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
