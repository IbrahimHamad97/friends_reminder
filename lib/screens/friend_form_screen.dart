import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../services/contact_phone_import.dart';
import '../services/friend_photo_storage.dart';
import '../services/friend_service.dart';
import '../services/group_service.dart';
import '../services/notification_scheduler.dart';
import '../data/database.dart';
import '../models/friend_level.dart';
import '../models/friend_mood.dart';
import '../utils/circular_photo_crop.dart';
import '../utils/date_utils.dart';
import '../utils/friend_phone.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import '../widgets/local_file_avatar.dart';
import '../widgets/saving_filled_button.dart';

/// Create or edit a friend: identity, birthday, notes, reminder cadence, optional photo,
/// and **group membership** (chips synced via [GroupService.setGroupsForFriend] on save).
class FriendFormScreen extends StatefulWidget {
  /// Creates a form for a new friend when [friendId] is `null`, or loads an existing row.
  ///
  /// Parameters:
  /// - [friendService]: persistence for the friend row and photo path.
  /// - [groupService]: load/save which groups include this friend.
  /// - [friendId]: when non-null, edit mode; otherwise create mode.
  const FriendFormScreen({
    super.key,
    required this.friendService,
    required this.groupService,
    this.friendId,
  });

  /// Persistence API.
  final FriendService friendService;

  /// Group membership when saving.
  final GroupService groupService;

  /// Optional id selecting the friend to edit.
  final int? friendId;

  @override
  State<FriendFormScreen> createState() => _FriendFormScreenState();
}

/// State for [FriendFormScreen]: form fields, media staging, group chips, and persistence.
class _FriendFormScreenState extends State<FriendFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late final TextEditingController _reminderDaysController;
  late final TextEditingController _lastChatController;
  late final TextEditingController _howWeMetController;
  late final TextEditingController _phoneController;
  DateTime _birthday = DateTime(DateTime.now().year, 1, 1);
  FriendLevel _closenessLevel = FriendLevel.regular;
  FriendMood? _mood;
  bool _useRandomCheckIn = true;
  bool _loading = false;
  bool _saving = false;
  bool _initialized = false;

  /// Staged gallery pick path (mobile/desktop only).
  String? _pickedImagePath;

  /// Stored path from the database while editing.
  String? _storedPhotoPath;

  /// Last "reached out" instant when editing; drives rhythm reset in UI copy.
  DateTime? _lastContactedAt;

  /// All groups (name order) used to build the membership chips.
  List<GroupRow> _allGroups = [];

  /// Group ids this friend belongs to; persisted with [GroupService.setGroupsForFriend].
  Set<int> _selectedGroupIds = {};

  /// When true, clears the stored photo on save.
  bool _removeStoredPhoto = false;

  /// Whether the screen is editing an existing id.
  bool get _isEditing => widget.friendId != null;

  /// Wires text controllers and starts [_bootstrap].
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _notesController = TextEditingController();
    _reminderDaysController = TextEditingController(
      text: '${FriendLevel.regular.defaultReminderDays}',
    );
    _lastChatController = TextEditingController();
    _howWeMetController = TextEditingController();
    _phoneController = TextEditingController();
    _bootstrap();
  }

  /// Loads ordered groups, then (in edit mode) the friend row and current group ids.
  ///
  /// Pops the route if the friend id is missing. Sets [_initialized] when ready to build.
  ///
  /// Returns: future that completes when bootstrap finishes or navigates away.
  Future<void> _bootstrap() async {
    final groups = await widget.groupService.getAllGroupsOrdered();
    if (!mounted) {
      return;
    }
    setState(() => _allGroups = groups);

    final id = widget.friendId;
    if (id == null) {
      setState(() => _initialized = true);
      return;
    }
    setState(() => _loading = true);
    final row = await widget.friendService.getFriendById(id);
    if (!mounted) {
      return;
    }
    if (row == null) {
      setState(() {
        _loading = false;
        _initialized = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend not found')),
      );
      context.pop();
      return;
    }
    _nameController.text = row.name;
    _birthday = row.birthday;
    _notesController.text = row.notes ?? '';
    _reminderDaysController.text = '${row.reminderIntervalDays}';
    _lastChatController.text = row.lastChatSnippet ?? '';
    _howWeMetController.text = row.howWeMet ?? '';
    _phoneController.text = row.phoneNumber ?? '';
    _closenessLevel = FriendLevel.fromStorage(row.closenessLevel);
    _useRandomCheckIn = row.useRandomCheckIn;
    _mood = FriendMood.fromStorage(row.moodTag);
    _storedPhotoPath = row.photoPath;
    _lastContactedAt = row.lastContactedAt;
    final gids = await widget.groupService.getGroupIdsForFriend(id);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedGroupIds = gids;
      _loading = false;
      _initialized = true;
    });
  }

  /// Disposes all text controllers owned by this state.
  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _reminderDaysController.dispose();
    _lastChatController.dispose();
    _howWeMetController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Opens the gallery picker and stages a new photo path on supported platforms.
  ///
  /// Returns: future that completes when selection finishes or is cancelled.
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2400,
      imageQuality: 95,
    );
    if (xFile == null || !mounted) {
      return;
    }
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Saving photos is supported on mobile and desktop installs.'),
        ),
      );
      return;
    }
    final bytes = await xFile.readAsBytes();
    if (!mounted) {
      return;
    }
    final croppedPath = await CircularPhotoCrop.pushCropEditor(
      context,
      imageBytes: bytes,
      title: 'Crop photo',
    );
    if (!mounted || croppedPath == null) {
      return;
    }
    setState(() {
      _pickedImagePath = croppedPath;
      _removeStoredPhoto = false;
    });
  }

  /// Fills the phone field from a device contact (mobile only).
  Future<void> _importPhoneFromContacts() async {
    final phone = await pickContactPhoneNumber(context);
    if (phone == null || !mounted) {
      return;
    }
    setState(() => _phoneController.text = phone);
  }

  /// Clears both staged and stored photo previews (applied on save for edits).
  ///
  /// Returns: nothing.
  void _clearPhoto() {
    setState(() {
      _pickedImagePath = null;
      _removeStoredPhoto = true;
    });
  }

  /// Presents a Material date picker constrained to reasonable years.
  ///
  /// Returns: future completing after user picks a date or cancels.
  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 120)),
    );
    if (picked != null) {
      setState(() => _birthday = picked);
    }
  }

  /// Normalizes optional notes to `null` when blank after trim.
  ///
  /// Parameters:
  /// - [value]: raw controller text.
  ///
  /// Returns: trimmed string or `null`.
  String? _optionalNotes(String value) {
    final t = value.trim();
    return t.isEmpty ? null : t;
  }

  /// Parses reminder interval from text; returns `null` if not a positive integer.
  ///
  /// Parameters:
  /// - [text]: raw text field value.
  ///
  /// Returns: parsed days, or `null` when invalid.
  int? _parseReminderDays(String text) {
    return int.tryParse(text.trim());
  }

  /// Applies default reminder days when the user picks a closeness level.
  void _selectCloseness(FriendLevel level) {
    setState(() {
      _closenessLevel = level;
      _reminderDaysController.text = '${level.defaultReminderDays}';
    });
  }

  /// Persists the friend row, optional photo, **and** group links, then pops on success.
  ///
  /// Calls [GroupService.setGroupsForFriend] after the friend id is known.
  ///
  /// Returns: future completing after save attempt (shows snackbar on error).
  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    final name = _nameController.text.trim();
    final notes = _optionalNotes(_notesController.text);
    final reminderDays = _parseReminderDays(_reminderDaysController.text);
    if (reminderDays == null || reminderDays < 1 || reminderDays > 365) {
      return;
    }
    final lastChat = _optionalNotes(_lastChatController.text);
    final howWeMet = _optionalNotes(_howWeMetController.text);
    final phone = normalizeFriendPhoneInput(_phoneController.text);

    setState(() => _saving = true);
    try {
      late final int savedId;
      if (_isEditing) {
        savedId = widget.friendId!;
        final previous = await widget.friendService.getFriendById(savedId);
        await widget.friendService.updateFriend(
          id: savedId,
          name: name,
          birthday: _birthday,
          notes: notes,
          reminderIntervalDays: reminderDays,
          useRandomCheckIn: _useRandomCheckIn,
          closenessLevel: _closenessLevel.storageKey,
          moodTag: _mood?.storageKey,
          lastChatSnippet: lastChat,
          howWeMet: howWeMet,
          phoneNumber: phone,
        );
        await _syncPhotoAfterSave(
          friendId: savedId,
          previousPath: previous?.photoPath,
        );
      } else {
        savedId = await widget.friendService.createFriend(
          name: name,
          birthday: _birthday,
          notes: notes,
          reminderIntervalDays: reminderDays,
          useRandomCheckIn: _useRandomCheckIn,
          closenessLevel: _closenessLevel.storageKey,
          moodTag: _mood?.storageKey,
          lastChatSnippet: lastChat,
          howWeMet: howWeMet,
          phoneNumber: phone,
        );
        await _syncPhotoAfterSave(
          friendId: savedId,
          previousPath: null,
        );
      }
      await widget.groupService.setGroupsForFriend(savedId, _selectedGroupIds);
      if (!mounted) {
        return;
      }
      await _refreshNotifications();
      if (!mounted) {
        return;
      }
      final message =
          _isEditing ? 'Changes saved' : 'Friend added successfully';
      showAppSnackBar(message);
      context.pop();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  /// Rebuilds OS notification schedules after this friend row changed.
  ///
  /// Returns: future completing after scheduling (errors are swallowed).
  Future<void> _refreshNotifications() async {
    try {
      await NotificationScheduler.instance.rescheduleAll(widget.friendService);
    } catch (_) {}
  }

  Future<void> _confirmUndoLastCheckIn() async {
    final id = widget.friendId;
    if (id == null) {
      return;
    }
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Undo last check-in?'),
              content: const Text(
                'This removes the date you logged reaching out. '
                'Their next reminder will count from when you added them—not from your last check-in.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Keep check-in'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Undo check-in'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!ok || !mounted) {
      return;
    }
    await widget.friendService.setLastContactedAt(id, null);
    if (!mounted) {
      return;
    }
    setState(() => _lastContactedAt = null);
    await _refreshNotifications();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Last check-in removed. Next reminder counts from when you added them.',
        ),
      ),
    );
  }

  /// Applies staged removals and uploads after the friend row exists.
  ///
  /// Parameters:
  /// - [friendId]: primary key used in the upload filename hint.
  /// - [previousPath]: last persisted URL or legacy disk path, if any.
  Future<void> _syncPhotoAfterSave({
    required int friendId,
    required String? previousPath,
  }) async {
    if (_removeStoredPhoto && previousPath != null) {
      await FriendPhotoStorage.deleteIfExists(previousPath);
      await widget.friendService.setFriendPhotoPath(friendId, null);
    }
    final stagedPath = _pickedImagePath;
    if (stagedPath != null && !kIsWeb) {
      if (previousPath != null &&
          previousPath.isNotEmpty &&
          !_removeStoredPhoto) {
        await FriendPhotoStorage.deleteIfExists(previousPath);
      }
      final saved =
          await FriendPhotoStorage.saveForFriendFromPath(friendId, stagedPath);
      await widget.friendService.setFriendPhotoPath(friendId, saved);
    }
  }

  /// Confirms deletion for edit mode and removes the row and photo file.
  ///
  /// Returns: future completing after delete or cancel.
  Future<void> _confirmDelete() async {
    final id = widget.friendId;
    if (id == null) {
      return;
    }
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete friend?'),
              content: const Text(
                  'This removes their card and clears their stored photo link.'),
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
            );
          },
        ) ??
        false;
    if (!ok || !mounted) {
      return;
    }
    await widget.friendService.deleteFriend(id);
    await _refreshNotifications();
    if (!mounted) {
      return;
    }
    showAppSnackBar('Friend removed');
    context.go('/friends');
  }

  /// Whether the user can clear an existing or staged photo.
  ///
  /// Returns: true when a staged pick or stored path is present (and not already cleared).
  bool get _canClearPhoto {
    if (_pickedImagePath != null) {
      return true;
    }
    return _storedPhotoPath != null &&
        _storedPhotoPath!.isNotEmpty &&
        !_removeStoredPhoto;
  }

  /// Builds the large circular preview at the top of the form.
  ///
  /// Parameters:
  /// - [scheme]: active color scheme for placeholders.
  ///
  /// Returns: avatar widget with optional file image.
  Widget _buildPhotoPreview(ColorScheme scheme) {
    final letter = _nameController.text.trim().isEmpty
        ? '?'
        : _nameController.text.trim().substring(0, 1).toUpperCase();
    final fallback = CircleAvatar(
      radius: 56,
      backgroundColor: scheme.surfaceContainerHighest,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
    );
    if (!kIsWeb && _pickedImagePath != null) {
      return buildLocalFileAvatar(
        absolutePath: _pickedImagePath,
        radius: 56,
        fallback: fallback,
      );
    }
    if (!_removeStoredPhoto &&
        _storedPhotoPath != null &&
        _storedPhotoPath!.isNotEmpty) {
      return buildLocalFileAvatar(
        absolutePath: _storedPhotoPath,
        radius: 56,
        fallback: fallback,
      );
    }
    return fallback;
  }

  /// Builds the friend editor: scrollable form fields and pinned save button.
  ///
  /// Parameters:
  /// - [context]: build context.
  ///
  /// Returns: scaffold with loading, form, or error state.
  @override
  Widget build(BuildContext context) {
    if (!_initialized || _loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(8, topInset + 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    _isEditing ? 'Edit friend' : 'New friend',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Align(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildPhotoPreview(scheme),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Material(
                            color: scheme.primary,
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: 'Choose photo',
                              onPressed: _pickPhoto,
                              icon: Icon(Icons.photo_camera_outlined,
                                  color: scheme.onPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_canClearPhoto)
                    Align(
                      child: TextButton(
                        onPressed: _clearPhoto,
                        child: const Text('Remove photo'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'How you think of them',
                    ),
                    validator: validateFriendName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Mobile number (optional)',
                      hintText: '+1 555 123 4567',
                      helperText: 'Enables Call and WhatsApp on their profile',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      suffixIcon: contactPhoneImportSupported
                          ? IconButton(
                              tooltip: 'Import from contacts',
                              onPressed: _importPhoneFromContacts,
                              icon: const Icon(Icons.contacts_outlined),
                            )
                          : null,
                    ),
                    validator: validateOptionalPhone,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Closeness',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'How tight you are — shows on their card.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: FriendLevel.values.map((level) {
                      final selected = _closenessLevel == level;
                      final accent = level.accentColor(scheme);
                      return FilterChip(
                        selected: selected,
                        showCheckmark: true,
                        avatar: Icon(
                          level.icon,
                          size: 18,
                          color: selected ? accent : scheme.onSurfaceVariant,
                        ),
                        label: Text(level.label),
                        selectedColor: level.chipBackground(scheme),
                        side: BorderSide(
                          color: selected
                              ? accent.withValues(alpha: 0.6)
                              : scheme.outline.withValues(alpha: 0.35),
                        ),
                        onSelected: (_) => _selectCloseness(level),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _closenessLevel.formCadenceHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reminderDaysController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Reminder every (days)',
                      hintText: '1–365',
                      helperText:
                          'Default for ${_closenessLevel.label}: ${_closenessLevel.defaultReminderDays} days (${_closenessLevel.cadenceBandLabel})',
                    ),
                    validator: validateReminderIntervalDays,
                  ),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Vary timing a little'),
                    subtitle: Text(
                      _useRandomCheckIn
                          ? 'Each reminder lands near your target — a few days earlier or later so it feels natural (${_closenessLevel.cadenceBandLabel}).'
                          : 'Reminders fire exactly every ${_reminderDaysController.text.trim().isEmpty ? '…' : _reminderDaysController.text.trim()} days.',
                    ),
                    value: _useRandomCheckIn,
                    onChanged: (value) =>
                        setState(() => _useRandomCheckIn = value),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'How are they doing?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        selected: _mood == null,
                        label: const Text('No tag'),
                        onSelected: (_) => setState(() => _mood = null),
                      ),
                      ...FriendMood.values.map((mood) {
                        final selected = _mood == mood;
                        return FilterChip(
                          selected: selected,
                          avatar: Icon(mood.icon, size: 18),
                          label: Text(mood.label),
                          selectedColor: mood.chipBackground(scheme),
                          onSelected: (_) {
                            setState(() => _mood = selected ? null : mood);
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastChatController,
                    maxLines: 2,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Last conversation',
                      hintText: 'e.g. new job, cat surgery, trip to Lisbon…',
                      helperText:
                          'Short reminder of what you last talked about',
                    ),
                    validator: (v) => validateOptionalShortLine(v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _howWeMetController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'How you met',
                      hintText:
                          'e.g. college roommate, work 2019, climbing gym',
                    ),
                    validator: (v) => validateOptionalShortLine(v),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Birthday'),
                    subtitle: Text(formatMonthDay(_birthday)),
                    trailing: FilledButton.tonalIcon(
                      onPressed: _pickBirthday,
                      icon: const Icon(Icons.cake_outlined),
                      label: const Text('Choose date'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tip: the year can be approximate if you only track the annual date.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (_isEditing) ...[
                    if (_lastContactedAt != null) ...[
                      Text(
                        lastContactedSummary(_lastContactedAt!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reminders are counting from that check-in.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _confirmUndoLastCheckIn,
                        icon: const Icon(Icons.undo_rounded, size: 20),
                        label: const Text('Undo last check-in'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      'To log a new check-in, open their profile and tap Log check-in.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Groups',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (_allGroups.isEmpty)
                    Text(
                      'No groups yet. Use Add → New group on the friends list, then assign them here.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allGroups.map((g) {
                        final selected = _selectedGroupIds.contains(g.id);
                        final accent = Color(g.colorArgb);
                        return FilterChip(
                          selected: selected,
                          showCheckmark: true,
                          checkmarkColor: scheme.onPrimary,
                          selectedColor: accent.withValues(alpha: 0.28),
                          side: BorderSide(
                            color: selected
                                ? accent
                                : scheme.outline.withValues(alpha: 0.35),
                          ),
                          avatar: CircleAvatar(
                            radius: 10,
                            backgroundColor: accent,
                            child: const SizedBox.shrink(),
                          ),
                          label: Text(g.name),
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _selectedGroupIds.add(g.id);
                              } else {
                                _selectedGroupIds.remove(g.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Gift ideas, inside jokes, reminders…',
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: _confirmDelete,
                      style:
                          TextButton.styleFrom(foregroundColor: scheme.error),
                      child: const Text('Delete friend'),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SavingFilledButton(
                saving: _saving,
                onPressed: _submit,
                label: _isEditing ? 'Save changes' : 'Save friend',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
