import 'package:flutter/material.dart';

import '../services/theme_service.dart';
import '../theme/app_theme.dart';

/// Theme gallery: System + Light and Dark sections, with an Apply action.
class ThemePicker extends StatelessWidget {
  const ThemePicker({
    super.key,
    required this.presets,
    required this.appliedId,
    required this.selectedId,
    required this.onSelected,
    required this.onApply,
  });

  final List<AppThemePreset> presets;

  /// Applied preference id (preset id or [ThemeService.systemId]).
  final String appliedId;

  /// Draft selection id (preset id or [ThemeService.systemId]).
  final String selectedId;
  final ValueChanged<String> onSelected;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final changed = appliedId != selectedId;
    final light =
        presets.where((p) => p.brightness == Brightness.light).toList();
    final dark = presets.where((p) => p.brightness == Brightness.dark).toList();
    final systemSelected = selectedId == ThemeService.systemId;
    final systemApplied = appliedId == ThemeService.systemId;
    // Only mark the palette System is using right now (light XOR dark).
    final activeSystemPresetId = (systemSelected || systemApplied)
        ? AppTheme.defaultForBrightness(
            MediaQuery.platformBrightnessOf(context),
          ).id
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pick a palette, then apply it across the whole app. '
          'System follows your phone light or dark setting.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 20),
        _SectionTitle(
          icon: Icons.brightness_auto_outlined,
          title: 'Device',
        ),
        const SizedBox(height: 10),
        _SystemChoice(
          selected: systemSelected,
          applied: systemApplied,
          onTap: () => onSelected(ThemeService.systemId),
        ),
        const SizedBox(height: 24),
        _SectionTitle(
          icon: Icons.wb_sunny_outlined,
          title: 'Light mode',
        ),
        const SizedBox(height: 10),
        _ThemeGrid(
          presets: light,
          appliedId: appliedId,
          selectedId: selectedId,
          activeSystemPresetId: activeSystemPresetId,
          onSelected: onSelected,
        ),
        const SizedBox(height: 24),
        _SectionTitle(
          icon: Icons.dark_mode_outlined,
          title: 'Dark mode',
        ),
        const SizedBox(height: 10),
        _ThemeGrid(
          presets: dark,
          appliedId: appliedId,
          selectedId: selectedId,
          activeSystemPresetId: activeSystemPresetId,
          onSelected: onSelected,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: changed ? onApply : null,
          icon: Icon(
            changed ? Icons.palette_outlined : Icons.check_circle_rounded,
          ),
          label: Text(changed ? 'Apply selected theme' : 'Theme applied'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _SystemChoice extends StatelessWidget {
  const _SystemChoice({
    required this.selected,
    required this.applied,
    required this.onTap,
  });

  final bool selected;
  final bool applied;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final light = AppTheme.defaultLightPreset;
    final dark = AppTheme.defaultDarkPreset;

    return Semantics(
      button: true,
      selected: selected,
      label: 'System theme${applied ? ', currently applied' : ''}',
      child: Material(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: 0.42)
            : scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.6),
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 40,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 34,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: light.surfaceColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  scheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: light.previewColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 34,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: dark.surfaceColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  scheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: dark.previewColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        applied
                            ? 'Applied'
                            : 'Matches phone light / dark · '
                                '${light.name} / ${dark.name}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: applied
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                              fontWeight:
                                  applied ? FontWeight.w700 : FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeGrid extends StatelessWidget {
  const _ThemeGrid({
    required this.presets,
    required this.appliedId,
    required this.selectedId,
    required this.activeSystemPresetId,
    required this.onSelected,
  });

  final List<AppThemePreset> presets;
  final String appliedId;
  final String selectedId;
  final String? activeSystemPresetId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: presets.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.75,
      ),
      itemBuilder: (context, index) {
        final preset = presets[index];
        return _ThemeChoice(
          preset: preset,
          selected: preset.id == selectedId,
          applied: preset.id == appliedId,
          usedBySystem: preset.id == activeSystemPresetId,
          onTap: () => onSelected(preset.id),
        );
      },
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.preset,
    required this.selected,
    required this.applied,
    required this.usedBySystem,
    required this.onTap,
  });

  final AppThemePreset preset;
  final bool selected;
  final bool applied;
  final bool usedBySystem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final checkColor =
        ThemeData.estimateBrightnessForColor(preset.previewColor) ==
                Brightness.dark
            ? Colors.white
            : Colors.black87;

    final emphasized = selected || usedBySystem;
    return Semantics(
      button: true,
      selected: selected,
      label:
          '${preset.name} theme${applied ? ', currently applied' : ''}${usedBySystem ? ', used by System' : ''}',
      child: Material(
        color: emphasized
            ? scheme.primaryContainer.withValues(alpha: selected ? 0.42 : 0.28)
            : scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected
                ? scheme.primary
                : usedBySystem
                    ? scheme.primary.withValues(alpha: 0.55)
                    : scheme.outlineVariant.withValues(alpha: 0.6),
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Mini preview: surface strip + vivid brand circle
                SizedBox(
                  width: 52,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        top: 4,
                        bottom: 4,
                        child: Container(
                          width: 22,
                          decoration: BoxDecoration(
                            color: preset.surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  scheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: preset.previewColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.55),
                              width: selected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    preset.previewColor.withValues(alpha: 0.35),
                                blurRadius: selected ? 10 : 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 160),
                            child: selected
                                ? Icon(
                                    Icons.check_rounded,
                                    key: const ValueKey('selected'),
                                    color: checkColor,
                                    size: 24,
                                  )
                                : const SizedBox(
                                    key: ValueKey('not-selected'),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preset.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        usedBySystem
                            ? (applied ? 'Applied · System' : 'Used by System')
                            : (applied ? 'Applied' : preset.description),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: (applied || usedBySystem)
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                              fontWeight: (applied || usedBySystem)
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
