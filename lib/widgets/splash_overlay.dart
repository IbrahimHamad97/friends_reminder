import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Short splash: mascot + copy slide up slightly while fading in, then the whole overlay fades out.
///
/// Native splash uses the same mascot on a dark background for a seamless cold start.
class SplashOverlay extends StatefulWidget {
  /// Wraps [child] with a short branded intro.
  const SplashOverlay({
    super.key,
    required this.child,
    this.title = 'Friends Reminder',
    this.subtitle = 'Birthdays & check-ins, kept close',
    this.totalDuration = const Duration(milliseconds: 2200),
  });

  /// App tree after the splash finishes.
  final Widget child;

  /// Primary splash title.
  final String title;

  /// Secondary line of copy.
  final String subtitle;

  /// Total animation length.
  final Duration totalDuration;

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// Entrance: fade in.
  late Animation<double> _enterOpacity;

  /// Entrance: slide up from a bit below.
  late Animation<Offset> _enterSlide;

  /// Whole splash fades out at the end.
  late Animation<double> _shellOpacity;

  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.totalDuration,
    );

    const enterCurve = Curves.easeOutCubic;

    _enterOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.40, curve: enterCurve),
    );

    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.44, curve: enterCurve),
      ),
    );

    _shellOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 1.0, curve: Curves.easeIn),
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

  @override
  Widget build(BuildContext context) {
    final showSplash = !_finished;
    final scheme = AppTheme.dark.colorScheme;
    final titleStyle = GoogleFonts.plusJakartaSans(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
      height: 1.12,
      color: scheme.onSurface,
    );
    final subtitleStyle = GoogleFonts.plusJakartaSans(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: scheme.onSurfaceVariant,
    );

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
              final shell = _shellOpacity.value.clamp(0.0, 1.0);

              return Opacity(
                opacity: shell,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: ColoredBox(color: scheme.surface),
                      ),
                      Center(
                        child: FadeTransition(
                          opacity: _enterOpacity,
                          child: SlideTransition(
                            position: _enterSlide,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipOval(
                                    child: Image.asset(
                                      'assets/branding/app_mascot.png',
                                      width: 112,
                                      height: 112,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                  const SizedBox(height: 26),
                                  Text(
                                    widget.title,
                                    textAlign: TextAlign.center,
                                    style: titleStyle,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    widget.subtitle,
                                    textAlign: TextAlign.center,
                                    style: subtitleStyle,
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
            },
          ),
      ],
    );
  }
}
