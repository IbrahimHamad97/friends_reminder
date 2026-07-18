import 'package:flutter/material.dart';

/// Primary check-in CTA on friend detail — prominent when [isDue], compact otherwise.
class CheckInActionCard extends StatelessWidget {
  const CheckInActionCard({
    super.key,
    required this.friendName,
    required this.isDue,
    required this.onLogCheckIn,
    this.isLoading = false,
  });

  final String friendName;
  final bool isDue;
  final VoidCallback? onLogCheckIn;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (isDue) {
      return _CheckInCardShell(
        scheme: scheme,
        highlighted: true,
        icon: Icons.notifications_active_rounded,
        title: 'Check-in reminder today',
        body:
            'After you reach out to $friendName, tap the button below. '
            'We\'ll schedule their next reminder from today.',
        child: FilledButton.icon(
          onPressed: isLoading ? null : onLogCheckIn,
          icon: _buttonIcon(isLoading, scheme.onPrimary),
          label: Text(isLoading ? 'Saving…' : 'Log check-in'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    return _CheckInCardShell(
      scheme: scheme,
      highlighted: false,
      icon: Icons.event_available_outlined,
      title: 'Already talked to them?',
      body:
          'Their next reminder isn\'t due yet. You can still log a check-in now '
          'and restart the timer from today.',
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onLogCheckIn,
        icon: _buttonIcon(isLoading, scheme.primary),
        label: Text(isLoading ? 'Saving…' : 'Log check-in anyway'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size.fromHeight(48),
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.45)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buttonIcon(bool loading, Color color) {
    if (loading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    return const Icon(Icons.check_circle_outline_rounded);
  }
}

class _CheckInCardShell extends StatelessWidget {
  const _CheckInCardShell({
    required this.scheme,
    required this.highlighted,
    required this.icon,
    required this.title,
    required this.body,
    required this.child,
  });

  final ColorScheme scheme;
  final bool highlighted;
  final IconData icon;
  final String title;
  final String body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bg = highlighted
        ? scheme.secondaryContainer.withValues(alpha: 0.55)
        : scheme.surfaceContainerLow;
    final border = highlighted
        ? scheme.secondary.withValues(alpha: 0.28)
        : scheme.outlineVariant.withValues(alpha: 0.45);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: scheme.primary, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
