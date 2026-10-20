import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import '../widgets/theme_picker.dart';

/// Full-screen theme gallery with select + Apply.
class SettingsAppearanceScreen extends StatefulWidget {
  const SettingsAppearanceScreen({
    super.key,
    required this.themeService,
  });

  final ThemeService themeService;

  @override
  State<SettingsAppearanceScreen> createState() =>
      _SettingsAppearanceScreenState();
}

class _SettingsAppearanceScreenState extends State<SettingsAppearanceScreen> {
  late String _draftThemeId;

  @override
  void initState() {
    super.initState();
    _draftThemeId = widget.themeService.preferenceId;
  }

  Future<void> _applySelectedTheme() async {
    if (_draftThemeId == ThemeService.systemId) {
      await widget.themeService.applySystem();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('System theme applied')),
      );
      return;
    }

    final preset = AppTheme.byId(_draftThemeId);
    await widget.themeService.applyTheme(preset);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${preset.name} theme applied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.themeService,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: const Text('Appearance'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              ThemePicker(
                presets: AppTheme.presets,
                appliedId: widget.themeService.preferenceId,
                selectedId: _draftThemeId,
                onSelected: (id) => setState(() => _draftThemeId = id),
                onApply: _applySelectedTheme,
              ),
            ],
          ),
        );
      },
    );
  }
}
