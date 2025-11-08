/**
 * Player Presence Widget - Feature 2.4
 * Displays player status with visual indicators
 */

import 'package:flutter/material.dart';
import '../models/models.dart';

class PlayerPresenceIndicator extends StatelessWidget {
  final Player player;
  final bool showLastSeen;

  const PlayerPresenceIndicator({
    Key? key,
    required this.player,
    this.showLastSeen = false,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (player.status) {
      case PlayerStatus.active:
        return Colors.green;
      case PlayerStatus.idle:
        return Colors.orange;
      case PlayerStatus.disconnected:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (player.status) {
      case PlayerStatus.active:
        return 'Active';
      case PlayerStatus.idle:
        return 'Idle';
      case PlayerStatus.disconnected:
        return _getLastSeenText();
    }
  }

  String _getLastSeenText() {
    final now = DateTime.now();
    final difference = now.difference(player.lastActive);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _getStatusText(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Badge for displaying status inline
class PlayerStatusBadge extends StatelessWidget {
  final PlayerStatus status;
  final double size;

  const PlayerStatusBadge({
    Key? key,
    required this.status,
    this.size = 12,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (status) {
      case PlayerStatus.active:
        return Colors.green;
      case PlayerStatus.idle:
        return Colors.orange;
      case PlayerStatus.disconnected:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

/// Typing indicator widget
class TypingIndicator extends StatefulWidget {
  final String username;

  const TypingIndicator({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${widget.username} is typing',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 4),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final delay = index * 0.2;
                final opacity = (((_controller.value + delay) % 1.0) * 2 - 1).abs();
                
                return Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(opacity),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}
