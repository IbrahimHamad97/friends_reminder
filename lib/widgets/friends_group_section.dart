import 'package:flutter/material.dart';

import '../data/database.dart';
import '../services/group_section_prefs.dart';
import 'friend_avatar.dart';
import 'friend_card.dart';
import 'local_file_avatar.dart';

/// Nudges a stored group color toward the app [ColorScheme] so it sits cleanly on M3 surfaces.
Color _harmonizedGroupAccent(ColorScheme scheme, Color stored) {
  return Color.lerp(stored, scheme.primary, 0.22)!;
}

/// One friends group: ribbon header, avatar cluster, collapsible members.
class FriendsGroupSection extends StatefulWidget {
  /// Creates a visual block for [group] and its [members].
  const FriendsGroupSection({
    super.key,
    required this.group,
    required this.members,
    required this.referenceDate,
    required this.onEditGroup,
    required this.onDeleteGroup,
    required this.onFriendTap,
    this.forceExpanded = false,
  });

  /// Group metadata (name, color).
  final GroupRow group;

  /// Members in this group (already filtered and sorted).
  final List<FriendRow> members;

  /// Reference date for [FriendCard].
  final DateTime referenceDate;

  /// Opens the group editor.
  final VoidCallback onEditGroup;

  /// Deletes the group after the header confirm dialog (friends stay in the list).
  final Future<void> Function() onDeleteGroup;

  /// Opens a friend detail/editor.
  final void Function(FriendRow friend) onFriendTap;

  /// When true (e.g. active search), keep the body open regardless of prefs.
  final bool forceExpanded;

  @override
  State<FriendsGroupSection> createState() => _FriendsGroupSectionState();
}

class _FriendsGroupSectionState extends State<FriendsGroupSection>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;
  bool _prefsLoaded = false;

  late final AnimationController _expandController;
  late final Animation<double> _expandFactor;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 0,
    );
    _expandFactor = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );
    _loadExpanded();
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FriendsGroupSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.id != widget.group.id) {
      _prefsLoaded = false;
      _expanded = true;
      _expandController.value = 0;
      _loadExpanded();
      return;
    }
    if (widget.forceExpanded != oldWidget.forceExpanded) {
      if (widget.forceExpanded) {
        _expandController.value = 1;
      } else {
        _expandController.value = _expanded ? 1 : 0;
      }
    }
  }

  Future<void> _loadExpanded() async {
    final value = await GroupSectionPrefs.instance.isExpanded(widget.group.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _expanded = value;
      _prefsLoaded = true;
    });
    // Instant (no animate) so returning from Save / stream rebuilds stay quiet.
    _expandController.value =
        widget.forceExpanded || value ? 1 : 0;
  }

  Future<void> _toggleExpanded() async {
    if (widget.forceExpanded) {
      return;
    }
    final next = !_expanded;
    setState(() => _expanded = next);
    if (next) {
      await _expandController.forward();
    } else {
      await _expandController.reverse();
    }
    await GroupSectionPrefs.instance.setExpanded(widget.group.id, next);
  }

  /// Confirms, then runs [FriendsGroupSection.onDeleteGroup]. Expand tap stays separate.
  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete ${widget.group.name}?'),
            content: const Text(
              'Friends stay in your list—only this group and its cover photo link are removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !mounted) {
      return;
    }
    await widget.onDeleteGroup();
  }

  bool get _showBody =>
      widget.forceExpanded || (_prefsLoaded && _expanded);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent =
        _harmonizedGroupAccent(scheme, Color(widget.group.colorArgb));
    final count = widget.members.length;
    final subtitle = count == 0
        ? 'No one here yet'
        : '$count ${count == 1 ? 'person' : 'people'}';
    final canToggle = !widget.forceExpanded && _prefsLoaded;
    final chevronTooltip = _showBody ? 'Collapse group' : 'Expand group';

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
                  padding: const EdgeInsets.fromLTRB(8, 10, 4, 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: GestureDetector(
                            onTap: canToggle ? _toggleExpanded : null,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                              child: Semantics(
                                button: canToggle,
                                expanded: _showBody,
                                label: '${widget.group.name}. $subtitle',
                                child: Row(
                                  children: [
                                    _GroupAvatar(
                                      name: widget.group.name,
                                      photoPath: widget.group.photoPath,
                                      accent: accent,
                                      radius: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.group.name,
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
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.2,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (widget.members.isNotEmpty) ...[
                                      _MemberAvatarCluster(
                                        members: widget.members,
                                        accent: accent,
                                        ringColor: scheme.surfaceContainerLow,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Icon(
                                      _showBody
                                          ? Icons.expand_less_rounded
                                          : Icons.expand_more_rounded,
                                      color: scheme.onSurfaceVariant,
                                      semanticLabel: chevronTooltip,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      PopupMenuButton<_GroupHeaderAction>(
                        tooltip: 'Group options',
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.more_vert_rounded,
                          size: 22,
                          color: scheme.onSurfaceVariant,
                        ),
                        onSelected: (action) {
                          switch (action) {
                            case _GroupHeaderAction.edit:
                              widget.onEditGroup();
                            case _GroupHeaderAction.delete:
                              _confirmDelete();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _GroupHeaderAction.edit,
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: 12),
                                Text('Edit group'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: _GroupHeaderAction.delete,
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 20),
                                SizedBox(width: 12),
                                Text('Delete group'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ClipRect(
              child: AnimatedBuilder(
                animation: _expandFactor,
                builder: (context, child) {
                  final factor = widget.forceExpanded
                      ? 1.0
                      : _expandFactor.value;
                  if (factor <= 0) {
                    return const SizedBox.shrink();
                  }
                  return Align(
                    alignment: Alignment.topCenter,
                    heightFactor: factor,
                    child: child,
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 14,
                      child: CustomPaint(
                        painter: _WaveRibbonPainter(
                          stroke: accent.withValues(alpha: 0.55),
                          fill: Color.lerp(
                            scheme.surfaceContainerLow,
                            accent,
                            0.07,
                          )!,
                        ),
                      ),
                    ),
                    if (widget.members.isEmpty)
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
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
                              color: scheme.outlineVariant
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(10, 12, 10, 6),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                for (var i = 0;
                                    i < widget.members.length;
                                    i++)
                                  FriendCard(
                                    key: ValueKey(widget.members[i].id),
                                    friend: widget.members[i],
                                    referenceDate: widget.referenceDate,
                                    groupAccentColors: null,
                                    onTap: () => widget
                                        .onFriendTap(widget.members[i]),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _GroupHeaderAction { edit, delete }

/// Small circular group cover: photo, or accent + groups icon.
class _GroupAvatar extends StatelessWidget {
  const _GroupAvatar({
    required this.name,
    required this.photoPath,
    required this.accent,
    required this.radius,
  });

  final String name;
  final String? photoPath;
  final Color accent;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: accent.withValues(alpha: 0.28),
      child: Icon(
        Icons.groups_rounded,
        size: radius * 1.15,
        color: accent,
      ),
    );
    final path = photoPath;
    if (path != null && path.isNotEmpty) {
      return Semantics(
        label: '$name group photo',
        child: buildLocalFileAvatar(
          absolutePath: path,
          radius: radius,
          fallback: fallback,
        ),
      );
    }
    return Semantics(
      label: '$name group',
      child: fallback,
    );
  }
}

/// Overlapping face pile for up to four members (omitted when empty).
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
      return const SizedBox.shrink();
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
