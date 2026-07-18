import 'package:flutter/material.dart';

import '../data/database.dart';
import '../services/friend_service.dart';
import 'app_snackbar.dart';

/// User choice from the last-conversation sheet.
sealed class CheckInNoteChoice {
  const CheckInNoteChoice();
}

/// Log the check-in without changing the stored conversation note.
class CheckInNoteSkipped extends CheckInNoteChoice {
  const CheckInNoteSkipped();
}

/// Log the check-in and save (or clear) the conversation note.
class CheckInNoteSaved extends CheckInNoteChoice {
  const CheckInNoteSaved(this.text);
  final String text;
}

/// Prompts for an optional note, then logs the check-in only if the user confirms.
///
/// Swiping the sheet away or tapping **Cancel** aborts — nothing is saved.
Future<void> runLogCheckInFlow(
  BuildContext context, {
  required FriendService friendService,
  required FriendRow friend,
  required Future<void> Function() reschedule,
}) async {
  final choice = await _promptLastConversation(
    context,
    friendName: friend.name,
    initialText: friend.lastChatSnippet,
  );
  if (choice == null || !context.mounted) {
    return;
  }

  await friendService.logCheckIn(friend.id);
  await reschedule();
  if (!context.mounted) {
    return;
  }

  if (choice case CheckInNoteSaved(:final text)) {
    await friendService.setLastChatSnippet(friend.id, text);
  }

  if (!context.mounted) {
    return;
  }
  showAppSnackBar('Check-in logged — next reminder is scheduled');
}

/// Bottom sheet: optional note about what you talked about.
///
/// Returns `null` when dismissed (cancelled). Otherwise skip or save choice.
Future<CheckInNoteChoice?> _promptLastConversation(
  BuildContext context, {
  required String friendName,
  String? initialText,
}) {
  return showModalBottomSheet<CheckInNoteChoice?>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _LastConversationSheet(
      friendName: friendName,
      initialText: initialText,
    ),
  );
}

class _LastConversationSheet extends StatefulWidget {
  const _LastConversationSheet({
    required this.friendName,
    this.initialText,
  });

  final String friendName;
  final String? initialText;

  @override
  State<_LastConversationSheet> createState() => _LastConversationSheetState();
}

class _LastConversationSheetState extends State<_LastConversationSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'What did you talk about?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Optional — jot a line about your chat with ${widget.friendName}. '
            'Close this sheet to cancel.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'e.g. new job, their trip, health update…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  const CheckInNoteSkipped(),
                ),
                child: const Text('Skip note'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  CheckInNoteSaved(_controller.text.trim()),
                ),
                child: const Text('Save & log'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
