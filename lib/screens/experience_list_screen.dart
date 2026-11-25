import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_detail_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Public list of experiences fetched from `GET /api/v1/experience/`.
///
/// Handles the three async states: loading (spinner), error (message +
/// Retry) and empty ("No experiences found."). Pull down to refresh.
class ExperienceListScreen extends StatefulWidget {
  const ExperienceListScreen({super.key});

  @override
  State<ExperienceListScreen> createState() => _ExperienceListScreenState();
}

class _ExperienceListScreenState extends State<ExperienceListScreen> {
  late Future<List<Experience>> _experiencesFuture;

  @override
  void initState() {
    super.initState();
    // Created once here (never in build()), so a rebuild doesn't fire a
    // new HTTP request.
    _experiencesFuture = context.read<ApiClient>().getExperiences();
  }

  Future<void> _reload() async {
    final future = context.read<ApiClient>().getExperiences();
    // Block body on purpose: an arrow (`=> _experiencesFuture = future`)
    // would return the Future, which setState() rejects.
    setState(() {
      _experiencesFuture = future;
    });
    // Errors are shown by the FutureBuilder; don't let them escape the
    // RefreshIndicator / Retry button.
    await future.then((_) {}, onError: (_) {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Experience',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<Experience>>(
        future: _experiencesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            final message = error is ApiException
                ? error.message
                : "Can't reach the server. Check your connection.";
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off, size: 48, color: colorScheme.error),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load experiences: $message',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final experiences = snapshot.data ?? const <Experience>[];

          if (experiences.isEmpty) {
            // Still scrollable, so pull-to-refresh works on an empty list.
            return RefreshIndicator(
              onRefresh: _reload,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: const Center(child: Text('No experiences found.')),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: experiences.length,
              itemBuilder: (context, index) =>
                  _ExperienceCard(experiences[index]),
            ),
          );
        },
      ),
    );
  }
}

/// One experience in the list: title, category + dates, and a short
/// description. Tapping it opens [ExperienceDetailScreen].
class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard(this.experience);

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final start = formatDate(experience.startedAt.toLocal());
    final end = experience.isOngoing
        ? 'Present'
        : formatDate(experience.endedAt!.toLocal());

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: MyHomePage.maxContentWidth),
        child: Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.work_outline),
            ),
            title: Text(
              experience.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${experience.categoryLabel} · $start – $end\n'
              '${experience.description}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExperienceDetailScreen(experience: experience),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
