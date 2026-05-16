// Form validation helpers for friend editing.

/// Trims and validates a display name.
///
/// Parameters:
/// - [value]: raw text field value.
///
/// Returns: `null` if valid, otherwise an error message for the UI.
String? validateFriendName(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'Please enter a name';
  }
  if (trimmed.length > 128) {
    return 'Name is too long';
  }
  return null;
}

/// Validates reminder interval in days (1–365).
///
/// Parameters:
/// - [value]: raw text field value.
///
/// Returns: `null` if valid, otherwise an error message for the UI.
String? validateReminderIntervalDays(String? value) {
  final raw = value?.trim() ?? '';
  final n = int.tryParse(raw);
  if (n == null) {
    return 'Enter a number of days';
  }
  if (n < 1 || n > 365) {
    return 'Use a number between 1 and 365';
  }
  return null;
}

/// Optional mobile number (7–15 digits after stripping spaces/symbols).
String? validateOptionalPhone(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }
  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 7) {
    return 'Enter at least 7 digits';
  }
  if (digits.length > 15) {
    return 'Number is too long';
  }
  return null;
}

/// Optional single-line context fields (last chat, how we met).
String? validateOptionalShortLine(String? value, {int maxLength = 200}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }
  if (trimmed.length > maxLength) {
    return 'Keep it under $maxLength characters';
  }
  return null;
}
