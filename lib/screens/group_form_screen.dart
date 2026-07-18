import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../data/database.dart';
import '../services/friend_service.dart';
import '../services/group_photo_storage.dart';
import '../services/group_service.dart';
import '../utils/circular_photo_crop.dart';
import '../utils/group_palette.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import '../widgets/local_file_avatar.dart';
import '../widgets/saving_filled_button.dart';

/// Create or edit a **group**: display name, accent color (full [ColorPicker] dialog),
/// optional cover photo, and bulk **member** checklist ([FriendGroupLinks]).
class GroupFormScreen extends StatefulWidget {
  /// Creates the group editor.
  ///
  /// Parameters:
  /// - [groupService]: create/update/delete group rows and membership.
  /// - [friendService]: list all friends for the member checklist.
  /// - [groupId]: when non-null, edit that group; when `null`, create a new group.
  const GroupFormScreen({
    super.key,
    required this.groupService,
    required this.friendService,
    this.groupId,
  });

  /// Group persistence API.
  final GroupService groupService;

  /// Friend list source for member selection.
  final FriendService friendService;

  /// Optional id of the group being edited.
  final int? groupId;

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

/// Mutable state for [GroupFormScreen]: form fields, color, media, and member ids.
class _GroupFormScreenState extends State<GroupFormScreen> {
  /// Root [Form] key for validation.
  final _formKey = GlobalKey<FormState>();

  /// Editable group display name.
  late final TextEditingController _nameController;

  /// Packed opaque ARGB accent color for the group (persisted as [GroupRow.colorArgb]).
  int _colorArgb = defaultGroupColorArgb();

  /// Staged gallery file path before the row id exists or after pick (IO platforms).
  String? _pickedImagePath;

  /// Path persisted in the database for the current group cover, if any.
  String? _storedPhotoPath;

  /// When true, delete the stored cover on next [_syncPhotoAfterSave].
  bool _removeStoredPhoto = false;

  /// `true` while loading an existing group in [_load].
  bool _loading = false;

  /// `true` while [_submit] is persisting the group.
  bool _saving = false;

  /// `true` after [_load] has finished for create or edit paths.
  bool _initialized = false;

  /// Friend ids selected as members of this group.
  Set<int> _memberIds = {};

  /// Cached friend rows for the membership checklist.
  List<FriendRow> _allFriends = [];

  /// Whether this screen is editing an existing [GroupRow].
  bool get _isEditing => widget.groupId != null;

  /// Allocates [TextEditingController] and starts [_load].
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _load();
  }

  /// Loads all friends for checkboxes, then (in edit mode) the group row and member ids.
  ///
  /// Pops with a snackbar if the group id is missing. Sets [_initialized] when the form can build.
  ///
  /// Returns: future that completes when loading finishes or the route is popped.
  Future<void> _load() async {
    final friends = await widget.friendService.getAllFriends();
    if (!mounted) {
      return;
    }
    setState(() => _allFriends = friends);

    final id = widget.groupId;
    if (id == null) {
      setState(() => _initialized = true);
      return;
    }
    setState(() => _loading = true);
    final row = await widget.groupService.getGroupById(id);
    if (!mounted) {
      return;
    }
    if (row == null) {
      setState(() {
        _loading = false;
        _initialized = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group not found')),
      );
      context.pop();
      return;
    }
    _nameController.text = row.name;
    _colorArgb = row.colorArgb;
    _storedPhotoPath = row.photoPath;
    final members = await widget.groupService.getMemberIdsForGroup(id);
    if (!mounted) {
      return;
    }
    setState(() {
      _memberIds = members.toSet();
      _loading = false;
      _initialized = true;
    });
  }

  /// Disposes the group name controller.
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Opens the gallery picker and stages a path for [_syncPhotoAfterSave] (non-web only).
  ///
  /// Returns: future completing when the picker returns or the user cancels.
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
      title: 'Crop cover',
    );
    if (!mounted || croppedPath == null) {
      return;
    }
    setState(() {
      _pickedImagePath = croppedPath;
      _removeStoredPhoto = false;
    });
  }

  /// Clears staged and stored photo flags so save removes or replaces the file.
  ///
  /// Returns: nothing.
  void _clearPhoto() {
    setState(() {
      _pickedImagePath = null;
      _removeStoredPhoto = true;
    });
  }

  /// Opens a dialog with [ColorPicker] to choose an opaque accent; updates [_colorArgb].
  ///
  /// Returns: future completing when the dialog is dismissed.
  Future<void> _pickAccentColor() async {
    var draft = Color(_colorArgb);
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Accent color'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: draft,
                  onColorChanged: (c) => setDialogState(() => draft = c),
                  enableAlpha: false,
                  displayThumbColor: true,
                  pickerAreaHeightPercent: 0.72,
                ),
              );
            },
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final c = draft;
                final r = (c.r * 255.0).round().clamp(0, 255);
                final g = (c.g * 255.0).round().clamp(0, 255);
                final b = (c.b * 255.0).round().clamp(0, 255);
                setState(
                    () => _colorArgb = 0xFF000000 | (r << 16) | (g << 8) | b);
                Navigator.pop(ctx);
              },
              child: const Text('Use this color'),
            ),
          ],
        );
      },
    );
  }

  /// Validates and saves the group row, membership set, and optional cover upload.
  ///
  /// Returns: future completing after save or error snackbar.
  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    final name = _nameController.text.trim();

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        final id = widget.groupId!;
        final previous = await widget.groupService.getGroupById(id);
        await widget.groupService.updateGroup(
          id: id,
          name: name,
          colorArgb: _colorArgb,
        );
        await widget.groupService.setMembersForGroup(id, _memberIds);
        await _syncPhotoAfterSave(
            groupId: id, previousPath: previous?.photoPath);
      } else {
        final id = await widget.groupService.createGroup(
          name: name,
          colorArgb: _colorArgb,
        );
        await widget.groupService.setMembersForGroup(id, _memberIds);
        await _syncPhotoAfterSave(groupId: id, previousPath: null);
      }
      if (!mounted) {
        return;
      }
      final message =
          _isEditing ? 'Group updated' : 'Group created successfully';
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

  /// Applies [_removeStoredPhoto] and/or uploads [_pickedImagePath] to Cloudinary for [groupId].
  ///
  /// Parameters:
  /// - [groupId]: saved group primary key.
  /// - [previousPath]: last known photo URL or legacy disk path from the database, if any.
  ///
  /// Returns: future completing after upload/delete attempts and DB updates.
  Future<void> _syncPhotoAfterSave({
    required int groupId,
    required String? previousPath,
  }) async {
    if (_removeStoredPhoto && previousPath != null) {
      await GroupPhotoStorage.deleteIfExists(previousPath);
      await widget.groupService.setGroupPhotoPath(groupId, null);
    }
    final stagedPath = _pickedImagePath;
    if (stagedPath != null && !kIsWeb) {
      if (previousPath != null &&
          previousPath.isNotEmpty &&
          !_removeStoredPhoto) {
        await GroupPhotoStorage.deleteIfExists(previousPath);
      }
      final saved =
          await GroupPhotoStorage.saveForGroupFromPath(groupId, stagedPath);
      await widget.groupService.setGroupPhotoPath(groupId, saved);
    }
  }

  /// Confirms and deletes the current group (members remain as friends; links removed).
  ///
  /// Returns: future completing after delete or cancel.
  Future<void> _confirmDelete() async {
    final id = widget.groupId;
    if (id == null) {
      return;
    }
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete group?'),
            content: const Text(
              'Friends stay in your list—only this group and its cover photo link are removed.',
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
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
    await widget.groupService.deleteGroup(id);
    if (!mounted) {
      return;
    }
    showAppSnackBar('Group removed');
    context.go('/friends');
  }

  /// Large circular preview at the top: staged file, stored file, or accent fallback + [Hero].
  ///
  /// Parameters:
  /// - [scheme]: active [ColorScheme] for placeholder surfaces.
  ///
  /// Returns: avatar-sized widget for the form header.
  Widget _buildPhotoPreview(ColorScheme scheme) {
    final accent = Color(_colorArgb);
    final fallback = CircleAvatar(
      radius: 56,
      backgroundColor: accent.withValues(alpha: 0.35),
      child: Icon(Icons.groups_rounded, size: 52, color: accent),
    );
    final heroTag = 'group_avatar_${widget.groupId ?? 'new'}';
    if (!kIsWeb && _pickedImagePath != null) {
      return Hero(
        tag: heroTag,
        child: Material(
          type: MaterialType.transparency,
          child: buildLocalFileAvatar(
            absolutePath: _pickedImagePath,
            radius: 56,
            fallback: fallback,
          ),
        ),
      );
    }
    if (!_removeStoredPhoto &&
        _storedPhotoPath != null &&
        _storedPhotoPath!.isNotEmpty) {
      return Hero(
        tag: heroTag,
        child: Material(
          type: MaterialType.transparency,
          child: buildLocalFileAvatar(
            absolutePath: _storedPhotoPath,
            radius: 56,
            fallback: fallback,
          ),
        ),
      );
    }
    return Hero(
      tag: heroTag,
      child: fallback,
    );
  }

  bool get _canClearPhoto =>
      _pickedImagePath != null ||
      (_storedPhotoPath != null &&
          _storedPhotoPath!.isNotEmpty &&
          !_removeStoredPhoto);

  /// Builds the scrollable form, or a loading scaffold until [_initialized] is true.
  ///
  /// Parameters:
  /// - [context]: build context.
  ///
  /// Returns: full-screen editor layout with bottom primary button.
  @override
  Widget build(BuildContext context) {
    if (!_initialized || _loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final scheme = Theme.of(context).colorScheme;
    final topInset = MediaQuery.paddingOf(context).top;
    final accent = Color(_colorArgb);

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
                    _isEditing ? 'Edit group' : 'New group',
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
                          child: const Text('Remove photo')),
                    ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Group name',
                      hintText: 'e.g. College crew',
                    ),
                    validator: validateFriendName,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Accent color',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _pickAccentColor,
                    icon: CircleAvatar(
                      radius: 12,
                      backgroundColor: accent,
                      child: const SizedBox.shrink(),
                    ),
                    label: Text(
                      '#${(_colorArgb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'Friends in this group',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${_memberIds.length} selected',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_allFriends.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Add people from the Friends screen, or assign them when editing each friend.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    )
                  else
                    ..._allFriends.map((f) {
                      final on = _memberIds.contains(f.id);
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: on
                              ? Color(_colorArgb).withValues(alpha: 0.12)
                              : scheme.surfaceContainerHighest
                                  .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: on
                                ? Color(_colorArgb).withValues(alpha: 0.55)
                                : scheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: CheckboxListTile(
                          value: on,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _memberIds.add(f.id);
                              } else {
                                _memberIds.remove(f.id);
                              }
                            });
                          },
                          title: Text(
                            f.name,
                            style: TextStyle(
                              fontWeight:
                                  on ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          secondary: CircleAvatar(
                            backgroundColor:
                                scheme.primaryContainer.withValues(alpha: 0.5),
                            child: Text(
                              f.name.isNotEmpty
                                  ? f.name.substring(0, 1).toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                    }),
                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: _confirmDelete,
                      style:
                          TextButton.styleFrom(foregroundColor: scheme.error),
                      child: const Text('Delete group'),
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
                label: _isEditing ? 'Save group' : 'Create group',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
