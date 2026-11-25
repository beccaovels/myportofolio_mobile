import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Form that creates a new experience through
/// `POST /api/v1/experience/` with the logged-in user's token.
///
/// Replaces the Tutorial 09 mock "Add Project" form. The inputs now match
/// Django's `ExperienceSerializer`: title (max 255), optional employer
/// (max 255), description, category, started_at and optional ended_at.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  /// `CharField(max_length=255)` for title and employer.
  static const int maxLength = 255;

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _employerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String _category = 'full-time'; // Django's default
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;
  bool _submitted = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final controller in [
      _titleController,
      _employerController,
      _descriptionController,
      _startDateController,
      _endDateController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

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

  void _setOngoing(bool value) {
    setState(() {
      _isOngoing = value;
      if (value) {
        _endDate = null;
        _endDateController.clear();
      }
    });
  }

  Experience _buildExperience() => Experience(
    title: _titleController.text.trim(),
    employer: _employerController.text.trim(),
    description: _descriptionController.text.trim(),
    category: _category,
    startedAt: _startDate!,
    endedAt: _isOngoing ? null : _endDate,
  );

  /// Validates, makes sure the user is logged in, then POSTs to the API.
  ///
  /// On 401 (token expired or revoked) the user is logged out and asked to
  /// log in again, and the request is retried once with the new token.
  Future<void> _submit({bool isRetry = false}) async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    if (!await ensureLoggedIn(context) || !mounted) return;
    final auth = context.read<AuthState>();
    final api = context.read<ApiClient>();

    setState(() => _isSubmitting = true);
    Experience? saved;
    var sessionExpired = false;
    try {
      saved = await api.createExperience(
        _buildExperience(),
        token: auth.token!,
      );
    } on ApiException catch (error) {
      if (error.statusCode == 401 && !isRetry) {
        sessionExpired = true;
      } else if (mounted) {
        _showSnackBar('Could not save (${error.statusCode}): ${error.message}');
      }
    } on Exception {
      if (mounted) {
        _showSnackBar("Can't reach the server. Check your connection.");
      }
    } finally {
      // Reset before any dialog or re-login, so the spinner never keeps
      // running behind them.
      if (mounted) setState(() => _isSubmitting = false);
    }
    if (!mounted) return;

    if (sessionExpired) {
      await auth.logout();
      if (!mounted) return;
      _showSnackBar('Your session expired. Please log in again.');
      await _submit(isRetry: true);
    } else if (saved != null) {
      await _showSavedDialog(saved);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Confirmation shown after `201 Created`, with the values the server
  /// saved. OK closes it and clears the form for the next entry.
  Future<void> _showSavedDialog(Experience saved) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Experience saved!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryRow('Title', saved.title),
              _SummaryRow('Employer', saved.employer),
              _SummaryRow('Category', saved.categoryLabel),
              _SummaryRow('Description', saved.description),
              _SummaryRow('Start date', formatDate(saved.startedAt.toLocal())),
              _SummaryRow(
                'End date',
                saved.isOngoing
                    ? 'Present (ongoing)'
                    : formatDate(saved.endedAt!.toLocal()),
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
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    for (final controller in [
      _titleController,
      _employerController,
      _descriptionController,
      _startDateController,
      _endDateController,
    ]) {
      controller.clear();
    }
    setState(() {
      _category = 'full-time';
      _startDate = null;
      _endDate = null;
      _isOngoing = false;
      _submitted = false;
    });
  }

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
          'Add Experience',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: MyHomePage.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('titleField'),
                    controller: _titleController,
                    decoration: _decoration(
                      'Title *',
                      Icons.work_outline,
                      hint: 'e.g. Teaching Assistant',
                    ),
                    maxLength: ExperienceFormPage.maxLength,
                    textInputAction: TextInputAction.next,
                    validator: (value) => requiredText(
                      value,
                      'Title',
                      maxLength: ExperienceFormPage.maxLength,
                    ),
                  ),
                  gap,
                  TextFormField(
                    key: const Key('employerField'),
                    controller: _employerController,
                    decoration: _decoration(
                      'Employer',
                      Icons.business,
                      hint: 'e.g. Fasilkom UI (optional)',
                    ),
                    maxLength: ExperienceFormPage.maxLength,
                    textInputAction: TextInputAction.next,
                    validator: (value) => optionalText(
                      value,
                      'Employer',
                      maxLength: ExperienceFormPage.maxLength,
                    ),
                  ),
                  gap,
                  DropdownButtonFormField<String>(
                    key: const Key('categoryField'),
                    initialValue: _category,
                    isExpanded: true,
                    decoration: _decoration('Category *', Icons.category),
                    items: Experience.categories.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _category = value!),
                  ),
                  gap,
                  TextFormField(
                    key: const Key('descriptionField'),
                    controller: _descriptionController,
                    decoration: _decoration(
                      'Description *',
                      Icons.notes,
                      hint: 'What did you do there?',
                    ),
                    minLines: 3,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    validator: (value) => requiredText(value, 'Description'),
                  ),
                  gap,
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
                  SwitchListTile(
                    key: const Key('ongoingSwitch'),
                    title: const Text('I currently work here'),
                    subtitle: const Text('No end date yet'),
                    value: _isOngoing,
                    onChanged: _setOngoing,
                    contentPadding: EdgeInsets.zero,
                  ),
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
                  ElevatedButton.icon(
                    key: const Key('saveButton'),
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
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

/// One `label: value` line in the confirmation dialog; empty values show `-`.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;

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
