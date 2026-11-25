import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';

/// Shows every field of one [Experience].
///
/// Optional data is only shown when present: the employer row is hidden
/// when it's empty (the tutorial's equivalent is the optional project image
/// URL), and an ongoing experience shows "Present" as its end date.
class ExperienceDetailScreen extends StatelessWidget {
  const ExperienceDetailScreen({required this.experience, super.key});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final end = experience.isOngoing
        ? 'Present'
        : formatDate(experience.endedAt!.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Experience Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: MyHomePage.maxContentWidth,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Chip(label: Text(experience.categoryLabel)),
                    const Divider(height: 24),
                    if (experience.employer.trim().isNotEmpty)
                      _DetailRow(
                        Icons.business,
                        'Employer',
                        experience.employer,
                      ),
                    _DetailRow(
                      Icons.date_range,
                      'Period',
                      '${formatDate(experience.startedAt.toLocal())} – $end',
                    ),
                    _DetailRow(
                      Icons.star_outline,
                      'Stars',
                      '${experience.starCount}',
                    ),
                    _DetailRow(
                      Icons.notes,
                      'Description',
                      experience.description,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An icon, a bold label and its value, stacked so long text wraps.
class _DetailRow extends StatelessWidget {
  const _DetailRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
