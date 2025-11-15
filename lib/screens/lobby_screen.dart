/**
 * Lobby Screen - Features 2.3 & 2.4
 * Main lobby view with player list, host controls, and presence tracking
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/multiplayer_service.dart';
import '../widgets/chat_widgets.dart';
import 'game_selection_screen.dart';
import 'game_voting_screen.dart';
import 'lobby_settings_screen.dart';

class LobbyScreen extends StatefulWidget {
  final MultiplayerService multiplayerService;
  final String currentUserId;

  const LobbyScreen({
    Key? key,
    required this.multiplayerService,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  GameLobby? _lobby;
  bool _isLoading = true;
  final Map<String, bool> _typingPlayers = {};
  final List<ChatMessage> _messages = [];
  final List<EmojiReaction> _recentReactions = [];
  late ScrollController _chatScrollController;

  @override
  void initState() {
    super.initState();
    _chatScrollController = ScrollController();
    
    try {
      _lobby = widget.multiplayerService.currentLobby;
      _setupEventListeners();
      _isLoading = false;

      // Start heartbeat for presence tracking
      widget.multiplayerService.startHeartbeat();
    } catch (e) {
      // Ensure scroll controller is disposed if initialization fails
      _chatScrollController.dispose();
      rethrow;
    }
  }

  @override
  void dispose() {
    _chatScrollController.dispose();
    super.dispose();
  }

  void _setupEventListeners() {
    // Player joined
    widget.multiplayerService.on('player-joined', (data) {
      if (!mounted) return;
      setState(() {
        final player = Player.fromJson(data['player']);
        _lobby = _lobby?.copyWith(
          players: [...(_lobby?.players ?? []), player],
        );
      });
      _showSnackBar('${data['player']['username']} joined the lobby');
    });

    // Player left
    widget.multiplayerService.on('player-left', (data) {
      if (!mounted) return;
      setState(() {
        _lobby = _lobby?.copyWith(
          players: _lobby?.players
              .where((p) => p.id != data['playerId'])
              .toList() ?? [],
        );
      });
      _showSnackBar('${data['username']} left the lobby');
    });

    // Player kicked
    widget.multiplayerService.on('player-kicked', (data) {
      if (!mounted) return;
      if (data['playerId'] == widget.currentUserId) {
        _showSnackBar('You were kicked from the lobby');
        Navigator.of(context).pop();
      } else {
        setState(() {
          _lobby = _lobby?.copyWith(
            players: _lobby?.players
                .where((p) => p.id != data['playerId'])
                .toList() ?? [],
          );
        });
        _showSnackBar('${data['username']} was kicked');
      }
    });

    // Host transferred
    widget.multiplayerService.on('host-transferred', (data) {
      if (!mounted) return;
      setState(() {
        _lobby = _lobby?.copyWith(hostId: data['newHostId']);
      });
      _showSnackBar('${data['newHostUsername']} is now the host');
    });

    // Lobby closed
    widget.multiplayerService.on('lobby-closed', (data) {
      if (!mounted) return;
      _showSnackBar('The lobby has been closed');
      Navigator.of(context).pop();
    });

    // Lobby updated
    widget.multiplayerService.on('lobby-updated', (data) {
      if (!mounted) return;
      setState(() {
        _lobby = GameLobby.fromJson(data['lobby']);
      });
    });

    // Player status changed
    widget.multiplayerService.on('player-status-changed', (data) {
      if (!mounted) return;
      setState(() {
        final playerId = data['playerId'];
        final status = PlayerStatus.values.firstWhere(
          (e) => e.toString() == data['status'],
          orElse: () => PlayerStatus.active,
        );
        
        final players = _lobby?.players.map((p) {
          if (p.id == playerId) {
            return Player(
              id: p.id,
              username: p.username,
              avatar: p.avatar,
              status: status,
              score: p.score,
              streak: p.streak,
              badges: p.badges,
              lastActive: DateTime.now(),
            );
          }
          return p;
        }).toList() ?? [];
        
        _lobby = _lobby?.copyWith(players: players);
      });
    });

    // Typing indicator
    widget.multiplayerService.on('player-typing', (data) {
      if (!mounted) return;
      setState(() {
        _typingPlayers[data['playerId']] = data['isTyping'];
      });
    });

    // Game started
    widget.multiplayerService.on('game-started', (data) {
      if (!mounted) return;
      final game = Game.fromJson(data['game']);
      // Navigate to game screen
      Navigator.of(context).pushNamed('/game', arguments: game);
    });

    // Chat message received
    widget.multiplayerService.on('chat-message', (data) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          id: data['id'] as String,
          senderId: data['userId'] as String,
          senderName: data['displayName'] as String,
          message: data['message'] as String,
          timestamp: DateTime.parse(data['timestamp'] as String),
        ));
      });
    });

    // Emoji reaction received
    widget.multiplayerService.on('emoji-reaction', (data) {
      if (!mounted) return;
      setState(() {
        _recentReactions.add(EmojiReaction.fromJson(data));
        // Keep only recent reactions (last 10)
        if (_recentReactions.length > 10) {
          _recentReactions.removeAt(0);
        }
      });
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _copyLobbyCode() async {
    if (_lobby?.lobbyCode != null) {
      await Clipboard.setData(ClipboardData(text: _lobby!.lobbyCode!));
      _showSnackBar('Lobby code copied to clipboard');
    }
  }

  Future<void> _startGame() async {
    if (_lobby == null) return;

    // Navigate to game voting screen where players vote on games
    final selectedGameId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => GameVotingScreen(
          lobby: _lobby!,
          multiplayerService: widget.multiplayerService,
        ),
      ),
    );

    if (selectedGameId != null && mounted) {
      _showSnackBar('Starting game: $selectedGameId');
      // Game voting screen handles the voting and game start
    }
  }

  Future<void> _kickPlayer(Player player) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kick Player'),
        content: Text('Are you sure you want to kick ${player.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Kick'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.multiplayerService.kickPlayer(player.id);
      } catch (e) {
        _showSnackBar('Failed to kick player: ${e.toString()}');
      }
    }
  }

  Future<void> _transferHost(Player player) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Host'),
        content: Text('Make ${player.username} the new host?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Transfer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.multiplayerService.transferHost(player.id);
      } catch (e) {
        _showSnackBar('Failed to transfer host: ${e.toString()}');
      }
    }
  }

  Future<void> _closeLobby() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Lobby'),
        content: const Text(
          'Are you sure you want to close this lobby? All players will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.multiplayerService.closeLobby();
        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        _showSnackBar('Failed to close lobby: ${e.toString()}');
      }
    }
  }

  Future<void> _leaveLobby() async {
    try {
      await widget.multiplayerService.leaveLobby();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Failed to leave lobby: ${e.toString()}');
    }
  }

  Future<void> _navigateToSettings() async {
    if (_lobby == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LobbySettingsScreen(
          lobby: _lobby!,
          onSave: (maxPlayers, totalRounds, votingPoints) {
            // Update lobby settings via multiplayer service
            widget.multiplayerService.updateLobbySettings(
              maxPlayers: maxPlayers,
              totalRounds: totalRounds,
              votingPointsPerPlayer: votingPoints,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerStatusIcon(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.active:
        return const Icon(Icons.circle, color: Colors.green, size: 12);
      case PlayerStatus.idle:
        return const Icon(Icons.circle, color: Colors.orange, size: 12);
      case PlayerStatus.disconnected:
        return const Icon(Icons.circle, color: Colors.grey, size: 12);
    }
  }

  String _getPlayerStatusText(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.active:
        return 'Active';
      case PlayerStatus.idle:
        return 'Idle';
      case PlayerStatus.disconnected:
        return 'Disconnected';
    }
  }

  void _sendChatMessage(String message) {
    widget.multiplayerService.sendMessage(message);
  }

  void _sendEmojiReaction(String emoji) {
    widget.multiplayerService.sendReaction(
      messageId: '', // Lobby-level reaction (not message-specific)
      emoji: emoji,
    );
  }

  void _onTypingStatusChanged(bool isTyping) {
    widget.multiplayerService.sendTypingIndicator(isTyping);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _lobby == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isHost = _lobby!.isHost(widget.currentUserId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_lobby!.name),
        actions: [
          if (isHost)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'settings':
                    _navigateToSettings();
                    break;
                  case 'close':
                    _closeLobby();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Lobby Settings'),
                ),
                const PopupMenuItem(
                  value: 'close',
                  child: Text('Close Lobby'),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Lobby Info Card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_lobby!.lobbyCode != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.vpn_key, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _lobby!.lobbyCode!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _copyLobbyCode,
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy Code'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.people, color: Colors.blue),
                            const SizedBox(height: 4),
                            Text(
                              '${_lobby!.players.length}/${_lobby!.maxPlayers}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text('Players', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.repeat, color: Colors.purple),
                            const SizedBox(height: 4),
                            Text(
                              '${_lobby!.numberOfRounds}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text('Rounds', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.how_to_vote, color: Colors.orange),
                            const SizedBox(height: 4),
                            Text(
                              '${_lobby!.votingPointsPerPlayer}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text('Points', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Players List and Chat Section
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Players List
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _lobby!.players.length,
                      itemBuilder: (context, index) {
                        final player = _lobby!.players[index];
                        final isCurrentHost = player.id == _lobby!.hostId;
                        final isTyping = _typingPlayers[player.id] == true;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  child: Text(
                                    player.username[0].toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: _buildPlayerStatusIcon(player.status),
                                ),
                              ],
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    player.username,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (isCurrentHost) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'HOST',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              isTyping
                                  ? 'typing...'
                                  : _getPlayerStatusText(player.status),
                              style: TextStyle(
                                color: isTyping ? Colors.blue : null,
                                fontStyle: isTyping ? FontStyle.italic : null,
                              ),
                            ),
                            trailing: isHost && player.id != widget.currentUserId
                                ? PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'kick':
                                          _kickPlayer(player);
                                          break;
                                        case 'transfer':
                                          _transferHost(player);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'transfer',
                                        child: Text('Make Host'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'kick',
                                        child: Text('Kick Player'),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),

                  // Vertical Divider
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.grey[300],
                  ),

                  // Chat Section
                  Expanded(
                    flex: 1,
                    child: Card(
                      margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                      child: Column(
                        children: [
                          // Chat Header
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.chat, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Chat',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${_messages.length}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Chat Messages List
                          Expanded(
                            child: ChatListView(
                              messages: _messages,
                              currentUserId: widget.currentUserId,
                              scrollController: _chatScrollController,
                            ),
                          ),

                          // Emoji Reactions Display
                          if (_recentReactions.isNotEmpty)
                            EmojiReactionsList(reactions: _recentReactions),

                          // Emoji Picker
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: EmojiPicker(
                              onEmojiSelected: _sendEmojiReaction,
                            ),
                          ),

                          // Chat Input
                          ChatInputField(
                            onSendMessage: _sendChatMessage,
                            onTypingStatusChanged: _onTypingStatusChanged,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (!isHost)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _leaveLobby,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Leave Lobby'),
                      ),
                    ),
                  if (isHost) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _closeLobby,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Close Lobby'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _lobby!.players.length >= 2
                            ? _startGame
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Start Game'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
