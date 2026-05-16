import 'package:url_launcher/url_launcher.dart';

/// Parses optional phone input for storage (trimmed) or `null` when empty.
String? normalizeFriendPhoneInput(String? raw) {
  final trimmed = raw?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

/// Digits only, suitable for `tel:` and `wa.me` (no leading `+`).
String phoneDigitsOnly(String stored) {
  return stored.replaceAll(RegExp(r'\D'), '');
}

/// Human-readable label for detail UI (keeps leading `+` when user entered it).
String formatFriendPhoneDisplay(String stored) {
  final trimmed = stored.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }
  if (trimmed.startsWith('+')) {
    final digits = phoneDigitsOnly(trimmed);
    if (digits.isEmpty) {
      return trimmed;
    }
    final buf = StringBuffer('+');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buf.write(' ');
      }
      buf.write(digits[i]);
    }
    return buf.toString();
  }
  return trimmed;
}

/// Opens the system dialer for [storedPhone].
Future<bool> launchFriendPhoneCall(String storedPhone) async {
  final digits = phoneDigitsOnly(storedPhone);
  if (digits.isEmpty) {
    return false;
  }
  final uri = Uri(scheme: 'tel', path: digits);
  if (!await canLaunchUrl(uri)) {
    return false;
  }
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Opens WhatsApp chat for [storedPhone] (`wa.me`, then `whatsapp://` fallback).
Future<bool> launchFriendWhatsApp(String storedPhone) async {
  final digits = phoneDigitsOnly(storedPhone);
  if (digits.isEmpty) {
    return false;
  }
  final web = Uri.parse('https://wa.me/$digits');
  if (await canLaunchUrl(web)) {
    return launchUrl(web, mode: LaunchMode.externalApplication);
  }
  final app = Uri.parse('whatsapp://send?phone=$digits');
  if (await canLaunchUrl(app)) {
    return launchUrl(app, mode: LaunchMode.externalApplication);
  }
  return false;
}
