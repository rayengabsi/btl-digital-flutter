import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class TransferHeader extends StatelessWidget {
  const TransferHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (onBack != null) {
      children.add(
        _CircleIconBtn(icon: Icons.arrow_back_rounded, onTap: onBack!),
      );
      children.add(const SizedBox(width: 12));
    }
    children.add(
      Expanded(
        child: Text(
          title,
          style: AppTypography.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
    if (trailing != null) {
      children.add(trailing!);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(children: children),
    );
  }
}

class _CircleIconBtn extends StatefulWidget {
  const _CircleIconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_CircleIconBtn> createState() => _CircleIconBtnState();
}

class _CircleIconBtnState extends State<_CircleIconBtn>
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
            color: AppColors.white,
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
          child: Icon(widget.icon, size: 22, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
