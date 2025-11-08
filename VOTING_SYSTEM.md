# Game Voting System

## Overview
The game voting system allows players to democratically select which games will be played during a session. Each player receives a configurable number of voting points that they can allocate across available games.

## Features
- **Configurable Points**: The group leader can set how many voting points each player receives
- **Multi-Round Support**: Voting can span multiple rounds, with games selected for each round
- **Flexible Allocation**: Players can distribute their points across multiple games or focus on favorites
- **Real-Time Updates**: All players see vote counts update in real-time via Socket.io
- **Democratic Selection**: The game with the most votes wins each round

## How It Works

### 1. Starting a Voting Session
The lobby host/leader starts a voting session by specifying:
- **Points Per Player**: How many voting points each player receives (e.g., 10 points)
- **Total Rounds**: Number of games to select (e.g., 3 rounds)
- **Available Games** (optional): Specific games to vote on, or defaults to all games suitable for the player count

```dart
final votingService = VotingService();

final session = votingService.createVotingSession(
  lobbyId: 'lobby123',
  pointsPerPlayer: 10,
  totalRounds: 3,
  playerIds: ['player1', 'player2', 'player3'],
  availableGames: ['memory_match', 'sudoku_duel', 'word_builder'], // optional
);
```

### 2. Casting Votes
Players allocate their points to games they want to play:

```dart
// Player 1 votes for Memory Match with 5 points
votingService.castVote(
  playerId: 'player1',
  gameId: 'memory_match',
  points: 5,
);

// Player 1 votes for Sudoku Duel with 3 points
votingService.castVote(
  playerId: 'player1',
  gameId: 'sudoku_duel',
  points: 3,
);
// Player 1 now has 2 points remaining
```

Players can vote multiple times for the same game to allocate more points:

```dart
// Add 2 more points to Memory Match
votingService.castVote(
  playerId: 'player1',
  gameId: 'memory_match',
  points: 2,
);
// Memory Match now has 7 points from player1
```

### 3. Removing Votes
Players can change their minds and remove votes:

```dart
// Remove 3 points from Memory Match
votingService.removeVote(
  playerId: 'player1',
  gameId: 'memory_match',
  points: 3,
);

// Remove all votes from a game
votingService.removeVote(
  playerId: 'player1',
  gameId: 'sudoku_duel',
);
```

### 4. Checking Vote Status
Query the current state of voting:

```dart
// Get remaining points for a player
final remaining = votingService.getRemainingPoints('player1');

// Get a player's current votes
final votes = votingService.getPlayerVotes('player1');
// Returns: {'memory_match': 4, 'sudoku_duel': 3}

// Get current vote totals across all players
final results = votingService.getCurrentResults();
// Returns: {'memory_match': 15, 'sudoku_duel': 8, 'word_builder': 7}

// Check if all players have voted
final allVoted = votingService.allPlayersVoted;
```

### 5. Ending a Round
Once voting is complete, the host ends the round:

```dart
// End voting and get the winning game
final selectedGame = votingService.endVotingRound();
// Returns: 'memory_match' (game with most votes)

// The session automatically moves to the next round
// Points are reset for all players
```

### 6. Multi-Round Progression
After each round:
- The winning game is added to the selected games list
- The round counter increments
- All votes are cleared
- Points are reset for all players
- Players vote again for the next round

```dart
// After 3 rounds, all games are selected
final selectedGames = votingService.selectedGames;
// Returns: ['memory_match', 'sudoku_duel', 'word_builder']

// Session is marked as completed
final isCompleted = votingService.currentSession!.completed;
// Returns: true
```

## Multiplayer Integration

The voting system integrates with the multiplayer service for real-time collaboration:

```dart
final multiplayerService = MultiplayerService();

// Host starts voting session
await multiplayerService.startVotingSession(
  pointsPerPlayer: 10,
  totalRounds: 3,
  availableGames: ['game1', 'game2', 'game3'],
);

// Players cast votes
await multiplayerService.voteForGame(
  gameId: 'game1',
  points: 5,
);

// Players remove votes
await multiplayerService.removeGameVote(
  gameId: 'game1',
  points: 2,
);

// Host ends voting round
final selectedGame = await multiplayerService.endVotingRound();
```

### Socket.io Events

**Client → Server:**
- `start-voting` - Host starts a voting session
- `vote-game` - Player casts a vote
- `remove-vote` - Player removes a vote
- `end-voting` - Host ends the current voting round

**Server → Client:**
- `voting-started` - Voting session has begun
- `vote-cast` - A player cast a vote (real-time update)
- `voting-update` - Vote totals updated
- `voting-ended` - Voting round completed, game selected

### Listening to Events

```dart
// Listen for voting events
multiplayerService.on('voting-started', (data) {
  print('Voting started: ${data['votingSession']}');
});

multiplayerService.on('vote-cast', (data) {
  print('Player ${data['playerId']} voted for ${data['gameId']}');
});

multiplayerService.on('voting-update', (data) {
  print('Current results: ${data['results']}');
});

multiplayerService.on('voting-ended', (data) {
  print('Game selected: ${data['selectedGame']}');
});
```

## Example User Flow

1. **Setup Phase**
   - Lobby host creates a voting session with 10 points per player for 3 rounds
   - Available games: Memory Match, Sudoku Duel, Word Builder

2. **Round 1 - Voting**
   - Player 1: 6 points → Memory Match, 4 points → Sudoku Duel
   - Player 2: 8 points → Memory Match, 2 points → Word Builder
   - Player 3: 5 points → Sudoku Duel, 5 points → Word Builder
   - **Result**: Memory Match wins (14 points)

3. **Round 2 - Voting**
   - Player 1: 7 points → Sudoku Duel, 3 points → Word Builder
   - Player 2: 6 points → Word Builder, 4 points → Sudoku Duel
   - Player 3: 10 points → Sudoku Duel
   - **Result**: Sudoku Duel wins (21 points)

4. **Round 3 - Voting**
   - Player 1: 10 points → Word Builder
   - Player 2: 10 points → Word Builder
   - Player 3: 10 points → Word Builder
   - **Result**: Word Builder wins (30 points)

5. **Game Session**
   - Games played in order: Memory Match → Sudoku Duel → Word Builder
   - Session complete!

## Best Practices

1. **Point Allocation**
   - Give enough points to allow meaningful distribution (10-20 points recommended)
   - More points = more granular voting options

2. **Round Count**
   - Match round count to desired session length
   - 3-5 rounds works well for most play sessions

3. **Game Selection**
   - Limit available games to those suitable for your player count
   - Consider player preferences and skill levels

4. **Time Management**
   - Set reasonable voting time limits on the server side
   - Auto-end voting after timeout or when all players have used their points

5. **Tie Breaking**
   - In case of ties, consider: random selection, host choice, or additional tie-breaker round
   - Current implementation: first game with max votes wins (deterministic)

## Error Handling

The voting service includes comprehensive error handling:

```dart
try {
  votingService.castVote(
    playerId: 'player1',
    gameId: 'invalid_game',
    points: 5,
  );
} catch (e) {
  print('Error: $e');
  // Error: Game not available for voting
}
```

Common errors:
- `No active voting session` - Voting hasn't started
- `Voting is closed` - Round has ended
- `Not enough points` - Trying to vote with more points than available
- `Game not available for voting` - Invalid game ID
- `Player not in voting session` - Player not part of the lobby

## Testing

The voting system includes comprehensive tests covering:
- Session creation and validation
- Vote casting and removal
- Round progression
- Multi-round scenarios
- Edge cases and error conditions
- Model serialization

Run tests:
```bash
flutter test test/voting_service_test.dart
```

## Future Enhancements

Potential improvements to the voting system:
- **Ranked Choice Voting**: Players rank games instead of allocating points
- **Weighted Voting**: Host/veteran players get more voting power
- **Veto System**: Allow vetoing of games with super-majority
- **Vote History**: Track voting patterns and preferences
- **Smart Recommendations**: Suggest games based on past voting behavior
