import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

/// Whether the device can read contacts for phone import (mobile only).
bool get contactPhoneImportSupported =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// Requests contacts access, lets the user pick a contact, then returns a phone string.
///
/// Returns `null` when unsupported, denied, cancelled, or no numbers found.
Future<String?> pickContactPhoneNumber(BuildContext context) async {
  if (!contactPhoneImportSupported) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact import is available on mobile installs only.'),
        ),
      );
    }
    return null;
  }

  final granted = await FlutterContacts.requestPermission(readonly: true);
  if (!granted) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contacts permission is needed to import a number.'),
        ),
      );
    }
    return null;
  }

  final contacts = await FlutterContacts.getContacts(
    withProperties: true,
    withPhoto: false,
  );
  final withPhones = contacts.where((c) => c.phones.isNotEmpty).toList()
    ..sort(
      (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );

  if (!context.mounted) {
    return null;
  }
  if (withPhones.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No contacts with phone numbers found.')),
    );
    return null;
  }

  final contact = await showModalBottomSheet<Contact>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _ContactPhonePickerSheet(contacts: withPhones),
  );
  if (contact == null || !context.mounted) {
    return null;
  }

  if (contact.phones.length == 1) {
    return contact.phones.first.number.trim();
  }

  final phone = await showDialog<Phone>(
    context: context,
    builder: (ctx) {
      return SimpleDialog(
        title: const Text('Pick a number'),
        children: [
          for (final entry in contact.phones)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, entry),
              child: Text(_phoneOptionLabel(entry)),
            ),
        ],
      );
    },
  );
  return phone?.number.trim();
}

String _phoneOptionLabel(Phone phone) {
  final label = phone.label.name;
  if (label.isEmpty || label == 'custom') {
    return phone.number;
  }
  return '$label · ${phone.number}';
}

class _ContactPhonePickerSheet extends StatefulWidget {
  const _ContactPhonePickerSheet({required this.contacts});

  final List<Contact> contacts;

  @override
  State<_ContactPhonePickerSheet> createState() => _ContactPhonePickerSheetState();
}

class _ContactPhonePickerSheetState extends State<_ContactPhonePickerSheet> {
  late List<Contact> _filtered;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.contacts;
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = widget.contacts;
        return;
      }
      _filtered = widget.contacts.where((contact) {
        if (contact.displayName.toLowerCase().contains(query)) {
          return true;
        }
        return contact.phones.any((p) => p.number.replaceAll(RegExp(r'\D'), '').contains(query));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: maxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                'Import from contacts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search name or number',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No matches',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final contact = _filtered[index];
                        final primary = contact.phones.first.number;
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              contact.displayName.isEmpty
                                  ? '?'
                                  : contact.displayName.substring(0, 1).toUpperCase(),
                            ),
                          ),
                          title: Text(
                            contact.displayName.isEmpty ? primary : contact.displayName,
                          ),
                          subtitle: contact.displayName.isEmpty
                              ? null
                              : Text(
                                  contact.phones.length > 1
                                      ? '$primary (+${contact.phones.length - 1} more)'
                                      : primary,
                                ),
                          onTap: () => Navigator.pop(context, contact),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
