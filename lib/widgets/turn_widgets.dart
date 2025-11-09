/**
 * Turn UI Components - Feature 3.3.2
 * Reusable widgets for turn-based gameplay
 */

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/turn_management_service.dart';

/// Turn indicator widget - shows whose turn it is
class TurnIndicator extends StatelessWidget {
  final String currentPlayerId;
  final String currentPlayerName;
  final String localPlayerId;
  final bool isYourTurn;

  const TurnIndicator({
    Key? key,
    required this.currentPlayerId,
    required this.currentPlayerName,
    required this.localPlayerId,
  })  : isYourTurn = currentPlayerId == localPlayerId,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isYourTurn ? Colors.green.shade100 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isYourTurn ? Colors.green : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isYourTurn ? Icons.touch_app : Icons.hourglass_empty,
            color: isYourTurn ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            isYourTurn ? "It's your turn!" : "$currentPlayerName's turn",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isYourTurn ? Colors.green.shade900 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Turn history list widget
class TurnHistoryList extends StatelessWidget {
  final List<Turn> turns;
  final String localPlayerId;

  const TurnHistoryList({
    Key? key,
    required this.turns,
    required this.localPlayerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (turns.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No turns yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: turns.length,
      itemBuilder: (context, index) {
        final turn = turns[index];
        final isLocalPlayer = turn.playerId == localPlayerId;

        return TurnHistoryCard(
          turn: turn,
          isLocalPlayer: isLocalPlayer,
        );
      },
    );
  }
}

/// Turn history card widget
class TurnHistoryCard extends StatelessWidget {
  final Turn turn;
  final bool isLocalPlayer;

  const TurnHistoryCard({
    Key? key,
    required this.turn,
    required this.isLocalPlayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      isLocalPlayer ? Colors.blue.shade100 : Colors.grey.shade200,
                  child: Text(
                    turn.playerName[0].toUpperCase(),
                    style: TextStyle(
                      color: isLocalPlayer ? Colors.blue : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            turn.playerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isLocalPlayer)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'You',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Turn ${turn.turnNumber} • ${_formatTimestamp(turn.timestamp)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (turn.score != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${turn.score}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
              ],
            ),
            if (turn.data['action'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _formatAction(turn.data),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatAction(Map<String, dynamic> data) {
    final action = data['action']?.toString() ?? 'Unknown action';
    return action;
  }
}

/// Turn notification badge widget
class TurnNotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const TurnNotificationBadge({
    Key? key,
    required this.count,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.notifications_outlined),
      );
    }

    return Stack(
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.notifications),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              count > 9 ? '9+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

/// Turn notifications list screen
class TurnNotificationsScreen extends StatelessWidget {
  final TurnManagementService turnService;
  final String playerId;

  const TurnNotificationsScreen({
    Key? key,
    required this.turnService,
    required this.playerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turn Notifications'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<TurnNotification>>(
        future: turnService.getNotifications(playerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading notifications: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(context, notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    TurnNotification notification,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.read ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: notification.read ? Colors.white : Colors.blue.shade50,
      child: InkWell(
        onTap: () async {
          if (!notification.read) {
            await turnService.markNotificationRead(notification.id);
            // Refresh the list by calling setState in parent or using state management
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.videogame_asset,
                    size: 20,
                    color: notification.read ? Colors.grey : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notification.gameName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: notification.read
                            ? Colors.grey.shade700
                            : Colors.black,
                      ),
                    ),
                  ),
                  if (!notification.read)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 14,
                  color: notification.read ? Colors.grey.shade600 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatTimestamp(notification.timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}
