import 'dart:ui';

import 'package:flutter/material.dart';

// ─── Controller ───────────────────────────────────────────────────────────────

/// Reference-counted overlay loader controller.
///
/// Multiple callers can independently call [show]; the overlay stays visible
/// until every caller has matched it with [hide]. Use [forceHide] in error
/// paths to reset unconditionally.
///
/// Typical usage:
/// ```dart
/// OverlayLoader.show(context);
/// try {
///   await repository.fetchData();
/// } finally {
///   OverlayLoader.hide();
/// }
/// ```
class OverlayLoader {
  OverlayLoader._();

  static final _notifier = ValueNotifier<bool>(false);
  static int _depth = 0;

  /// Shows the loader. Safe to call multiple times.
  static void show(BuildContext context) {
    _depth++;
    if (!_notifier.value) _notifier.value = true;
  }

  /// Hides the loader when all callers have called [hide].
  static void hide() {
    if (_depth > 0) _depth--;
    if (_depth == 0 && _notifier.value) _notifier.value = false;
  }

  /// Immediately hides the loader regardless of depth.
  static void forceHide() {
    _depth = 0;
    if (_notifier.value) _notifier.value = false;
  }

  /// Runs [body] while showing the loader, hides it when done or on error.
  static Future<T> run<T>(
    BuildContext context,
    Future<T> Function() body,
  ) async {
    show(context);
    try {
      return await body();
    } finally {
      hide();
    }
  }

  static ValueNotifier<bool> get notifier => _notifier;
}

// ─── Root wrapper ─────────────────────────────────────────────────────────────

/// Place this at the root of your widget tree (inside [MaterialApp.builder]).
///
/// ```dart
/// builder: (context, child) => AppOverlayLoader(child: child!),
/// ```
class AppOverlayLoader extends StatelessWidget {
  final Widget child;

  const AppOverlayLoader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        ValueListenableBuilder<bool>(
          valueListenable: OverlayLoader.notifier,
          builder: (context, isLoading, child) => _LoaderOverlay(isLoading: isLoading),
        ),
      ],
    );
  }
}

// ─── Animated overlay ─────────────────────────────────────────────────────────

class _LoaderOverlay extends StatefulWidget {
  final bool isLoading;

  const _LoaderOverlay({required this.isLoading});

  @override
  State<_LoaderOverlay> createState() => _LoaderOverlayState();
}

class _LoaderOverlayState extends State<_LoaderOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    if (widget.isLoading) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_LoaderOverlay old) {
    super.didUpdateWidget(old);
    if (widget.isLoading != old.isLoading) {
      widget.isLoading ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fade,
      builder: (context, child) {
        final v = _fade.value;
        if (v == 0) return const SizedBox.shrink();

        return AbsorbPointer(
          absorbing: widget.isLoading,
          child: Opacity(
            opacity: v,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Blurred + dimmed backdrop
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4 * v, sigmaY: 4 * v),
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.38 * v),
                  ),
                ),
                // Spinner card
                Center(
                  child: ScaleTransition(
                    scale: _scale,
                    child: const _PortalCard(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Spinner card ─────────────────────────────────────────────────────────────

class _PortalCard extends StatefulWidget {
  const _PortalCard();

  @override
  State<_PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends State<_PortalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHigh : cs.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.18),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _spin,
          builder: (context, child) => CustomPaint(
            size: const Size(68, 68),
            painter: _PortalPainter(progress: _spin.value),
          ),
        ),
      ),
    );
  }
}

// ─── Portal painter ───────────────────────────────────────────────────────────

class _PortalPainter extends CustomPainter {
  final double progress;

  const _PortalPainter({required this.progress});

  static const _rings = [
    _RingDef(fraction: 0.48, width: 3.5, speed: 1.00, color: Color(0xFF97CE4C)),
    _RingDef(fraction: 0.70, width: 2.5, speed: -0.65, color: Color(0xFF52D9F5)),
    _RingDef(fraction: 0.90, width: 2.0, speed: 0.45, color: Color(0xFF97CE4C)),
  ];

  static const _tau = 3.14159265 * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    // Glowing core
    canvas.drawCircle(
      c,
      maxR * 0.44,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFF97CE4C).withValues(alpha: 0.85),
          const Color(0xFF52D9F5).withValues(alpha: 0.35),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: c, radius: maxR * 0.44)),
    );

    // Spinning arcs
    for (final ring in _rings) {
      final r = maxR * ring.fraction;
      final angle = progress * ring.speed * _tau;
      const sweep = 1.85;

      final arcPaint = Paint()
        ..strokeWidth = ring.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        angle,
        sweep,
        false,
        arcPaint..color = ring.color,
      );

      // Ghost arc on the opposite side
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        angle + 3.14159265,
        sweep * 0.35,
        false,
        arcPaint..color = ring.color.withValues(alpha: 0.22),
      );
    }
  }

  @override
  bool shouldRepaint(_PortalPainter old) => old.progress != progress;
}

class _RingDef {
  final double fraction;
  final double width;
  final double speed;
  final Color color;

  const _RingDef({
    required this.fraction,
    required this.width,
    required this.speed,
    required this.color,
  });
}
