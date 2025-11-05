import 'package:flutter/material.dart';
import '../../models/job_site.dart';
import '../../models/job_site_task.dart';
import '../../models/job_site_photo.dart';
import '../../models/job_site_note.dart';
import '../../services/supabase_service.dart';

class JobSiteDetailPage extends StatefulWidget {
  final String jobSiteId;

  const JobSiteDetailPage({super.key, required this.jobSiteId});

  @override
  State<JobSiteDetailPage> createState() => _JobSiteDetailPageState();
}

class _JobSiteDetailPageState extends State<JobSiteDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  JobSite? _jobSite;
  List<JobSiteTask> _tasks = [];
  List<JobSitePhoto> _photos = [];
  List<JobSiteNote> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchJobSite();
    _fetchTasks();
    _fetchPhotos();
    _fetchNotes();
  }

  Future<void> _fetchJobSite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jobSite = await SupabaseService.getJobSiteById(widget.jobSiteId);
      if (mounted) {
        setState(() {
          _jobSite = jobSite;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement du chantier: ${e.toString()}")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchTasks() async {
    try {
      final tasks = await SupabaseService.getTasksForJobSite(widget.jobSiteId);
      if (mounted) {
        setState(() {
          _tasks = tasks;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des tâches: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _fetchPhotos() async {
    try {
      final photos = await SupabaseService.getJobSitePhotosForJobSite(widget.jobSiteId);
      if (mounted) {
        setState(() {
          _photos = photos;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des photos: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _fetchNotes() async {
    try {
      final notes = await SupabaseService.getNotesForJobSite(widget.jobSiteId);
      if (mounted) {
        setState(() {
          _notes = notes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des notes: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_jobSite?.jobName ?? 'Chantier'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aperçu'),
            Tab(text: 'Finances'),
            Tab(text: 'Tâches'),
            Tab(text: 'Photos'),
            Tab(text: 'Notes'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildFinancialTab(),
                _buildTasksTab(),
                _buildPhotosTab(),
                _buildNotesTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    if (_jobSite == null) return const Center(child: Text('Aucun détail de chantier disponible.'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nom du chantier: ${_jobSite!.jobName}'),
          Text('Adresse: ${_jobSite!.address ?? 'N/A'}'),
          Text('Statut: ${_jobSite!.status ?? 'N/A'}'),
        ],
      ),
    );
  }

  Widget _buildFinancialTab() {
    if (_jobSite == null) return const Center(child: Text('Aucun détail financier disponible.'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Budget estimé: ${_jobSite!.estimatedBudget ?? 'N/A'}'),
          Text('Coût réel: ${_jobSite!.actualCost ?? 'N/A'}'),
          Text('Marge de profit: ${_jobSite!.profitMargin ?? 'N/A'}'),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return CheckboxListTile(
          title: Text(task.taskDescription),
          value: task.isCompleted,
          onChanged: (value) {
            // TODO: Update task status
          },
        );
      },
    );
  }

  Widget _buildPhotosTab() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return Card(
          child: Image.network(photo.photoUrl, fit: BoxFit.cover),
        );
      },
    );
  }

  Widget _buildNotesTab() {
    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return ListTile(
          title: Text(note.noteText),
          subtitle: Text(note.createdAt.toString()),
        );
      },
    );
  }
}
