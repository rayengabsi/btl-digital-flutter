import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Success Transfer Screen
// ═══════════════════════════════════════════════════════════════════════════════
class SuccessTransferScreen extends StatefulWidget {
  const SuccessTransferScreen({
    super.key,
    required this.recipientName,
    required this.amount,
    required this.onDone,
  });

  final String recipientName;
  final double amount;
  final VoidCallback onDone;

  @override
  State<SuccessTransferScreen> createState() => _SuccessTransferScreenState();
}

class _SuccessTransferScreenState extends State<SuccessTransferScreen>
    with TickerProviderStateMixin {
  // Checkmark draw animation
  late AnimationController _checkCtrl;
  late Animation<double> _checkAnim;

  // Outer circle scale
  late AnimationController _circleCtrl;
  late Animation<double> _circleScale;

  // Content fade + slide
  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  // Confetti-like particle controller
  late AnimationController _particleCtrl;

  @override
  void initState() {
    super.initState();

    // Checkmark
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkAnim = CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOut);

    // Circle
    _circleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _circleCtrl, curve: Curves.elasticOut),
    );

    // Content
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));

    // Particles
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Sequence: circle → checkmark → content → particles
    _circleCtrl.forward().then((_) {
      _checkCtrl.forward();
      _particleCtrl.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _contentCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _circleCtrl.dispose();
    _contentCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background image (same as rest of app)
            Positioned.fill(
              child: Image.asset(
                'assets/images/dashboard_bg.png',
                fit: BoxFit.cover,
              ),
            ),

            // Particle overlay
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleCtrl,
                builder: (context, _) => CustomPaint(
                  painter: _ConfettiPainter(progress: _particleCtrl.value),
                ),
              ),
            ),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated checkmark
                        ScaleTransition(
                          scale: _circleScale,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.35),
                                  blurRadius: 40,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: AnimatedBuilder(
                              animation: _checkAnim,
                              builder: (context, _) => CustomPaint(
                                painter: _CheckPainter(
                                  progress: _checkAnim.value,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Transfer Successful!',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          'Your money has been sent successfully.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // Amount + recipient
                        if (widget.amount > 0 &&
                            widget.recipientName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'TND ${widget.amount.toStringAsFixed(2)}',
                                  style: AppTypography.h4.copyWith(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: ' sent to ',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.recipientName.split(' ').first,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 48),

                        // Share receipt button
                        _SuccessButton(
                          label: 'Share Receipt',
                          icon: Icons.share_rounded,
                          isPrimary: false,
                          onTap: () {},
                        ),

                        const SizedBox(height: 12),

                        // Download PDF button
                        _SuccessButton(
                          label: 'Download PDF Receipt',
                          icon: Icons.download_rounded,
                          isPrimary: false,
                          onTap: () {},
                        ),

                        const SizedBox(height: 12),

                        // Done button
                        _SuccessButton(
                          label: 'Done',
                          icon: Icons.check_rounded,
                          isPrimary: true,
                          onTap: widget.onDone,
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
    );
  }
}

// ─── Success action button ────────────────────────────────────────────────────
class _SuccessButton extends StatefulWidget {
  const _SuccessButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  State<_SuccessButton> createState() => _SuccessButtonState();
}

class _SuccessButtonState extends State<_SuccessButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
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
          width: double.infinity,
          height: AppDimensions.buttonHeight,
          decoration: BoxDecoration(
            color: widget.isPrimary ? AppColors.primaryGreen : AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: widget.isPrimary
                ? null
                : Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.isPrimary
                    ? Colors.white
                    : AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTypography.buttonLarge.copyWith(
                  color: widget.isPrimary
                      ? Colors.white
                      : AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Animated checkmark painter ──────────────────────────────────────────────
class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Check path: two segments
    // First segment: down-left  (progress 0→0.4)
    // Second segment: up-right  (progress 0.4→1.0)
    final p1 = Offset(cx - 18, cy);
    final p2 = Offset(cx - 4, cy + 14);
    final p3 = Offset(cx + 20, cy - 14);

    final path = Path();
    path.moveTo(p1.dx, p1.dy);

    if (progress <= 0.4) {
      final t = progress / 0.4;
      final midX = p1.dx + (p2.dx - p1.dx) * t;
      final midY = p1.dy + (p2.dy - p1.dy) * t;
      path.lineTo(midX, midY);
    } else {
      path.lineTo(p2.dx, p2.dy);
      final t = (progress - 0.4) / 0.6;
      final endX = p2.dx + (p3.dx - p2.dx) * t;
      final endY = p2.dy + (p3.dy - p2.dy) * t;
      path.lineTo(endX, endY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}

// ─── Confetti painter ─────────────────────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});

  final double progress;

  static final _rng = math.Random(42);
  static final _particles = List.generate(40, (i) => _Particle(_rng));

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final x = size.width * p.x +
          p.vx * progress * size.width * 0.3;
      final y = size.height * p.startY +
          (size.height * 0.8) * progress * p.vy;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity * p.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation * progress * math.pi * 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.5,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _Particle {
  _Particle(math.Random rng)
      : x = rng.nextDouble(),
        startY = rng.nextDouble() * 0.6,
        vx = (rng.nextDouble() - 0.5) * 1.5,
        vy = rng.nextDouble() * 0.8 + 0.2,
        rotation = (rng.nextDouble() - 0.5) * 2,
        size = rng.nextDouble() * 8 + 4,
        opacity = rng.nextDouble() * 0.7 + 0.3,
        color = _colors[rng.nextInt(_colors.length)];

  final double x;
  final double startY;
  final double vx;
  final double vy;
  final double rotation;
  final double size;
  final double opacity;
  final Color color;

  static const _colors = [
    AppColors.primaryGreen,
    Color(0xFF0B6B53),
    Color(0xFFFFC107),
    Color(0xFF4CAF50),
    Color(0xFF81C784),
    Color(0xFFFFEB3B),
  ];
}
