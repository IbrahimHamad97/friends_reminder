import 'package:flutter/material.dart';

/// Primary save button with disabled + animated loading state while [saving].
class SavingFilledButton extends StatelessWidget {
  const SavingFilledButton({
    super.key,
    required this.saving,
    required this.onPressed,
    required this.label,
    this.savingLabel = 'Saving…',
  });

  final bool saving;
  final VoidCallback? onPressed;
  final String label;
  final String savingLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: saving ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: saving
            ? Row(
                key: const ValueKey('saving'),
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    savingLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Text(
                label,
                key: const ValueKey('idle'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
