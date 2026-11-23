import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Screen with a form for adding an education entry to the portfolio.
///
/// The fields mirror the Django `Education` model of the portfolio website:
/// `institution` (max 255), optional `program` (max 255), `level` (choice),
/// `description`, optional `logo` (URL), `started_at` and optional
/// `ended_at` (`null` means the education is still ongoing).
///
/// It is a [StatefulWidget] because the selected level, dates and the
/// "currently studying" switch change while the user fills in the form.
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  /// Level choices, matching `Education.LEVEL_CHOICES` in Django.
  static const List<String> levels = [
    'University',
    'High School',
    'Middle School',
  ];

  /// Max length of `institution` and `program` (`CharField(max_length=255)`).
  static const int maxNameLength = 255;

  /// Minimum description length, so one-word descriptions are rejected.
  static const int minDescriptionLength = 10;

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  /// Gives access to the [FormState] to validate and reset the whole form.
  final _formKey = GlobalKey<FormState>();

  // Controllers keep the typed text so it can be shown in the summary
  // dialog and cleared after saving.
  final _institutionController = TextEditingController();
  final _programController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _logoController = TextEditingController();

  // Read-only fields that display the dates chosen with showDatePicker().
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String _level = EducationFormPage.levels.first;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;

  /// Becomes `true` after the first Save, so errors then update while typing
  /// instead of only on the next press.
  bool _submitted = false;

  @override
  void dispose() {
    _institutionController.dispose();
    _programController.dispose();
    _descriptionController.dispose();
    _logoController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  /// Opens the date picker and stores the chosen start or end date.
  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? _startDate : (_endDate ?? _startDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year + 10),
      helpText: isStart ? 'Select start date' : 'Select end date',
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        _startDateController.text = formatDate(picked);
      } else {
        _endDate = picked;
        _endDateController.text = formatDate(picked);
      }
    });
  }

  /// Turns the "currently studying here" switch on or off. An ongoing
  /// education has no end date, so the end date is cleared.
  void _setOngoing(bool value) {
    setState(() {
      _isOngoing = value;
      if (value) {
        _endDate = null;
        _endDateController.clear();
      }
    });
  }

  /// Validates every field and, if all pass, shows the summary dialog.
  void _save() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Education saved!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow('Institution', _institutionController.text),
                _SummaryRow('Program', _programController.text),
                _SummaryRow('Level', _level),
                _SummaryRow('Description', _descriptionController.text),
                _SummaryRow('Logo URL', _logoController.text),
                _SummaryRow('Start date', formatDate(_startDate!)),
                _SummaryRow(
                  'End date',
                  _isOngoing ? 'Present (ongoing)' : formatDate(_endDate!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _resetForm();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Clears every field so another entry can be added.
  void _resetForm() {
    _formKey.currentState!.reset();
    for (final controller in [
      _institutionController,
      _programController,
      _descriptionController,
      _logoController,
      _startDateController,
      _endDateController,
    ]) {
      controller.clear();
    }
    setState(() {
      _level = EducationFormPage.levels.first;
      _startDate = null;
      _endDate = null;
      _isOngoing = false;
      _submitted = false;
    });
  }

  /// Shared look for every input: outlined border with a label and icon.
  InputDecoration _decoration(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const gap = SizedBox(height: 16.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Education',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // Same colors as the home screen AppBar.
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        // Scrolls so every field and the Save button stay reachable on
        // short screens or while the keyboard covers the bottom half.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            // Same max width as the home screen, so it stays readable on web.
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: MyHomePage.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // === Institution (required, max 255) ===
                  TextFormField(
                    key: const Key('institutionField'),
                    controller: _institutionController,
                    decoration: _decoration(
                      'Institution *',
                      Icons.account_balance,
                      hint: 'e.g. Universitas Indonesia',
                    ),
                    maxLength: EducationFormPage.maxNameLength,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (value) => requiredText(
                      value,
                      'Institution',
                      maxLength: EducationFormPage.maxNameLength,
                    ),
                  ),
                  gap,

                  // === Program (optional, max 255) ===
                  TextFormField(
                    key: const Key('programField'),
                    controller: _programController,
                    decoration: _decoration(
                      'Program / Major',
                      Icons.menu_book,
                      hint: 'e.g. S1 Ilmu Komputer KKI (optional)',
                    ),
                    maxLength: EducationFormPage.maxNameLength,
                    textInputAction: TextInputAction.next,
                    validator: (value) => optionalText(
                      value,
                      'Program',
                      maxLength: EducationFormPage.maxNameLength,
                    ),
                  ),
                  gap,

                  // === Level (choice) ===
                  DropdownButtonFormField<String>(
                    key: const Key('levelField'),
                    initialValue: _level,
                    // Fill the field width (and ellipsize long items)
                    // instead of sizing to the widest item, which
                    // overflowed on 320px-wide phones.
                    isExpanded: true,
                    decoration: _decoration('Level *', Icons.school),
                    items: EducationFormPage.levels
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _level = value!),
                  ),
                  gap,

                  // === Description (required) ===
                  TextFormField(
                    key: const Key('descriptionField'),
                    controller: _descriptionController,
                    decoration: _decoration(
                      'Description *',
                      Icons.notes,
                      hint: 'What did you study or achieve there?',
                    ),
                    minLines: 3,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    validator: (value) => requiredText(
                      value,
                      'Description',
                      minLength: EducationFormPage.minDescriptionLength,
                    ),
                  ),
                  gap,

                  // === Logo URL (optional, must be http/https) ===
                  TextFormField(
                    key: const Key('logoField'),
                    controller: _logoController,
                    decoration: _decoration(
                      'Logo URL',
                      Icons.link,
                      hint: 'https://... (optional)',
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    validator: optionalUrl,
                  ),
                  gap,

                  // === Start date (required, picked with showDatePicker) ===
                  TextFormField(
                    key: const Key('startDateField'),
                    controller: _startDateController,
                    readOnly: true,
                    decoration: _decoration(
                      'Start date *',
                      Icons.calendar_today,
                      hint: 'Tap to pick a date',
                    ),
                    onTap: () => _pickDate(isStart: true),
                    validator: (_) =>
                        _startDate == null ? 'Pick a start date.' : null,
                  ),
                  gap,

                  // === Ongoing switch (ended_at = null in Django) ===
                  SwitchListTile(
                    key: const Key('ongoingSwitch'),
                    title: const Text('Currently studying here'),
                    subtitle: const Text('No end date yet'),
                    value: _isOngoing,
                    onChanged: _setOngoing,
                    contentPadding: EdgeInsets.zero,
                  ),

                  // === End date (required unless ongoing, not before start) ===
                  TextFormField(
                    key: const Key('endDateField'),
                    controller: _endDateController,
                    readOnly: true,
                    enabled: !_isOngoing,
                    decoration: _decoration(
                      'End date',
                      Icons.event,
                      hint: _isOngoing ? 'Present' : 'Tap to pick a date',
                    ),
                    onTap: () => _pickDate(isStart: false),
                    validator: (_) => endDateAfterStart(
                      _startDate,
                      _endDate,
                      isOngoing: _isOngoing,
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // === Save button ===
                  ElevatedButton.icon(
                    key: const Key('saveButton'),
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One `label: value` line in the summary dialog. Empty optional values
/// are shown as `-` so the user can see they were left blank.
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final display = value.trim().isEmpty ? '-' : value.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: display),
          ],
        ),
      ),
    );
  }
}
