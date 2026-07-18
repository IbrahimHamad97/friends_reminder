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

  /// Typical reminder cadence in days (form default when this level is picked).
  int get defaultReminderDays {
    switch (this) {
      case FriendLevel.bestie:
        return 7;
      case FriendLevel.close:
        return 14;
      case FriendLevel.regular:
        return 30;
      case FriendLevel.casual:
        return 60;
    }
  }

  /// Human-readable target band for the friend form.
  String get cadenceBandLabel {
    switch (this) {
      case FriendLevel.bestie:
        return 'Every 1–2 weeks';
      case FriendLevel.close:
        return 'Every 2–3 weeks';
      case FriendLevel.regular:
        return 'About once a month';
      case FriendLevel.casual:
        return 'Every 2–3 months';
    }
  }

  /// How many days to add or subtract when random timing is on.
  (int min, int max) get randomVarianceDays {
    switch (this) {
      case FriendLevel.bestie:
        return (1, 2);
      case FriendLevel.close:
        return (3, 4);
      case FriendLevel.regular:
        return (7, 7);
      case FriendLevel.casual:
        return (7, 7);
    }
  }

  /// Short note shown under closeness chips in the form.
  String get formCadenceHint {
    switch (this) {
      case FriendLevel.bestie:
        return 'Besties: ~$defaultReminderDays-day rhythm, usually within 1–2 weeks.';
      case FriendLevel.close:
        return 'Close friends: ~$defaultReminderDays days, roughly every 2–3 weeks.';
      case FriendLevel.regular:
        return 'Regular: ~$defaultReminderDays days, about monthly.';
      case FriendLevel.casual:
        return 'Acquaintances: ~$defaultReminderDays days, every couple of months.';
    }
  }

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
