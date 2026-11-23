/// Pure validation helpers shared by the portfolio forms.
///
/// Each function follows the [FormFieldValidator] contract: it returns
/// `null` when the value is valid, or an error message that the form field
/// shows under the input. Keeping them here (instead of inline lambdas)
/// keeps the screens short and lets the rules be unit-tested on their own.
library;

/// Rejects an empty or whitespace-only [value] and enforces optional
/// [minLength] / [maxLength] limits on the trimmed text.
///
/// Example: `requiredText('   ', 'Institution')` returns
/// `'Institution is required.'`, because spaces alone are not a real value.
String? requiredText(
  String? value,
  String fieldName, {
  int? minLength,
  int? maxLength,
}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return '$fieldName is required.';
  }
  if (minLength != null && text.length < minLength) {
    return '$fieldName must be at least $minLength characters.';
  }
  if (maxLength != null && text.length > maxLength) {
    return '$fieldName must be at most $maxLength characters.';
  }
  return null;
}

/// Allows an empty [value] (the field is optional) but enforces
/// [maxLength] when something is typed.
String? optionalText(
  String? value,
  String fieldName, {
  required int maxLength,
}) {
  final text = value?.trim() ?? '';
  if (text.length > maxLength) {
    return '$fieldName must be at most $maxLength characters.';
  }
  return null;
}

/// Allows an empty [value], otherwise requires an absolute `http` or
/// `https` URL with a host, matching what Django's `URLField` accepts.
///
/// Example: `optionalUrl('ui.ac.id')` and `optionalUrl('ftp://ui.ac.id')`
/// are both rejected, while `optionalUrl('https://ui.ac.id/logo.png')`
/// passes.
String? optionalUrl(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;

  final uri = Uri.tryParse(text);
  final isValid =
      uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty &&
      !text.contains(' ');
  return isValid ? null : 'Enter a valid URL starting with http:// or https://';
}

/// Validates an end date against a start date.
///
/// When [isOngoing] is `true` there is no end date to check. Otherwise the
/// end date is required and must not be earlier than [start].
String? endDateAfterStart(
  DateTime? start,
  DateTime? end, {
  required bool isOngoing,
}) {
  if (isOngoing) return null;
  if (end == null) {
    return 'Pick an end date, or mark it as ongoing.';
  }
  if (start != null && end.isBefore(start)) {
    return 'End date cannot be before the start date.';
  }
  return null;
}

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats [date] as a short, locale-free label such as `23 Nov 2026`,
/// so no extra package (e.g. `intl`) is needed.
String formatDate(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
