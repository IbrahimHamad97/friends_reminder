import 'package:flutter/material.dart';

/// Centered illustration used when a list has no items.
class EmptyState extends StatelessWidget {
  /// Creates an empty state with [title], [message], and optional [action].
  ///
  /// Parameters:
  /// - [title]: primary heading.
  /// - [message]: supporting copy.
  /// - [actionLabel]: optional button label.
  /// - [onAction]: optional button callback.
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Bold heading text.
  final String title;

  /// Secondary description under the title.
  final String message;

  /// Optional CTA label.
  final String? actionLabel;

  /// Optional CTA handler.
  final VoidCallback? onAction;

  /// Builds the centered column with iconography.
  ///
  /// Parameters:
  /// - [context]: build context.
  ///
  /// Returns: padded [Column] suitable for slivers or plain body.
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.celebration_outlined,
            size: 72,
            color: scheme.primary.withValues(alpha: 0.65),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
