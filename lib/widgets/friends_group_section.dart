import 'package:flutter/material.dart';

import '../data/database.dart';
import 'friend_avatar.dart';
import 'friend_card.dart';

/// Nudges a stored group color toward the app [ColorScheme] so it sits cleanly on M3 surfaces.
Color _harmonizedGroupAccent(ColorScheme scheme, Color stored) {
  return Color.lerp(stored, scheme.primary, 0.22)!;
}

/// One friends group: ribbon header, avatar cluster, members always visible.
class FriendsGroupSection extends StatelessWidget {
  /// Creates a visual block for [group] and its [members].
  const FriendsGroupSection({
    super.key,
    required this.group,
    required this.members,
    required this.referenceDate,
    required this.onEditGroup,
    required this.onFriendTap,
  });

  /// Group metadata (name, color).
  final GroupRow group;

  /// Members in this group (already filtered and sorted).
  final List<FriendRow> members;

  /// Reference date for [FriendCard].
  final DateTime referenceDate;

  /// Opens the group editor.
  final VoidCallback onEditGroup;

  /// Opens a friend editor.
  final void Function(FriendRow friend) onFriendTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = _harmonizedGroupAccent(scheme, Color(group.colorArgb));
    final count = members.length;
    final subtitle = count == 0
        ? 'No one here yet'
        : '$count ${count == 1 ? 'person' : 'people'}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Material(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -40,
                  top: -50,
                  child: IgnorePointer(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.09),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  bottom: 4,
                  child: IgnorePointer(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primary.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 10, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                    height: 1.08,
                                    letterSpacing: -0.55,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _MemberAvatarCluster(
                        members: members,
                        accent: accent,
                        ringColor: scheme.surfaceContainerLow,
                      ),
                      IconButton(
                        tooltip: 'Edit group',
                        visualDensity: VisualDensity.compact,
                        onPressed: onEditGroup,
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 22,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 14,
              child: CustomPaint(
                painter: _WaveRibbonPainter(
                  stroke: accent.withValues(alpha: 0.55),
                  fill: Color.lerp(scheme.surfaceContainerLow, accent, 0.07)!,
                ),
              ),
            ),
            if (members.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.rocket_launch_outlined,
                      size: 26,
                      color: accent.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Open Edit to invite people — they will land in this little crew.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < members.length; i++)
                          FriendCard(
                            key: ValueKey(members[i].id),
                            friend: members[i],
                            referenceDate: referenceDate,
                            groupAccentColors: null,
                            onTap: () => onFriendTap(members[i]),
                          ),
                      ],
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

/// Overlapping face pile for up to four members.
class _MemberAvatarCluster extends StatelessWidget {
  const _MemberAvatarCluster({
    required this.members,
    required this.accent,
    required this.ringColor,
  });

  final List<FriendRow> members;
  final Color accent;
  final Color ringColor;

  static const double _overlap = 16;
  static const double _radius = 17;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: accent.withValues(alpha: 0.45),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              Icons.add_rounded,
              size: 22,
              color: accent.withValues(alpha: 0.85),
            ),
          ),
        ),
      );
    }

    final shown = members.take(4).toList();
    final extra = members.length - shown.length;
    final width = (shown.length - 1) * _overlap +
        _radius * 2 +
        2 +
        (extra > 0 ? 30.0 : 0.0);

    return SizedBox(
      width: width,
      height: _radius * 2 + 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * _overlap,
              top: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .shadow
                          .withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: FriendAvatar(
                  name: shown[i].name,
                  photoPath: shown[i].photoPath,
                  radius: _radius,
                ),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * _overlap,
              top: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border.all(color: ringColor, width: 2.5),
                ),
                child: SizedBox(
                  width: _radius * 2,
                  height: _radius * 2,
                  child: Center(
                    child: Text(
                      '+$extra',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A soft wave stroke with a light fill band under it (ribbon “tear” feel).
class _WaveRibbonPainter extends CustomPainter {
  _WaveRibbonPainter({required this.stroke, required this.fill});

  final Color stroke;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height * 0.45;
    final path = Path()..moveTo(0, midY);
    path.quadraticBezierTo(
        size.width * 0.22, midY - 5.5, size.width * 0.42, midY);
    path.quadraticBezierTo(
        size.width * 0.62, midY + 5.5, size.width * 0.82, midY);
    path.quadraticBezierTo(size.width * 0.92, midY - 3, size.width, midY);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()..color = fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveRibbonPainter old) {
    return old.stroke != stroke || old.fill != fill;
  }
}
