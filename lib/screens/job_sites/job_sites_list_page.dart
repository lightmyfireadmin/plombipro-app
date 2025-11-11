import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/job_site.dart';
import '../../services/supabase_service.dart';
import '../../widgets/modern/empty_state_widget.dart';
import '../../config/plombipro_colors.dart';

class JobSitesListPage extends StatefulWidget {
  const JobSitesListPage({super.key});

  @override
  State<JobSitesListPage> createState() => _JobSitesListPageState();
}

class _JobSitesListPageState extends State<JobSitesListPage> {
  bool _isLoading = true;
  List<JobSite> _jobSites = [];

  @override
  void initState() {
    super.initState();
    _fetchJobSites();
  }

  Future<void> _fetchJobSites() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final jobSites = await SupabaseService.getJobSites();
      if (mounted) {
        setState(() {
          _jobSites = jobSites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des chantiers: ${e.toString()}")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget.noJobSites(
      onAddJobSite: () {
        context.push('/job-sites/new').then((_) => _fetchJobSites());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Chantiers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/job-sites/new').then((_) => _fetchJobSites());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jobSites.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _jobSites.length,
                  itemBuilder: (context, index) {
                    final jobSite = _jobSites[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          jobSite.jobName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (jobSite.address != null)
                              Text(jobSite.address!),
                            if (jobSite.city != null)
                              Text('${jobSite.postalCode ?? ''} ${jobSite.city}'),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            jobSite.status ?? 'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: _getStatusColor(jobSite.status),
                        ),
                        onTap: () {
                          // Navigate to job site detail page
                          context.push('/job-sites/${jobSite.id}');
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: _jobSites.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () {
                context.push('/job-sites/new').then((_) => _fetchJobSites());
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'en cours':
      case 'in_progress':
        return PlombiProColors.primaryBlue.withOpacity(0.2);
      case 'terminé':
      case 'completed':
        return PlombiProColors.success.withOpacity(0.2);
      case 'en attente':
      case 'pending':
        return PlombiProColors.warning.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}
