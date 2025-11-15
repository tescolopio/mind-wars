# Vote-to-Skip Feature: Complete Walkthroughs

**Feature**: Vote-to-Skip (Skip AFK/Slow Player's Turn During Gameplay)
**Minimum Players**: 3 (requires majority vote)
**Purpose**: Keep games moving when a player is AFK or taking too long

---

## Mind Wars Terminology Reference

| Term | Definition | Example |
|------|------------|---------|
| **Mind War** | The entire multiplayer session from lobby creation to completion | "Family Gaming Night" with 4 players |
| **Lobby** | The waiting room where players gather and configure settings | Status: `waiting` → `in-progress` → `completed` |
| **Round** | One cycle of voting → game selection → playing selected games | Round 1 of 3 |
| **Game** | A single cognitive game that players compete in | Memory Match, Sudoku Duel, Word Builder |
| **Voting Session** | Democratic point-allocation system to select which games to play | Each player gets 10 points per round |
| **Turn** | One player's move/action during a game | Player 1's turn in Memory Match |
| **Vote-to-Skip** | Majority vote to skip an AFK/slow player's turn | 2 out of 3 players vote → skip executed |

---

## Scenario 1: 2-Player Mind War (Vote-to-Skip NOT Available)

**Players**: Alice (Host), Bob
**Configuration**: 2 rounds, 2 games per round, 10 voting points per player
**Duration**: ~20-30 minutes

### Complete Flow

```
═══════════════════════════════════════════════════════════════
PHASE 1: LOBBY SETUP
═══════════════════════════════════════════════════════════════

Step 1: Alice Creates Lobby
├─ Lobby Name: "Quick Mind War"
├─ Max Players: 2
├─ Total Rounds: 2
├─ Games Per Round: 2
├─ Voting Points: 10 per player
├─ Privacy: Private
└─ Lobby Code Generated: "SWIFT42"

Step 2: Bob Joins
├─ Enters code: "SWIFT42"
├─ Joins lobby successfully
└─ Alice sees: "Bob joined the lobby"

Step 3: Lobby Status
├─ Players: Alice (Host), Bob
├─ Status: 'waiting'
├─ Ready to start: ✅ (minimum 2 players)
└─ Vote-to-Skip Available: ❌ (needs minimum 3 players)


═══════════════════════════════════════════════════════════════
PHASE 2: ROUND 1 - VOTING
═══════════════════════════════════════════════════════════════

Step 4: Alice Starts Voting for Round 1
├─ Button: "Start Game" → Opens Game Voting Screen
├─ System creates VotingSession:
│  ├─ currentRound: 1
│  ├─ totalRounds: 2
│  └─ Each player gets 10 points
└─ Both players navigate to voting screen

Step 5: Players Vote on Games (Round 1)

Alice's Votes (10 points total):
├─ Memory Match: 6 points
├─ Sudoku Duel: 4 points
└─ Remaining: 0 points

Bob's Votes (10 points total):
├─ Memory Match: 3 points
├─ Word Builder: 5 points
├─ Sudoku Duel: 2 points
└─ Remaining: 0 points

Step 6: Alice Ends Voting
├─ Button: "End Voting"
├─ System tallies votes:
│  ├─ Memory Match: 6 + 3 = 9 points (1st place) ✅
│  ├─ Sudoku Duel: 4 + 2 = 6 points (2nd place) ✅
│  └─ Word Builder: 0 + 5 = 5 points (3rd place) ❌
└─ Selected games for Round 1: [Memory Match, Sudoku Duel]


═══════════════════════════════════════════════════════════════
PHASE 3: ROUND 1 - PLAYING GAMES
═══════════════════════════════════════════════════════════════

Step 7: Play Game 1 - Memory Match
├─ Lobby Status: 'waiting' → 'in-progress'
├─ Turn Order: Alice (Turn 1) → Bob (Turn 2) → Alice (Turn 3) → ...
│
├─ Turn 1: Alice's Turn
│  ├─ Alice flips 2 cards
│  ├─ No match → cards flip back
│  ├─ Alice's score: 0
│  └─ System: "Bob's turn"
│
├─ Turn 2: Bob's Turn
│  ├─ Bob flips 2 cards
│  ├─ Match! → cards stay revealed
│  ├─ Bob's score: 10 points
│  └─ System: "Alice's turn"
│
├─ Turn 3: Alice's Turn
│  ├─ [SCENARIO: Alice goes AFK - doesn't respond]
│  ├─ ⏰ Timeout: 60 seconds
│  ├─ ⚠️ Vote-to-Skip Button Shows: ❌ (needs 3+ players)
│  ├─ System: Waits full 60 seconds
│  ├─ Auto-skip after timeout
│  └─ System: "Bob's turn"
│
│  💡 NOTE: With only 2 players, vote-to-skip is NOT available
│           The game must wait for timeout before auto-skipping
│
└─ Game continues until completion
   Final Scores: Bob: 50 points, Alice: 30 points

Step 8: Play Game 2 - Sudoku Duel
├─ Similar turn-based gameplay
├─ No vote-to-skip available (only 2 players)
└─ Final Scores: Alice: 70 points, Bob: 60 points


═══════════════════════════════════════════════════════════════
PHASE 4: ROUND 2 - VOTING & PLAYING
═══════════════════════════════════════════════════════════════

Step 9: Voting for Round 2
├─ System resets voting points (10 each)
├─ Players vote again for new games
├─ Top 2 games selected
└─ Games played

Step 10: Round 2 Games Complete
├─ All scores tallied across both rounds
└─ Winner determined


═══════════════════════════════════════════════════════════════
PHASE 5: MIND WAR COMPLETE
═══════════════════════════════════════════════════════════════

Step 11: Final Results
├─ Total Scores:
│  ├─ Alice: 150 points
│  └─ Bob: 180 points
├─ Winner: Bob 🏆
└─ Lobby Status: 'completed'

Step 12: Alice Closes Lobby
├─ Players returned to lobby browser
└─ Mind War session ended
```

### Key Takeaway: 2-Player Limitations

❌ **Vote-to-Skip NOT Available**
- Only 1 other player (cannot have majority vote)
- Must rely on timeout system
- Slower gameplay if player goes AFK

⏰ **Timeout System**
- Default: 60 seconds per turn
- Auto-skip after timeout expires
- No manual skip option

---

## Scenario 2: 3-Player Mind War (Vote-to-Skip AVAILABLE)

**Players**: Alice (Host), Bob, Carol
**Configuration**: 2 rounds, 2 games per round, 10 voting points per player
**Duration**: ~25-35 minutes

### Complete Flow

```
═══════════════════════════════════════════════════════════════
PHASE 1: LOBBY SETUP
═══════════════════════════════════════════════════════════════

Step 1: Alice Creates Lobby
├─ Lobby Name: "Friends Mind War"
├─ Max Players: 4
├─ Total Rounds: 2
├─ Games Per Round: 2
├─ Voting Points: 10 per player
├─ Privacy: Private
└─ Lobby Code: "BRAIN99"

Step 2: Bob & Carol Join
├─ Bob enters "BRAIN99" → Joins
├─ Carol enters "BRAIN99" → Joins
└─ All 3 players in lobby

Step 3: Lobby Status
├─ Players: Alice (Host), Bob, Carol
├─ Status: 'waiting'
├─ Ready to start: ✅
└─ Vote-to-Skip Available: ✅ (3 players = majority voting possible)


═══════════════════════════════════════════════════════════════
PHASE 2: ROUND 1 - VOTING
═══════════════════════════════════════════════════════════════

Step 4: Alice Starts Voting for Round 1
├─ All 3 players get 10 voting points each
└─ Navigate to Game Voting Screen

Step 5: Players Vote on Games (Round 1)

Alice's Votes (10 points):
├─ Memory Match: 5 points
├─ Puzzle Race: 5 points

Bob's Votes (10 points):
├─ Memory Match: 8 points
├─ Sudoku Duel: 2 points

Carol's Votes (10 points):
├─ Word Builder: 6 points
├─ Puzzle Race: 4 points

Step 6: Alice Ends Voting
├─ System tallies votes:
│  ├─ Memory Match: 5 + 8 + 0 = 13 points (1st) ✅
│  ├─ Puzzle Race: 5 + 0 + 4 = 9 points (2nd) ✅
│  ├─ Word Builder: 0 + 0 + 6 = 6 points (3rd) ❌
│  └─ Sudoku Duel: 0 + 2 + 0 = 2 points (4th) ❌
└─ Selected for Round 1: [Memory Match, Puzzle Race]


═══════════════════════════════════════════════════════════════
PHASE 3: ROUND 1 - PLAYING GAMES (WITH VOTE-TO-SKIP)
═══════════════════════════════════════════════════════════════

Step 7: Play Game 1 - Memory Match
├─ Turn Order: Alice → Bob → Carol → Alice → ...
│
├─ Turn 1: Alice's Turn
│  ├─ Alice flips 2 cards → No match
│  ├─ Score: 0
│  └─ Next: Bob's turn
│
├─ Turn 2: Bob's Turn
│  ├─ Bob flips 2 cards → Match! ✅
│  ├─ Score: +10 points
│  └─ Next: Carol's turn
│
├─ Turn 3: Carol's Turn
│  ├─ [SCENARIO: Carol goes AFK - no response]
│  ├─ ⏰ Timer starts: 60 seconds
│  │
│  ├─ At 20 seconds: Alice initiates Vote-to-Skip
│  │  └─ Alice clicks "Vote to Skip Carol's Turn"
│  │
│  ├─ Vote-to-Skip UI appears for all players:
│  │  ┌────────────────────────────────────────────┐
│  │  │  Vote to Skip Carol's Turn?                │
│  │  │                                            │
│  │  │  Carol hasn't responded in 40 seconds     │
│  │  │                                            │
│  │  │  Votes: 1/2 required                      │
│  │  │  ✅ Alice (voted to skip)                  │
│  │  │  ⏳ Bob (not voted yet)                    │
│  │  │  👤 Carol (AFK - being skipped)            │
│  │  │                                            │
│  │  │  [Vote to Skip]  [Cancel]                 │
│  │  └────────────────────────────────────────────┘
│  │
│  ├─ At 25 seconds: Bob votes to skip
│  │  ├─ Bob clicks "Vote to Skip"
│  │  ├─ Votes: 2/2 (majority reached!) ✅
│  │  └─ System: "Majority vote reached - skipping turn"
│  │
│  └─ Turn 3 Result:
│     ├─ Carol's turn skipped automatically
│     ├─ Carol receives 0 points for this turn
│     ├─ Turn counter incremented
│     ├─ Notification: "Carol's turn was skipped by vote"
│     └─ System: "Alice's turn"
│
├─ Turn 4: Alice's Turn (continues normally)
│  └─ Game progresses...
│
└─ Game Complete
   Final Scores: Bob: 50, Alice: 40, Carol: 20


═══════════════════════════════════════════════════════════════
VOTE-TO-SKIP MECHANICS BREAKDOWN
═══════════════════════════════════════════════════════════════

Majority Calculation (3 players):
├─ Total players: 3
├─ Player being skipped: Carol (cannot vote)
├─ Eligible voters: 2 (Alice, Bob)
├─ Required for majority: 50% + 1 = 2 votes
└─ Result: Both Alice AND Bob must vote to skip

Vote Window:
├─ Initiated by: Any player (Alice or Bob)
├─ Vote window duration: 30 seconds (or until turn timeout)
├─ If majority not reached: Vote cancelled, turn continues
└─ If majority reached: Turn skipped immediately

Skip Button Visibility:
├─ Appears: When turn timer > 20 seconds elapsed
├─ Visible to: All players EXCEPT the current player
├─ Disabled for: The player whose turn it is (Carol)
└─ Shows: Real-time vote count (1/2, 2/2)

Penalties (Future Enhancement):
├─ Player being skipped: -10 points penalty
├─ Streak broken: If player had a win streak
└─ Warning: After 2 skips in a game, player may be kicked


═══════════════════════════════════════════════════════════════
PHASE 4: CONTINUE GAMEPLAY
═══════════════════════════════════════════════════════════════

Step 8: Carol Returns
├─ Carol comes back from AFK
├─ Notification: "You missed your turn (vote-to-skip)"
├─ Carol continues playing on next turn
└─ No permanent penalty (just lost turn points)

Step 9: Play Game 2 - Puzzle Race
├─ All players active
├─ No vote-to-skip needed
└─ Game completes normally


═══════════════════════════════════════════════════════════════
PHASE 5: ROUND 2 - VOTING & PLAYING
═══════════════════════════════════════════════════════════════

Step 10: Round 2 Voting
├─ Voting points reset (10 each)
├─ Players vote for new games
└─ Top 2 selected

Step 11: Round 2 Games
├─ Games played
└─ Final scores tallied


═══════════════════════════════════════════════════════════════
PHASE 6: MIND WAR COMPLETE
═══════════════════════════════════════════════════════════════

Step 12: Final Results
├─ Total Scores:
│  ├─ Bob: 190 points 🏆
│  ├─ Alice: 160 points
│  └─ Carol: 140 points
├─ Winner: Bob
└─ Lobby Status: 'completed'
```

### Key Takeaway: 3+ Player Benefits

✅ **Vote-to-Skip AVAILABLE**
- Majority voting possible (2 out of 2 eligible voters)
- Faster resolution for AFK players
- Democratic decision-making

⚡ **Faster Gameplay**
- Don't wait full timeout (60s)
- Skip can happen in ~20-30 seconds
- Better user experience

🎮 **Better Flow**
- Active players control the pace
- Less frustration with AFK players
- Games progress smoothly

---

## Scenario 3: 5-Player Mind War (Vote-to-Skip with Different Majority)

**Players**: Alice, Bob, Carol, Dave, Eve
**Vote-to-Skip Example**: Carol goes AFK during her turn

### Vote-to-Skip Mechanics (5 players)

```
Majority Calculation:
├─ Total players: 5
├─ Player being skipped: Carol (cannot vote on her own skip)
├─ Eligible voters: 4 (Alice, Bob, Dave, Eve)
├─ Required for majority: 50% + 1 = 3 votes
└─ Result: 3 out of 4 must vote to skip Carol's turn

Example Vote Sequence:
├─ Time 0s: Carol's turn starts
├─ Time 20s: Alice initiates vote-to-skip
│  └─ Votes: 1/3
├─ Time 25s: Bob votes to skip
│  └─ Votes: 2/3
├─ Time 30s: Dave votes to skip
│  └─ Votes: 3/3 ✅ MAJORITY REACHED
├─ Time 30s: Turn skipped immediately
│  └─ Eve's vote not needed (majority already achieved)
└─ Next turn starts
```

---

## Technical Implementation Requirements

### Database Schema

```sql
-- Vote-to-skip tracking table
CREATE TABLE IF NOT EXISTS vote_to_skip_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    game_id VARCHAR(50) NOT NULL,
    player_id_to_skip UUID NOT NULL REFERENCES users(id),
    initiated_by UUID NOT NULL REFERENCES users(id),
    votes_required INTEGER NOT NULL,
    votes_count INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active', -- active, executed, cancelled
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    executed_at TIMESTAMP,
    cancelled_at TIMESTAMP
);

-- Individual skip votes
CREATE TABLE IF NOT EXISTS vote_to_skip_votes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES vote_to_skip_sessions(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES users(id),
    voted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(session_id, voter_id)
);

CREATE INDEX idx_vote_to_skip_sessions_lobby_id ON vote_to_skip_sessions(lobby_id);
CREATE INDEX idx_vote_to_skip_sessions_status ON vote_to_skip_sessions(status);
CREATE INDEX idx_vote_to_skip_votes_session_id ON vote_to_skip_votes(session_id);
```

### Socket.io Events

```javascript
// Client → Server
'initiate-skip-vote'   // Player starts a vote-to-skip
'cast-skip-vote'       // Player votes to skip
'cancel-skip-vote'     // Player cancels their vote

// Server → Client
'skip-vote-initiated'  // Broadcast: Skip vote started
'skip-vote-updated'    // Broadcast: Vote count changed (1/2, 2/2)
'skip-vote-executed'   // Broadcast: Turn skipped
'skip-vote-cancelled'  // Broadcast: Vote window closed
```

### Flutter Models

```dart
class VoteToSkipSession {
  final String id;
  final String lobbyId;
  final String gameId;
  final String playerIdToSkip;
  final String playerNameToSkip;
  final String initiatedBy;
  final int votesRequired;        // 2 for 3 players, 3 for 5 players
  final int votesCount;            // Current votes
  final Map<String, bool> votes;   // userId → voted
  final String status;             // 'active', 'executed', 'cancelled'
  final DateTime createdAt;
  final DateTime? executedAt;

  bool get isExecuted => votesCount >= votesRequired;
  int get votesRemaining => votesRequired - votesCount;
}
```

### UI Components

```dart
// Vote-to-skip button (shown when turn > 20s elapsed)
FloatingActionButton(
  onPressed: _initiateSkipVote,
  child: Icon(Icons.skip_next),
  tooltip: 'Vote to skip ${currentPlayer.name}\'s turn',
);

// Vote-to-skip dialog
AlertDialog(
  title: Text('Vote to Skip ${playerName}\'s Turn?'),
  content: Column(
    children: [
      Text('${playerName} hasn\'t responded in ${elapsedSeconds}s'),
      SizedBox(height: 16),
      Text('Votes: ${votesCount}/${votesRequired}'),
      SizedBox(height: 8),
      ...playerList.map((player) =>
        ListTile(
          leading: player.voted
            ? Icon(Icons.check, color: Colors.green)
            : Icon(Icons.hourglass_empty),
          title: Text(player.name),
        )
      ),
    ],
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('Cancel'),
    ),
    ElevatedButton(
      onPressed: _castSkipVote,
      child: Text('Vote to Skip'),
    ),
  ],
);
```

---

## Summary: 2 vs 3+ Players

| Feature | 2 Players | 3+ Players |
|---------|-----------|------------|
| **Vote-to-Skip** | ❌ Not available | ✅ Available |
| **Skip Method** | Auto-skip after timeout only | Vote-to-skip OR auto-skip |
| **Turn Timeout** | Full 60 seconds | Can skip in 20-30s with votes |
| **Majority Needed** | N/A (no voting) | 50% + 1 of eligible voters |
| **User Experience** | Slower if AFK occurs | Faster, more dynamic |
| **Democracy** | No voting mechanism | Players control pace |

---

## Next Steps

1. **Backend Implementation**
   - Create database tables for skip votes
   - Implement majority calculation logic
   - Add Socket.io event handlers
   - Track vote history

2. **Frontend Implementation**
   - Add skip button to game screens
   - Create vote-to-skip dialog UI
   - Show real-time vote counts
   - Handle notifications

3. **Testing**
   - Test with 2 players (skip NOT shown)
   - Test with 3 players (2/2 majority)
   - Test with 5 players (3/4 majority)
   - Test timeout scenarios
   - Test cancellation flows
