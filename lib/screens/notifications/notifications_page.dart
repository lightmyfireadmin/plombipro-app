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

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  List<model.Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await SupabaseService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.handleError(
          e,
          customMessage: "Erreur de chargement des notifications",
          onRetry: _fetchNotifications,
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
      appBar: const CustomAppBar(
        title: 'Notifications',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(notification.title ?? ''),
                  subtitle: Text(notification.message ?? ''),
                  trailing: notification.isRead ? null : const Icon(Icons.circle, color: Colors.blue, size: 12),
                  onTap: () {
                    // TODO: Mark as read and navigate to the link
                  },
                );
              },
            ),
    );
  }
}
