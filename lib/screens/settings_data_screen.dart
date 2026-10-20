import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/friend_service.dart';
import '../services/friends_backup_export.dart';

/// Export backup and on-device storage notes.
class SettingsDataScreen extends StatefulWidget {
  const SettingsDataScreen({
    super.key,
    required this.friendService,
  });

  final FriendService friendService;

  @override
  State<SettingsDataScreen> createState() => _SettingsDataScreenState();
}

class _SettingsDataScreenState extends State<SettingsDataScreen> {
  bool _exporting = false;

  Future<void> _exportBackup() async {
    if (_exporting) {
      return;
    }
    setState(() => _exporting = true);
    try {
      await FriendsBackupExport.shareJson(widget.friendService);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Data & privacy'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.upload_file_rounded, color: scheme.primary),
              title: const Text('Export backup'),
              subtitle: Text(
                'JSON file with names, dates, notes, and cadence (photos stay on device).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              trailing: _exporting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share_rounded),
              onTap: _exporting ? null : _exportBackup,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: scheme.primary),
              title: const Text('On-device storage'),
              subtitle: Text(
                'Friends live in a local SQLite database via Drift—nothing leaves your phone in this build.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
