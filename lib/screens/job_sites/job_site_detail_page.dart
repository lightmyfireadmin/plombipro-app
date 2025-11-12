import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import '../../models/job_site.dart';
import '../../models/job_site_task.dart';
import '../../models/job_site_photo.dart';
import '../../models/job_site_note.dart';
import '../../models/job_site_time_log.dart';
import '../../models/job_site_document.dart';
import '../../services/supabase_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'widgets/job_site_timeline_widget.dart';

/// Enhanced Job Site Detail Page with full functionality
///
/// Features:
/// - 8 tabs: Overview, Timeline, Financial, Tasks, Photos, Documents, Notes, Time Tracking
/// - Photo upload (camera/gallery)
/// - Task completion tracking
/// - Time tracking timer (start/stop/pause)
/// - Financial calculations (labor, materials, profit/loss)
/// - Progress percentage tracking
/// - Visual timeline of all events
class JobSiteDetailPage extends StatefulWidget {
  final String jobSiteId;

  const JobSiteDetailPage({super.key, required this.jobSiteId});

  @override
  State<JobSiteDetailPage> createState() => _JobSiteDetailPageState();
}

class _JobSiteDetailPageState extends State<JobSiteDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  JobSite? _jobSite;
  List<JobSiteTask> _tasks = [];
  List<JobSitePhoto> _photos = [];
  List<JobSiteNote> _notes = [];
  List<JobSiteTimeLog> _timeLogs = [];
  List<JobSiteDocument> _documents = [];
  bool _isLoading = true;

  // Time tracking
  DateTime? _timerStartTime;
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;

  // Financial calculations
  double _totalLaborCost = 0.0;
  double _totalMaterialsCost = 0.0;
  double _totalRevenue = 0.0;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _fetchAllData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    await _fetchJobSite();
    await Future.wait([
      _fetchTasks(),
      _fetchPhotos(),
      _fetchNotes(),
      _fetchTimeLogs(),
      _loadDocuments(),
    ]);
    _calculateFinancials();
  }

  Future<void> _fetchJobSite() async {
    setState(() => _isLoading = true);

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
        _showError('Erreur de chargement du chantier: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchTasks() async {
    try {
      final tasks =
          await SupabaseService.getTasksForJobSite(widget.jobSiteId);
      if (mounted) setState(() => _tasks = tasks);
    } catch (e) {
      _showError('Erreur de chargement des tâches: $e');
    }
  }

  Future<void> _fetchPhotos() async {
    try {
      final photos =
          await SupabaseService.getJobSitePhotosForJobSite(widget.jobSiteId);
      if (mounted) setState(() => _photos = photos);
    } catch (e) {
      _showError('Erreur de chargement des photos: $e');
    }
  }

  Future<void> _fetchNotes() async {
    try {
      final notes = await SupabaseService.getNotesForJobSite(widget.jobSiteId);
      if (mounted) setState(() => _notes = notes);
    } catch (e) {
      _showError('Erreur de chargement des notes: $e');
    }
  }

  Future<void> _fetchTimeLogs() async {
    try {
      final timeLogs =
          await SupabaseService.getTimeLogsForJobSite(widget.jobSiteId);
      if (mounted) setState(() => _timeLogs = timeLogs);
    } catch (e) {
      _showError('Erreur de chargement des temps: $e');
    }
  }

  void _calculateFinancials() {
    // Calculate total labor cost from time logs
    _totalLaborCost = _timeLogs.fold(
        0.0, (sum, log) => sum + (log.laborCost ?? 0.0));

    // Calculate materials cost from job site actual cost
    // This can be manually updated or linked to purchases
    _totalMaterialsCost = _jobSite?.actualCost ?? 0.0;

    // Calculate revenue from related quote/invoice
    _totalRevenue = _jobSite?.estimatedBudget ?? 0.0;

    setState(() {});
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // ==================== TASK MANAGEMENT ====================

  Future<void> _toggleTaskCompletion(JobSiteTask task) async {
    try {
      await SupabaseService.updateJobSiteTask(
        task.id,
        {
          'is_completed': !task.isCompleted,
          'completed_at': !task.isCompleted ? DateTime.now().toIso8601String() : null,
        },
      );

      await _fetchTasks();
      _updateProgress();
    } catch (e) {
      _showError('Erreur de mise à jour de la tâche: $e');
    }
  }

  Future<void> _addTask() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle tâche'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Description de la tâche',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await SupabaseService.createJobSiteTask({
          'job_site_id': widget.jobSiteId,
          'task_description': result,
          'is_completed': false,
        });

        await _fetchTasks();
      } catch (e) {
        _showError('Erreur d\\'ajout de la tâche: $e');
      }
    }
  }

  void _updateProgress() {
    if (_tasks.isEmpty) return;

    final completedCount = _tasks.where((t) => t.isCompleted).length;
    final progressPercentage = ((completedCount / _tasks.length) * 100).round();

    SupabaseService.updateJobSite(widget.jobSiteId, {
      'progress_percentage': progressPercentage,
    });

    _fetchJobSite();
  }

  // ==================== PHOTO MANAGEMENT ====================

  Future<void> _addPhoto(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);

      if (image == null) return;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Upload to Supabase Storage
      final file = File(image.path);
      final fileName = 'job_site_${widget.jobSiteId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final photoUrl = await SupabaseService.uploadPhoto(file, fileName);

      // Create photo record
      await SupabaseService.createJobSitePhoto({
        'job_site_id': widget.jobSiteId,
        'photo_url': photoUrl,
        'photo_type': 'progress', // before, progress, after
        'description': 'Photo du chantier',
      });

      Navigator.pop(context); // Close loading dialog

      await _fetchPhotos();
      _showError('Photo ajoutée avec succès');
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showError('Erreur d\\'ajout de la photo: $e');
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _addPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir dans la galerie'),
              onTap: () {
                Navigator.pop(context);
                _addPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TIME TRACKING ====================

  void _startTimer() {
    _timerStartTime = DateTime.now();
    _isTimerRunning = true;
    _isTimerPaused = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = DateTime.now().difference(_timerStartTime!);
      });
    });

    setState(() {});
  }

  void _pauseTimer() {
    _timer?.cancel();
    _isTimerPaused = true;
    setState(() {});
  }

  void _resumeTimer() {
    _timerStartTime = DateTime.now().subtract(_elapsedTime);
    _isTimerPaused = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = DateTime.now().difference(_timerStartTime!);
      });
    });

    setState(() {});
  }

  Future<void> _stopTimer() async {
    _timer?.cancel();

    // Show dialog to enter hourly rate and description
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        final rateController = TextEditingController(text: '50.0');
        final descController = TextEditingController();

        return AlertDialog(
          title: const Text('Enregistrer le temps'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Durée: ${_formatDuration(_elapsedTime)}'),
              const SizedBox(height: 16),
              TextField(
                controller: rateController,
                decoration: const InputDecoration(
                  labelText: 'Taux horaire (€/h)',
                  prefixText: '€ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, {
                'hourlyRate': double.tryParse(rateController.text) ?? 50.0,
                'description': descController.text,
              }),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final hoursWorked = _elapsedTime.inSeconds / 3600;
      final hourlyRate = result['hourlyRate'] as double;
      final laborCost = hoursWorked * hourlyRate;

      try {
        await SupabaseService.createTimeLog({
          'job_site_id': widget.jobSiteId,
          'log_date': DateTime.now().toIso8601String(),
          'hours_worked': hoursWorked,
          'hourly_rate': hourlyRate,
          'labor_cost': laborCost,
          'description': result['description'],
        });

        _elapsedTime = Duration.zero;
        _isTimerRunning = false;
        _isTimerPaused = false;

        await _fetchTimeLogs();
        _calculateFinancials();

        _showError('Temps enregistré: ${hoursWorked.toStringAsFixed(2)}h = ${laborCost.toStringAsFixed(2)}€');
      } catch (e) {
        _showError('Erreur d\\'enregistrement: $e');
      }
    }

    setState(() {});
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  // ==================== BUILD METHODS ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_jobSite?.jobName ?? 'Chantier'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Aperçu'),
            Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
            Tab(icon: Icon(Icons.euro), text: 'Finances'),
            Tab(icon: Icon(Icons.checklist), text: 'Tâches'),
            Tab(icon: Icon(Icons.photo), text: 'Photos'),
            Tab(icon: Icon(Icons.folder), text: 'Documents'),
            Tab(icon: Icon(Icons.notes), text: 'Notes'),
            Tab(icon: Icon(Icons.timer), text: 'Temps'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTimelineTab(),
                _buildFinancialTab(),
                _buildTasksTab(),
                _buildPhotosTab(),
                _buildDocumentsTab(),
                _buildNotesTab(),
                _buildTimeTrackingTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    if (_jobSite == null) {
      return const Center(child: Text('Aucun détail disponible'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _jobSite!.jobName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (_jobSite!.address != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_jobSite!.address!)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text('Début: ${_jobSite!.startDate?.toString().split(' ')[0] ?? 'N/A'}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progression',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${_jobSite!.progressPercentage}%',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _jobSite!.progressPercentage / 100,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Tâches', '${_tasks.where((t) => t.isCompleted).length}/${_tasks.length}'),
                      _buildStatCard('Photos', '${_photos.length}'),
                      _buildStatCard('Notes', '${_notes.length}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_jobSite!.description != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_jobSite!.description!),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTimelineTab() {
    if (_jobSite == null) {
      return const Center(child: Text('Aucun détail disponible'));
    }

    return JobSiteTimelineWidget(
      jobSite: _jobSite!,
      tasks: _tasks,
      notes: _notes,
      photos: _photos,
      timeLogs: _timeLogs,
    );
  }

  Widget _buildFinancialTab() {
    if (_jobSite == null) {
      return const Center(child: Text('Aucun détail disponible'));
    }

    final profit = _totalRevenue - _totalLaborCost - _totalMaterialsCost;
    final profitMargin = _totalRevenue > 0 ? (profit / _totalRevenue) * 100 : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Revenu estimé', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '${_totalRevenue.toStringAsFixed(2)} €',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Coûts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildFinancialRow('Main d\\'œuvre', _totalLaborCost, Colors.orange),
                  const Divider(),
                  _buildFinancialRow('Matériaux', _totalMaterialsCost, Colors.blue),
                  const Divider(thickness: 2),
                  _buildFinancialRow('Total Coûts', _totalLaborCost + _totalMaterialsCost, Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: profit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    profit >= 0 ? 'Profit' : 'Perte',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${profit.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: profit >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Marge: ${profitMargin.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 16,
                      color: profit >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            '${amount.toStringAsFixed(2)} €',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    return Column(
      children: [
        Expanded(
          child: _tasks.isEmpty
              ? const Center(child: Text('Aucune tâche'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return CheckboxListTile(
                      title: Text(
                        task.taskDescription ?? 'Sans description',
                        style: TextStyle(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: task.completedAt != null
                          ? Text('Complétée: ${task.completedAt!.toString().split(' ')[0]}')
                          : null,
                      value: task.isCompleted,
                      onChanged: (value) => _toggleTaskCompletion(task),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _addTask,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une tâche'),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosTab() {
    return Column(
      children: [
        Expanded(
          child: _photos.isEmpty
              ? const Center(child: Text('Aucune photo'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    final photo = _photos[index];
                    return GestureDetector(
                      onTap: () => _showFullScreenImage(photo.photoUrl),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          photo.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 64),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _showPhotoOptions,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Ajouter une photo'),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab() {
    return Column(
      children: [
        Expanded(
          child: _documents.isEmpty
              ? const Center(child: Text('Aucun document'))
              : ListView.builder(
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final doc = _documents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(JobSiteDocument.getIconForType(doc.documentType)),
                        ),
                        title: Text(doc.documentName),
                        subtitle: Text('${doc.documentType} • ${doc.formattedFileSize}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () => _openDocument(doc.documentUrl),
                              tooltip: 'Ouvrir',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteDocument(doc.id),
                              tooltip: 'Supprimer',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _uploadDocument,
            icon: const Icon(Icons.upload_file),
            label: const Text('Ajouter un document'),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesTab() {
    return Column(
      children: [
        Expanded(
          child: _notes.isEmpty
              ? const Center(child: Text('Aucune note'))
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(note.noteText),
                        subtitle: Text(note.createdAt.toString().split('.')[0]),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _showAddNoteDialog,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une note'),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeTrackingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    _formatDuration(_elapsedTime),
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_isTimerRunning)
                        ElevatedButton.icon(
                          onPressed: _startTimer,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Démarrer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      if (_isTimerRunning && !_isTimerPaused)
                        ElevatedButton.icon(
                          onPressed: _pauseTimer,
                          icon: const Icon(Icons.pause),
                          label: const Text('Pause'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      if (_isTimerRunning && _isTimerPaused)
                        ElevatedButton.icon(
                          onPressed: _resumeTimer,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Reprendre'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      if (_isTimerRunning) ...[
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _stopTimer,
                          icon: const Icon(Icons.stop),
                          label: const Text('Arrêter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historique des temps',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  if (_timeLogs.isEmpty)
                    const Center(child: Text('Aucun temps enregistré'))
                  else
                    ..._timeLogs.map((log) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text('${log.hoursWorked?.toStringAsFixed(2)} heures'),
                            subtitle: Text(log.description ?? 'Sans description'),
                            trailing: Text(
                              '${log.laborCost?.toStringAsFixed(2)} €',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '${_totalLaborCost.toStringAsFixed(2)} €',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === Helper Methods ===

  /// Show full-screen image viewer
  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image, size: 64, color: Colors.white)),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog to add a new note
  void _showAddNoteDialog() {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Saisissez votre note...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final noteText = noteController.text.trim();
              if (noteText.isNotEmpty) {
                Navigator.of(context).pop();
                await _addNote(noteText);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  /// Add a new note
  Future<void> _addNote(String noteText) async {
    try {
      await SupabaseService.createJobSiteNote({
        'job_site_id': widget.jobSiteId,
        'note_text': noteText,
      });
      await _loadNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note ajoutée avec succès')),
        );
      }
    } catch (e) {
      _showError('Erreur lors de l\'ajout de la note: $e');
    }
  }

  /// Upload a document
  Future<void> _uploadDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileSize = result.files.single.size;

        // Show loading
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Téléchargement en cours...')),
          );
        }

        // Upload to Supabase Storage
        final documentUrl = await SupabaseService.uploadDocument(file, fileName);

        // Determine document type from extension
        final extension = fileName.split('.').last.toLowerCase();
        String docType = 'other';
        if (extension == 'pdf') docType = 'pdf';
        if (['jpg', 'jpeg', 'png'].contains(extension)) docType = 'photo';

        // Save document metadata
        await SupabaseService.createJobSiteDocument({
          'job_site_id': widget.jobSiteId,
          'document_name': fileName,
          'document_url': documentUrl,
          'document_type': docType,
          'file_size': fileSize,
          'uploaded_at': DateTime.now().toIso8601String(),
        });

        await _loadDocuments();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document ajouté avec succès')),
          );
        }
      }
    } catch (e) {
      _showError('Erreur lors de l\'ajout du document: $e');
    }
  }

  /// Open a document in browser
  Future<void> _openDocument(String documentUrl) async {
    try {
      final uri = Uri.parse(documentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Impossible d\'ouvrir le document');
      }
    } catch (e) {
      _showError('Erreur lors de l\'ouverture du document: $e');
    }
  }

  /// Delete a document
  Future<void> _deleteDocument(String documentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce document ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await SupabaseService.deleteJobSiteDocument(documentId);
        await _loadDocuments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document supprimé')),
          );
        }
      } catch (e) {
        _showError('Erreur lors de la suppression: $e');
      }
    }
  }

  /// Load documents from database
  Future<void> _loadDocuments() async {
    try {
      final data = await SupabaseService.getJobSiteDocuments(widget.jobSiteId);
      setState(() {
        _documents = data.map((json) => JobSiteDocument.fromJson(json)).toList();
      });
    } catch (e) {
      _showError('Erreur de chargement des documents: $e');
    }
  }

  /// Load notes from database
  Future<void> _loadNotes() async {
    try {
      final data = await SupabaseService.getNotesForJobSite(widget.jobSiteId);
      setState(() {
        _notes = data;
      });
    } catch (e) {
      _showError('Erreur de chargement des notes: $e');
    }
  }
}
