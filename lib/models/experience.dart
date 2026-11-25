import 'package:json_annotation/json_annotation.dart';

part 'experience.g.dart';

/// One portfolio experience, synchronized with the Django REST Framework
/// endpoint `/api/v1/experience/` (`ExperienceSerializer` in Django).
///
/// Tutorial 10 uses a "Project" example; in this portfolio the tutorial
/// section is Experience (same mapping as Tutorial 7).
///
/// `FieldRename.snake` maps Dart camelCase fields to DRF snake_case keys,
/// e.g. `startedAt` <-> `started_at`.
@JsonSerializable(fieldRename: FieldRename.snake)
class Experience {
  const Experience({
    required this.title,
    required this.description,
    required this.category,
    required this.startedAt,
    this.employer = '',
    this.endedAt,
    this.id,
    this.starCount = 0,
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  /// Category values accepted by Django (`Experience.EXPERIENCE_CHOICES`),
  /// mapped to their display labels.
  static const Map<String, String> categories = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  /// UUID assigned by the server. Never sent in a POST body.
  @JsonKey(includeToJson: false)
  final String? id;

  final String title;

  /// Optional in Django (`null=True`), so `null` becomes an empty string.
  @JsonKey(defaultValue: '')
  final String employer;

  final String description;

  /// One of the keys in [categories], e.g. `part-time`.
  final String category;

  @JsonKey(toJson: _dateTimeToJson)
  final DateTime startedAt;

  /// `null` means the experience is still ongoing.
  @JsonKey(toJson: _nullableDateTimeToJson)
  final DateTime? endedAt;

  /// Read-only star count computed by the server.
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  /// Display label of [category], falling back to the raw value.
  String get categoryLabel => categories[category] ?? category;

  /// Whether there is no end date yet.
  bool get isOngoing => endedAt == null;

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}

/// Sends dates as UTC ISO-8601 (e.g. `2026-11-01T17:00:00.000Z`), so Django
/// (`USE_TZ = True`) never receives a naive datetime.
String _dateTimeToJson(DateTime value) => value.toUtc().toIso8601String();

String? _nullableDateTimeToJson(DateTime? value) =>
    value == null ? null : _dateTimeToJson(value);
