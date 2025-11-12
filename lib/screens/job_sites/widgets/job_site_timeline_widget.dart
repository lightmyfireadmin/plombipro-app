import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/job_site.dart';
import '../../../models/job_site_task.dart';
import '../../../models/job_site_note.dart';
import '../../../models/job_site_photo.dart';
import '../../../models/job_site_time_log.dart';

/// Timeline event types
enum TimelineEventType {
  jobSiteCreated,
  jobSiteStarted,
  taskCreated,
  taskCompleted,
  noteAdded,
  photoAdded,
  timeLogged,
  statusChanged,
  jobSiteCompleted,
}

/// Timeline event model
class TimelineEvent {
  final DateTime timestamp;
  final TimelineEventType type;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final dynamic relatedData;

  TimelineEvent({
    required this.timestamp,
    required this.type,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    this.relatedData,
  });
}

/// Job Site Timeline Widget
///
/// Displays a chronological timeline of all events on a job site:
/// - Job site creation and milestones
/// - Task creations and completions
/// - Notes added
/// - Photos uploaded
/// - Time logged
/// - Status changes
class JobSiteTimelineWidget extends StatelessWidget {
  final JobSite jobSite;
  final List<JobSiteTask> tasks;
  final List<JobSiteNote> notes;
  final List<JobSitePhoto> photos;
  final List<JobSiteTimeLog> timeLogs;

  const JobSiteTimelineWidget({
    super.key,
    required this.jobSite,
    required this.tasks,
    required this.notes,
    required this.photos,
    required this.timeLogs,
  });

  @override
  Widget build(BuildContext context) {
    final events = _buildTimelineEvents();

    if (events.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isFirst = index == 0;
        final isLast = index == events.length - 1;

        return _buildTimelineItem(
          context,
          event,
          isFirst: isFirst,
          isLast: isLast,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun événement',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les événements du chantier apparaîtront ici',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    TimelineEvent event, {
    required bool isFirst,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and icon
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // Top line
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                // Icon circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: event.color, width: 2),
                  ),
                  child: Icon(
                    event.icon,
                    color: event.color,
                    size: 20,
                  ),
                ),
                // Bottom line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Event content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: event.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatEventType(event.type),
                              style: TextStyle(
                                fontSize: 10,
                                color: event.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(event.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (event.description != null && event.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          event.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TimelineEvent> _buildTimelineEvents() {
    final List<TimelineEvent> events = [];

    // Job site creation
    events.add(TimelineEvent(
      timestamp: jobSite.createdAt,
      type: TimelineEventType.jobSiteCreated,
      title: 'Chantier créé',
      description: 'Le chantier "${jobSite.jobName}" a été créé',
      icon: Icons.add_circle,
      color: Colors.blue,
    ));

    // Job site start
    if (jobSite.startDate != null) {
      events.add(TimelineEvent(
        timestamp: jobSite.startDate!,
        type: TimelineEventType.jobSiteStarted,
        title: 'Début des travaux',
        description: 'Les travaux ont officiellement commencé',
        icon: Icons.play_circle,
        color: Colors.green,
      ));
    }

    // Task events
    for (final task in tasks) {
      // Task created
      events.add(TimelineEvent(
        timestamp: task.createdAt,
        type: TimelineEventType.taskCreated,
        title: 'Nouvelle tâche',
        description: task.taskDescription ?? 'Sans description',
        icon: Icons.task_alt,
        color: Colors.orange,
        relatedData: task,
      ));

      // Task completed
      if (task.isCompleted && task.completedAt != null) {
        events.add(TimelineEvent(
          timestamp: task.completedAt!,
          type: TimelineEventType.taskCompleted,
          title: 'Tâche terminée',
          description: task.taskDescription ?? 'Sans description',
          icon: Icons.check_circle,
          color: Colors.green,
          relatedData: task,
        ));
      }
    }

    // Note events
    for (final note in notes) {
      events.add(TimelineEvent(
        timestamp: note.createdAt,
        type: TimelineEventType.noteAdded,
        title: 'Note ajoutée',
        description: note.noteText ?? 'Sans texte',
        icon: Icons.note,
        color: Colors.purple,
        relatedData: note,
      ));
    }

    // Photo events
    for (final photo in photos) {
      events.add(TimelineEvent(
        timestamp: photo.uploadedAt,
        type: TimelineEventType.photoAdded,
        title: 'Photo ajoutée',
        description: photo.caption ?? 'Photo du chantier',
        icon: Icons.photo_camera,
        color: Colors.pink,
        relatedData: photo,
      ));
    }

    // Time log events
    for (final timeLog in timeLogs) {
      final hours = timeLog.hoursWorked?.toStringAsFixed(2) ?? '0';
      final cost = timeLog.laborCost?.toStringAsFixed(2) ?? '0';

      events.add(TimelineEvent(
        timestamp: timeLog.logDate,
        type: TimelineEventType.timeLogged,
        title: 'Temps enregistré',
        description: '${hours}h de travail (${cost}€) - ${timeLog.description ?? "Sans description"}',
        icon: Icons.timer,
        color: Colors.teal,
        relatedData: timeLog,
      ));
    }

    // Job site completion
    if (jobSite.actualEndDate != null) {
      events.add(TimelineEvent(
        timestamp: jobSite.actualEndDate!,
        type: TimelineEventType.jobSiteCompleted,
        title: 'Chantier terminé',
        description: 'Les travaux sont terminés avec succès',
        icon: Icons.celebration,
        color: Colors.amber,
      ));
    }

    // Sort events by timestamp (newest first)
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return events;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} min';
      }
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier à ${DateFormat.Hm().format(timestamp)}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(timestamp);
    }
  }

  String _formatEventType(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.jobSiteCreated:
        return 'CRÉATION';
      case TimelineEventType.jobSiteStarted:
        return 'DÉMARRAGE';
      case TimelineEventType.taskCreated:
        return 'TÂCHE';
      case TimelineEventType.taskCompleted:
        return 'COMPLÉTÉ';
      case TimelineEventType.noteAdded:
        return 'NOTE';
      case TimelineEventType.photoAdded:
        return 'PHOTO';
      case TimelineEventType.timeLogged:
        return 'TEMPS';
      case TimelineEventType.statusChanged:
        return 'STATUT';
      case TimelineEventType.jobSiteCompleted:
        return 'TERMINÉ';
    }
  }
}
