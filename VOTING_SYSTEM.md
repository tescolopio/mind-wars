# Game Voting System

## Overview
The game voting system allows players to democratically select which games will be played during a session. Each player receives a configurable number of voting points that they can allocate across available games.

## Features
- **Configurable Points**: The group leader can set how many voting points each player receives
- **Multi-Round Support**: Voting can span multiple rounds, with games selected for each round
- **Flexible Allocation**: Players can distribute their points across multiple games or focus on favorites
- **Real-Time Updates**: All players see vote counts update in real-time via Socket.io
- **Democratic Selection**: The game with the most votes wins each round
- **Minimum Game Requirement**: At least 3 games must be available to ensure meaningful voting choices

## How It Works

### 1. Starting a Voting Session
The lobby host/leader starts a voting session by specifying:
- **Points Per Player**: How many voting points each player receives (e.g., 10 points)
- **Total Rounds**: Number of rounds in the match (e.g., 3 rounds)
- **Games Per Round**: Number of games to select per round (e.g., 2 games)
- **Available Games** (optional): Specific games to vote on (minimum 3), or defaults to all games suitable for the player count

**Match Structure**: A match consists of X rounds, with each round selecting Y games to play. For example:
- 3 rounds × 2 games per round = 6 total games in the match
- 4 rounds × 3 games per round = 12 total games in the match

**Note**: The system requires at least 3 games to be available for voting. This ensures users have meaningful choices to spend their points based on their game preferences.

```dart
final votingService = VotingService();

final session = votingService.createVotingSession(
  lobbyId: 'lobby123',
  pointsPerPlayer: 10,
  totalRounds: 3,          // 3 rounds in the match
  gamesPerRound: 2,        // 2 games selected per round = 6 total games
  playerIds: ['player1', 'player2', 'player3'],
  availableGames: ['memory_match', 'sudoku_duel', 'word_builder', 'puzzle_race'], // optional, min 3 games
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
- The top N games (based on gamesPerRound) are added to the selected games list for that round
- The round counter increments
- All votes are cleared
- Points are reset for all players
- Players vote again for the next round

```dart
// After 3 rounds with 2 games per round, 6 games are selected
final selectedGames = votingService.selectedGames;
// Returns flattened list: ['memory_match', 'sudoku_duel', 'word_builder', 'puzzle_race', 'color_rush', 'anagram_attack']

// Get games organized by round
final gamesByRound = votingService.selectedGamesByRound;
// Returns: [
//   ['memory_match', 'sudoku_duel'],      // Round 1
//   ['word_builder', 'puzzle_race'],       // Round 2
//   ['color_rush', 'anagram_attack']       // Round 3
// ]

// Session is marked as completed
final isCompleted = votingService.currentSession!.completed;
// Returns: true

// Total games in match
final totalGames = votingService.currentSession!.totalGames;
// Returns: 6 (3 rounds × 2 games per round)
```

## Multiplayer Integration

The voting system integrates with the multiplayer service for real-time collaboration:

```dart
final multiplayerService = MultiplayerService();

// Host starts voting session
await multiplayerService.startVotingSession(
  pointsPerPlayer: 10,
  totalRounds: 3,
  gamesPerRound: 2,
  availableGames: ['game1', 'game2', 'game3', 'game4'],
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
final selectedGames = await multiplayerService.endVotingRound();
// Returns list of selected games for the round: ['game1', 'game2']
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
  print('Games selected: ${data['selectedGames']}');
});
```

## Example User Flow

1. **Setup Phase**
   - Lobby host creates a voting session with 10 points per player for 3 rounds, 2 games per round
   - Total games in match: 6 (3 rounds × 2 games)
   - Available games: Memory Match, Sudoku Duel, Word Builder, Puzzle Race

2. **Round 1 - Voting**
   - Player 1: 6 points → Memory Match, 4 points → Sudoku Duel
   - Player 2: 8 points → Memory Match, 2 points → Word Builder
   - Player 3: 5 points → Sudoku Duel, 5 points → Word Builder
   - **Result**: Top 2 games selected → Memory Match (14 points), Sudoku Duel (9 points)

3. **Round 2 - Voting**
   - Player 1: 7 points → Word Builder, 3 points → Puzzle Race
   - Player 2: 6 points → Word Builder, 4 points → Puzzle Race
   - Player 3: 10 points → Puzzle Race
   - **Result**: Top 2 games selected → Puzzle Race (17 points), Word Builder (13 points)

4. **Round 3 - Voting**
   - Player 1: 5 points → Memory Match, 5 points → Sudoku Duel
   - Player 2: 7 points → Memory Match, 3 points → Sudoku Duel
   - Player 3: 4 points → Memory Match, 6 points → Puzzle Race
   - **Result**: Top 2 games selected → Memory Match (16 points), Sudoku Duel (14 points)

5. **Game Session**
   - **Round 1**: Memory Match, Sudoku Duel
   - **Round 2**: Puzzle Race, Word Builder
   - **Round 3**: Memory Match, Sudoku Duel
   - Total: 6 games across 3 rounds
   - Session complete!

## Best Practices

1. **Point Allocation**
   - Give enough points to allow meaningful distribution (10-20 points recommended)
   - More points = more granular voting options

2. **Games Per Round**
   - Consider session length: 2-3 games per round works well
   - More games per round = longer play sessions but more variety

3. **Round Count**
   - Match round count to desired session length
   - 3-5 rounds works well for most play sessions
   - Total match length = rounds × games per round

4. **Game Selection**
   - Limit available games to those suitable for your player count
   - Consider player preferences and skill levels
   - Ensure at least 3 games (minimum requirement)
   - Ideally, have more games available than gamesPerRound to allow for variety

5. **Time Management**
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
