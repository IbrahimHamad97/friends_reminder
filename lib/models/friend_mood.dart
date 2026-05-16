import 'package:flutter/material.dart';

/// Optional emotional context before you text someone.
enum FriendMood {
  goodPlace(
    storageKey: 'good_place',
    label: 'Good place',
    icon: Icons.sentiment_satisfied_alt_rounded,
  ),
  busy(
    storageKey: 'busy',
    label: 'Busy lately',
    icon: Icons.schedule_rounded,
  ),
  toughTime(
    storageKey: 'tough_time',
    label: 'Tough time',
    icon: Icons.favorite_border_rounded,
  ),
  celebrating(
    storageKey: 'celebrating',
    label: 'Celebrating',
    icon: Icons.celebration_outlined,
  );

  const FriendMood({
    required this.storageKey,
    required this.label,
    required this.icon,
  });

  final String storageKey;
  final String label;
  final IconData icon;

  static FriendMood? fromStorage(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final key = raw.trim().toLowerCase();
    for (final mood in FriendMood.values) {
      if (mood.storageKey == key) {
        return mood;
      }
    }
    return null;
  }

  Color chipBackground(ColorScheme scheme) {
    switch (this) {
      case FriendMood.goodPlace:
        return scheme.tertiaryContainer.withValues(alpha: 0.85);
      case FriendMood.busy:
        return scheme.surfaceContainerHighest;
      case FriendMood.toughTime:
        return scheme.errorContainer.withValues(alpha: 0.55);
      case FriendMood.celebrating:
        return scheme.primaryContainer.withValues(alpha: 0.75);
    }
  }

  Color chipForeground(ColorScheme scheme) {
    switch (this) {
      case FriendMood.goodPlace:
        return scheme.onTertiaryContainer;
      case FriendMood.busy:
        return scheme.onSurfaceVariant;
      case FriendMood.toughTime:
        return scheme.onErrorContainer;
      case FriendMood.celebrating:
        return scheme.onPrimaryContainer;
    }
  }
}
