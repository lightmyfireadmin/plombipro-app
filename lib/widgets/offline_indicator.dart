import 'package:flutter/material.dart';
import '../services/offline_storage_service.dart';
import '../services/offline_aware_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

/// Offline indicator widget (Phase 10)
///
/// Shows connection status and sync controls
class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  bool _isOnline = true;
  int _pendingOps = 0;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _startMonitoring();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _checkStatus() async {
    final isOnline = await OfflineStorageService.isOnline();
    final pendingOps = OfflineAwareService.getPendingOperationsCount();

    if (mounted) {
      setState(() {
        _isOnline = isOnline;
        _pendingOps = pendingOps;
      });
    }
  }

  void _startMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (results) {
        _checkStatus();
      },
    );
  }

  Future<void> _syncNow() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Synchronisation...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final result = await OfflineAwareService.sync();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? '${result.syncedCount} opérations synchronisées'
                  : 'Erreur: ${result.message}',
            ),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );

        _checkStatus(); // Refresh status
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de synchronisation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnline && _pendingOps == 0) {
      // Everything is synced, don't show anything
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isOnline ? Colors.orange.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isOnline ? Colors.orange : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOnline ? Icons.cloud_queue : Icons.cloud_off,
            size: 16,
            color: _isOnline ? Colors.orange : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            _isOnline
                ? '$_pendingOps en attente'
                : 'Hors ligne',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _isOnline ? Colors.orange.shade900 : Colors.red.shade900,
            ),
          ),
          if (_isOnline && _pendingOps > 0) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _syncNow,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sync,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Banner to show offline status at the top of the screen
class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _startMonitoring();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _checkConnection() async {
    final isOnline = await OfflineStorageService.isOnline();
    if (mounted) {
      setState(() {
        _isOnline = isOnline;
      });
    }
  }

  void _startMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (results) {
        _checkConnection();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isOnline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.red.shade700,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Mode hors ligne - Les modifications seront synchronisées plus tard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Sync button for manual synchronization
class SyncButton extends StatefulWidget {
  final VoidCallback? onSyncComplete;

  const SyncButton({super.key, this.onSyncComplete});

  @override
  State<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  bool _isSyncing = false;

  Future<void> _sync() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      final result = await OfflineAwareService.sync();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? '${result.syncedCount} opérations synchronisées'
                  : 'Erreur: ${result.message}',
            ),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );

        if (result.success) {
          widget.onSyncComplete?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.sync),
      onPressed: _isSyncing ? null : _sync,
      tooltip: 'Synchroniser',
    );
  }
}
