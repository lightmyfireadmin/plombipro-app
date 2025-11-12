import 'package:flutter/material.dart';
import '../../models/notification.dart' as model;
import '../../services/supabase_service.dart';
import '../../services/error_handler.dart';
import '../../widgets/custom_app_bar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<model.Notification> _notifications = [];
  List<_TodoItem> _todos = [];
  List<_ReminderItem> _reminders = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await SupabaseService.getNotifications();

      // Generate sample reminders and todos (TODO: Replace with real data from backend)
      final sampleReminders = _generateSampleReminders();
      final sampleTodos = _generateSampleTodos();

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _reminders = sampleReminders;
          _todos = sampleTodos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.handleError(
          e,
          customMessage: "Erreur de chargement des données",
          onRetry: _fetchAllData,
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<_ReminderItem> _generateSampleReminders() {
    return [
      _ReminderItem(
        title: 'Rappel de paiement',
        description: 'Facture #2024-001 - Client Dupont - 1 500€',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        priority: 'high',
      ),
      _ReminderItem(
        title: 'Rendez-vous client',
        description: 'Installation chaudière - M. Martin - 14h00',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: 'medium',
      ),
      _ReminderItem(
        title: 'Renouvellement assurance',
        description: 'Assurance décennale à renouveler',
        dueDate: DateTime.now().add(const Duration(days: 30)),
        priority: 'low',
      ),
    ];
  }

  List<_TodoItem> _generateSampleTodos() {
    return [
      _TodoItem(
        title: 'Finaliser devis plomberie',
        description: 'Devis #2024-015 pour rénovation salle de bain',
        isCompleted: false,
        priority: 'high',
      ),
      _TodoItem(
        title: 'Commander matériel',
        description: 'Robinetterie pour chantier rue Voltaire',
        isCompleted: false,
        priority: 'medium',
      ),
      _TodoItem(
        title: 'Mettre à jour catalogue',
        description: 'Ajouter nouveaux produits Point P',
        isCompleted: true,
        priority: 'low',
      ),
      _TodoItem(
        title: 'Relancer client pour signature',
        description: 'Devis #2024-012 envoyé il y a 5 jours',
        isCompleted: false,
        priority: 'high',
      ),
    ];
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      await SupabaseService.markNotificationAsRead(notificationId);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index >= 0) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index] = _todos[index].copyWith(isCompleted: !_todos[index].isCompleted);
    });
    // TODO: Persist to backend
  }

  void _deleteReminder(int index) {
    setState(() {
      _reminders.removeAt(index);
    });
    // TODO: Persist to backend
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    final activeTodosCount = _todos.where((t) => !t.isCompleted).length;
    final upcomingRemindersCount = _reminders.where((r) =>
      r.dueDate.difference(DateTime.now()).inDays <= 7
    ).length;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Notifications & Rappels',
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.notifications_active,
                    count: unreadCount,
                    label: 'Non lues',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.alarm,
                    count: upcomingRemindersCount,
                    label: 'Rappels',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.check_circle_outline,
                    count: activeTodosCount,
                    label: 'À faire',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
              Tab(icon: Icon(Icons.alarm), text: 'Rappels'),
              Tab(icon: Icon(Icons.checklist), text: 'Tâches'),
            ],
          ),
          // Tab Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNotificationsTab(),
                      _buildRemindersTab(),
                      _buildTodosTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune notification',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Les notifications apparaîtront ici',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAllData,
      child: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Dismissible(
            key: Key(notification.id ?? index.toString()),
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.check, color: Colors.white),
            ),
            onDismissed: (direction) {
              if (notification.id != null) {
                _markNotificationAsRead(notification.id!);
              }
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: notification.isRead
                    ? Colors.grey[300]
                    : Colors.blue,
                child: Icon(
                  Icons.notifications,
                  color: notification.isRead ? Colors.grey[600] : Colors.white,
                ),
              ),
              title: Text(
                notification.title ?? 'Notification',
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(notification.message ?? ''),
              trailing: notification.isRead
                  ? null
                  : const Icon(Icons.circle, color: Colors.blue, size: 12),
              onTap: () {
                if (notification.id != null && !notification.isRead) {
                  _markNotificationAsRead(notification.id!);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRemindersTab() {
    if (_reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alarm_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun rappel',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez des rappels pour ne rien oublier',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        final daysUntil = reminder.dueDate.difference(DateTime.now()).inDays;
        final isUrgent = daysUntil <= 2;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isUrgent ? Colors.red : Colors.orange,
              child: const Icon(Icons.alarm, color: Colors.white),
            ),
            title: Text(
              reminder.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(reminder.description),
                const SizedBox(height: 4),
                Text(
                  daysUntil == 0
                      ? 'Aujourd\'hui'
                      : daysUntil == 1
                          ? 'Demain'
                          : 'Dans $daysUntil jours',
                  style: TextStyle(
                    color: isUrgent ? Colors.red : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteReminder(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodosTab() {
    if (_todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune tâche',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez des tâches pour organiser votre travail',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final activeTodos = _todos.where((t) => !t.isCompleted).toList();
    final completedTodos = _todos.where((t) => t.isCompleted).toList();

    return ListView(
      children: [
        if (activeTodos.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'À faire (${activeTodos.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...activeTodos.map((todo) {
            final index = _todos.indexOf(todo);
            return _buildTodoItem(todo, index);
          }),
        ],
        if (completedTodos.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Terminées (${completedTodos.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          ...completedTodos.map((todo) {
            final index = _todos.indexOf(todo);
            return _buildTodoItem(todo, index);
          }),
        ],
      ],
    );
  }

  Widget _buildTodoItem(_TodoItem todo, int index) {
    Color priorityColor = Colors.grey;
    if (todo.priority == 'high') priorityColor = Colors.red;
    if (todo.priority == 'medium') priorityColor = Colors.orange;
    if (todo.priority == 'low') priorityColor = Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) => _toggleTodo(index),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Text(todo.description),
        trailing: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: priorityColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoItem {
  final String title;
  final String description;
  final bool isCompleted;
  final String priority; // 'high', 'medium', 'low'

  _TodoItem({
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.priority,
  });

  _TodoItem copyWith({bool? isCompleted}) {
    return _TodoItem(
      title: title,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority,
    );
  }
}

class _ReminderItem {
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority; // 'high', 'medium', 'low'

  _ReminderItem({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
  });
}
