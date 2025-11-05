import 'package:flutter/material.dart';
import '../../models/job_site.dart';
import '../../services/supabase_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Chantiers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to JobSiteFormPage
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _jobSites.length,
              itemBuilder: (context, index) {
                final jobSite = _jobSites[index];
                return Card(
                  child: ListTile(
                    title: Text(jobSite.jobName),
                    subtitle: Text(jobSite.address ?? 'N/A'),
                    trailing: Text(jobSite.status ?? 'N/A'),
                    onTap: () {
                      // TODO: Navigate to JobSiteDetailPage
                    },
                  ),
                );
              },
            ),
    );
  }
}
