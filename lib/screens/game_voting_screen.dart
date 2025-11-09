/**
 * Game Voting Screen - Feature 3.2.2
 * Allows players to vote on games using a point allocation system
 * with real-time updates and multi-round support
 */

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../games/game_catalog.dart';
import '../services/voting_service.dart';
import '../services/multiplayer_service.dart';

class GameVotingScreen extends StatefulWidget {
  final String lobbyId;
  final String playerId;
  final VotingService votingService;
  final MultiplayerService multiplayerService;

  const GameVotingScreen({
    Key? key,
    required this.lobbyId,
    required this.playerId,
    required this.votingService,
    required this.multiplayerService,
  }) : super(key: key);

  @override
  State<GameVotingScreen> createState() => _GameVotingScreenState();
}

class _GameVotingScreenState extends State<GameVotingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Map<String, int> _localVotes = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadExistingVotes();
    _setupVotingListeners();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadExistingVotes() {
    final votes = widget.votingService.getPlayerVotes(widget.playerId);
    setState(() {
      _localVotes = Map.from(votes);
    });
  }

  void _setupVotingListeners() {
    // Listen for voting updates from Socket.io (Feature 3.2.3)
    widget.multiplayerService.onVotingUpdate((data) {
      if (mounted && data['lobbyId'] == widget.lobbyId) {
        setState(() {
          // Refresh voting session state
        });
      }
    });
  }

  VotingSession? get _session => widget.votingService.currentSession;

  int get _remainingPoints =>
      widget.votingService.getRemainingPoints(widget.playerId);

  int _getTotalAllocatedPoints() {
    return _localVotes.values.fold(0, (sum, points) => sum + points);
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vote for Games'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(
          child: Text('No active voting session'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Vote for Games - Round ${_session!.currentRound}'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Voting header with points info
          _buildVotingHeader(),
          // Games list
          Expanded(
            child: _buildGamesList(),
          ),
          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildVotingHeader() {
    final totalPoints = _session!.pointsPerPlayer;
    final usedPoints = _getTotalAllocatedPoints();
    final remaining = totalPoints - usedPoints;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Points display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Points',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$remaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Allocated',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$usedPoints / $totalPoints',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: usedPoints / totalPoints,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                usedPoints == totalPoints ? Colors.greenAccent : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Round info
          Text(
            'Round ${_session!.currentRound} of ${_session!.totalRounds} • Select ${_session!.gamesPerRound} game${_session!.gamesPerRound > 1 ? 's' : ''}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList() {
    final availableGames = _session!.availableGames
        .map((id) => GameCatalog.getGameById(id))
        .where((game) => game != null)
        .cast<GameTemplate>()
        .toList();

    if (availableGames.isEmpty) {
      return const Center(
        child: Text('No games available for voting'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableGames.length,
      itemBuilder: (context, index) {
        final game = availableGames[index];
        return _buildGameVoteCard(game);
      },
    );
  }

  Widget _buildGameVoteCard(GameTemplate game) {
    final categoryInfo = GameCatalog.getCategoryInfo(game.category);
    final currentVotes = _localVotes[game.id] ?? 0;
    final totalVotes = widget.votingService.getCurrentResults()[game.id] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game header
            Row(
              children: [
                // Game icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(game.category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      game.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Game info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            categoryInfo['icon']!,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            categoryInfo['name']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Total votes indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: totalVotes > 0
                        ? Colors.deepPurple.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.how_to_vote,
                        size: 16,
                        color: totalVotes > 0 ? Colors.deepPurple : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$totalVotes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: totalVotes > 0 ? Colors.deepPurple : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Vote controls
            Row(
              children: [
                // Minus button
                IconButton(
                  onPressed: currentVotes > 0 ? () => _decrementVote(game.id) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.deepPurple,
                  disabledColor: Colors.grey.shade300,
                ),
                // Points display
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: currentVotes > 0
                          ? Colors.deepPurple.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentVotes > 0
                          ? '$currentVotes point${currentVotes > 1 ? 's' : ''}'
                          : 'No votes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: currentVotes > 0 ? Colors.deepPurple : Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Plus button
                IconButton(
                  onPressed: _remainingPoints > 0 ? () => _incrementVote(game.id) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.deepPurple,
                  disabledColor: Colors.grey.shade300,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _getTotalAllocatedPoints() > 0 && !_isSubmitting;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_getTotalAllocatedPoints() == 0)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Allocate at least 1 point to continue',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: canSubmit ? _submitVotes : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.votingService.allPlayersVoted
                            ? 'Waiting for Others...'
                            : 'Confirm Votes',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _incrementVote(String gameId) {
    if (_remainingPoints > 0) {
      setState(() {
        _localVotes[gameId] = (_localVotes[gameId] ?? 0) + 1;
      });
      _animationController.forward(from: 0);
    }
  }

  void _decrementVote(String gameId) {
    if ((_localVotes[gameId] ?? 0) > 0) {
      setState(() {
        _localVotes[gameId] = _localVotes[gameId]! - 1;
        if (_localVotes[gameId] == 0) {
          _localVotes.remove(gameId);
        }
      });
      _animationController.forward(from: 0);
    }
  }

  Future<void> _submitVotes() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Calculate vote changes and submit to server
      final currentServerVotes = widget.votingService.getPlayerVotes(widget.playerId);
      
      // Remove votes that were decreased
      for (var gameId in currentServerVotes.keys) {
        final currentPoints = currentServerVotes[gameId]!;
        final newPoints = _localVotes[gameId] ?? 0;
        if (newPoints < currentPoints) {
          widget.votingService.removeVote(
            playerId: widget.playerId,
            gameId: gameId,
            points: currentPoints - newPoints,
          );
        }
      }
      
      // Add new votes or increased votes
      for (var entry in _localVotes.entries) {
        final currentPoints = currentServerVotes[entry.key] ?? 0;
        if (entry.value > currentPoints) {
          widget.votingService.castVote(
            playerId: widget.playerId,
            gameId: entry.key,
            points: entry.value - currentPoints,
          );
        }
      }

      // Emit voting update via Socket.io (Feature 3.2.3)
      widget.multiplayerService.emitVoteUpdate(
        widget.lobbyId,
        widget.playerId,
        _localVotes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votes submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Check if all players have voted
        if (widget.votingService.allPlayersVoted) {
          _showAllVotedDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting votes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showAllVotedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('All Votes In!'),
        content: const Text(
          'All players have voted. The host can now end voting and start the games.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(CognitiveCategory category) {
    switch (category) {
      case CognitiveCategory.memory:
        return Colors.blue.shade300;
      case CognitiveCategory.logic:
        return Colors.purple.shade300;
      case CognitiveCategory.attention:
        return Colors.orange.shade300;
      case CognitiveCategory.spatial:
        return Colors.green.shade300;
      case CognitiveCategory.language:
        return Colors.pink.shade300;
    }
  }
}
