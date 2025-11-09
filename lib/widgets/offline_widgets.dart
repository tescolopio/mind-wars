/**
 * Offline Mode Widgets - UI components for offline mode indication
 * Shows connectivity status, sync status, and offline indicator
 */

import 'package:flutter/material.dart';
import 'dart:async';

/// Offline indicator widget showing connectivity and sync status
class OfflineIndicator extends StatefulWidget {
  final bool isOffline;
  final bool isSyncing;
  final int pendingChanges;
  final VoidCallback? onTap;
  
  const OfflineIndicator({
    Key? key,
    required this.isOffline,
    required this.isSyncing,
    this.pendingChanges = 0,
    this.onTap,
  }) : super(key: key);
  
  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isOffline && !widget.isSyncing) {
      return const SizedBox.shrink();
    }
    
    return Material(
      color: _getBackgroundColor(),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(),
              const SizedBox(width: 8.0),
              Flexible(
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.pendingChanges > 0) ...[
                const SizedBox(width: 8.0),
                _buildBadge(),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildIcon() {
    if (widget.isSyncing) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value * 2 * 3.14159,
            child: const Icon(
              Icons.sync,
              color: Colors.white,
              size: 20.0,
            ),
          );
        },
      );
    } else {
      return const Icon(
        Icons.cloud_off,
        color: Colors.white,
        size: 20.0,
      );
    }
  }
  
  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        '${widget.pendingChanges}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Color _getBackgroundColor() {
    if (widget.isSyncing) {
      return Colors.blue;
    } else if (widget.isOffline) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
  
  String _getStatusText() {
    if (widget.isSyncing) {
      return 'Syncing...';
    } else if (widget.isOffline) {
      if (widget.pendingChanges > 0) {
        return 'Offline - ${widget.pendingChanges} pending';
      } else {
        return 'Offline Mode';
      }
    } else {
      return 'Online';
    }
  }
}

/// Connectivity status monitor widget
class ConnectivityStatusMonitor extends StatefulWidget {
  final Widget child;
  final Function(bool isOnline)? onConnectivityChanged;
  
  const ConnectivityStatusMonitor({
    Key? key,
    required this.child,
    this.onConnectivityChanged,
  }) : super(key: key);
  
  @override
  State<ConnectivityStatusMonitor> createState() => _ConnectivityStatusMonitorState();
}

class _ConnectivityStatusMonitorState extends State<ConnectivityStatusMonitor> {
  bool _isOnline = true;
  Timer? _checkTimer;
  
  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }
  
  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
  
  void _startMonitoring() {
    // Check connectivity every 5 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkConnectivity();
    });
    
    // Initial check
    _checkConnectivity();
  }
  
  Future<void> _checkConnectivity() async {
    // In a real app, this would use connectivity_plus package
    // For now, we simulate connectivity check
    // This should be replaced with actual connectivity check
    final wasOnline = _isOnline;
    // _isOnline = await _performConnectivityCheck();
    
    if (wasOnline != _isOnline) {
      if (mounted) {
        setState(() {});
        widget.onConnectivityChanged?.call(_isOnline);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Sync status widget
class SyncStatusWidget extends StatelessWidget {
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int pendingItems;
  final String? errorMessage;
  
  const SyncStatusWidget({
    Key? key,
    required this.isSyncing,
    this.lastSyncTime,
    this.pendingItems = 0,
    this.errorMessage,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 24.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    _getStatusTitle(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            if (isSyncing)
              const LinearProgressIndicator(),
            if (!isSyncing) ...[
              _buildInfoRow('Last synced', _getLastSyncText()),
              if (pendingItems > 0)
                _buildInfoRow('Pending items', '$pendingItems'),
              if (errorMessage != null)
                _buildErrorRow(errorMessage!),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorRow(String error) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16.0),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getStatusIcon() {
    if (isSyncing) {
      return Icons.sync;
    } else if (errorMessage != null) {
      return Icons.error_outline;
    } else if (pendingItems > 0) {
      return Icons.cloud_upload;
    } else {
      return Icons.cloud_done;
    }
  }
  
  Color _getStatusColor() {
    if (isSyncing) {
      return Colors.blue;
    } else if (errorMessage != null) {
      return Colors.red;
    } else if (pendingItems > 0) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
  
  String _getStatusTitle() {
    if (isSyncing) {
      return 'Syncing...';
    } else if (errorMessage != null) {
      return 'Sync Error';
    } else if (pendingItems > 0) {
      return 'Pending Sync';
    } else {
      return 'Up to Date';
    }
  }
  
  String _getLastSyncText() {
    if (lastSyncTime == null) {
      return 'Never';
    }
    
    final now = DateTime.now();
    final difference = now.difference(lastSyncTime!);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Offline mode banner
class OfflineModeBanner extends StatelessWidget {
  final bool isOffline;
  final VoidCallback? onRetry;
  
  const OfflineModeBanner({
    Key? key,
    required this.isOffline,
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (!isOffline) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      color: Colors.orange,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 20.0),
          const SizedBox(width: 12.0),
          const Expanded(
            child: Text(
              'You are offline. Changes will sync when online.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'RETRY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
