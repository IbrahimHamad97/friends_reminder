import 'package:flutter/material.dart';

/// Short animated splash above [child]: title, tagline, and icon only (no photos).
///
/// Blocks taps on [child] until the animation completes.
class SplashOverlay extends StatefulWidget {
  /// Wraps [child] with a text-first intro animation.
  ///
  /// Parameters:
  /// - [child]: app root (typically [MaterialApp]).
  /// - [title]: main heading.
  /// - [subtitle]: supporting line under the title.
  /// - [backgroundColor]: full-screen background.
  /// - [accentColor]: icon and highlights (match app seed).
  /// - [totalDuration]: controller length (enter + hold + exit).
  const SplashOverlay({
    super.key,
    required this.child,
    this.title = 'Friends Reminder',
    this.subtitle = 'Birthdays & check-ins, kept close',
    this.backgroundColor = const Color(0xFFFFF8F5),
    this.accentColor = const Color(0xFFE26A5A),
    this.totalDuration = const Duration(milliseconds: 2600),
  });

  /// App tree after the splash finishes.
  final Widget child;

  /// Primary splash title.
  final String title;

  /// Secondary line of copy.
  final String subtitle;

  /// Background fill.
  final Color backgroundColor;

  /// Accent for icon decoration.
  final Color accentColor;

  /// Total animation length.
  final Duration totalDuration;

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// Brand column fades and scales in.
  late Animation<double> _markOpacity;
  late Animation<double> _markScale;

  /// Whole overlay fades out at the end.
  late Animation<double> _shellOpacity;

  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.totalDuration,
    );

    _markOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.32, curve: Curves.easeOut),
    );
    _markScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic),
      ),
    );
    _shellOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.64, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().whenComplete(() {
      if (mounted) {
        setState(() => _finished = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Centered text + icon block (no network, no assets).
  ///
  /// Parameters:
  /// - [context]: used only for [DefaultTextStyle] if needed; colors come from [widget].
  ///
  /// Returns: padded column for the scale/fade transition.
  Widget _brandColumn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_rounded,
              size: 44,
              color: widget.accentColor,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.15,
              color: const Color(0xFF1C1B1F).withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.35,
              color: const Color(0xFF1C1B1F).withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showSplash = !_finished;

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          ignoring: showSplash,
          child: widget.child,
        ),
        if (showSplash)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Opacity(
                opacity: _shellOpacity.value.clamp(0.0, 1.0),
                child: Container(
                  color: widget.backgroundColor,
                  alignment: Alignment.center,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: FadeTransition(
                      opacity: _markOpacity,
                      child: ScaleTransition(
                        scale: _markScale,
                        child: _brandColumn(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
