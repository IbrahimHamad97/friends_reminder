import 'package:flutter/material.dart';

/// How close this person is to you — shown on cards and in the friend editor.
enum FriendLevel {
  bestie(
    storageKey: 'bestie',
    label: 'Bestie',
    shortLabel: 'Bestie',
    icon: Icons.favorite_rounded,
  ),
  close(
    storageKey: 'close',
    label: 'Close friend',
    shortLabel: 'Close',
    icon: Icons.people_rounded,
  ),
  regular(
    storageKey: 'regular',
    label: 'Regular',
    shortLabel: 'Regular',
    icon: Icons.person_outline_rounded,
  ),
  casual(
    storageKey: 'casual',
    label: 'Acquaintance',
    shortLabel: 'Casual',
    icon: Icons.waving_hand_rounded,
  );

  const FriendLevel({
    required this.storageKey,
    required this.label,
    required this.shortLabel,
    required this.icon,
  });

  final String storageKey;
  final String label;
  final String shortLabel;
  final IconData icon;

  static FriendLevel fromStorage(String? raw) {
    final key = raw?.trim().toLowerCase();
    for (final level in FriendLevel.values) {
      if (level.storageKey == key) {
        return level;
      }
    }
    return FriendLevel.regular;
  }

  /// Accent for card border and chips (harmonized per level).
  Color accentColor(ColorScheme scheme) {
    switch (this) {
      case FriendLevel.bestie:
        return Color.lerp(scheme.primary, const Color(0xFFE91E8C), 0.35)!;
      case FriendLevel.close:
        return scheme.primary;
      case FriendLevel.regular:
        return scheme.outline;
      case FriendLevel.casual:
        return scheme.tertiary;
    }
  }

  Color chipBackground(ColorScheme scheme) {
    return accentColor(scheme).withValues(alpha: 0.14);
  }

  Color chipForeground(ColorScheme scheme) {
    switch (this) {
      case FriendLevel.bestie:
      case FriendLevel.close:
        return accentColor(scheme);
      case FriendLevel.regular:
        return scheme.onSurfaceVariant;
      case FriendLevel.casual:
        return scheme.onTertiaryContainer;
    }
  }
}
