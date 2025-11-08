# Mind Wars - Sprint Planning Templates 📅

## Document Purpose
This document provides standardized templates and checklists for sprint planning, execution, and retrospectives to ensure consistent and effective agile delivery.

**Last Updated**: November 2025  
**Version**: 1.0

---

## Table of Contents
1. [Sprint Planning Template](#sprint-planning-template)
2. [Sprint Goal Template](#sprint-goal-template)
3. [Daily Standup Template](#daily-standup-template)
4. [Sprint Review Template](#sprint-review-template)
5. [Sprint Retrospective Template](#sprint-retrospective-template)
6. [Sprint Health Check](#sprint-health-check)

---

## Sprint Planning Template

### Sprint Information
```
Sprint Number: [e.g., Sprint 5]
Sprint Duration: [Start Date] - [End Date]
Phase: [MVP / Social & Progression / Offline & Polish]
Team Capacity: [Total story points available]
Team Members: [List of engineers with capacity]
```

### Sprint Goal
```
Sprint Goal: [One sentence describing what we want to achieve]

Success Criteria:
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]
- [ ] [Measurable outcome 3]

Personas Served: [List primary personas benefiting from this sprint]
```

### Selected Backlog Items

#### Epic: [Epic Name]

**Feature 1: [Feature Name]** - [Priority] - [Story Points]
- **Story**: As a [persona], I want [goal] so that [benefit]
- **Acceptance Criteria**:
  - [ ] Criterion 1
  - [ ] Criterion 2
  - [ ] Criterion 3
- **Tasks**:
  - [ ] Task 1 - [Owner] - [Est. hours]
  - [ ] Task 2 - [Owner] - [Est. hours]
  - [ ] Task 3 - [Owner] - [Est. hours]
- **Dependencies**: [None / List dependencies]
- **Risks**: [None / List risks]

**Feature 2: [Feature Name]** - [Priority] - [Story Points]
- **Story**: As a [persona], I want [goal] so that [benefit]
- **Acceptance Criteria**:
  - [ ] Criterion 1
  - [ ] Criterion 2
- **Tasks**:
  - [ ] Task 1 - [Owner] - [Est. hours]
  - [ ] Task 2 - [Owner] - [Est. hours]
- **Dependencies**: [None / List dependencies]
- **Risks**: [None / List risks]

### Sprint Backlog Summary
```
Total Story Points Committed: [X points]
Team Capacity: [Y points]
Capacity Utilization: [X/Y = Z%]

Breakdown by Priority:
- P0 (Critical): [X points]
- P1 (High): [Y points]
- P2 (Medium): [Z points]

Breakdown by Epic:
- Epic 1: [X points]
- Epic 2: [Y points]
- Epic 3: [Z points]
```

### Definition of Done Reminder
- [ ] All tasks completed and code merged
- [ ] Unit tests written (>80% coverage)
- [ ] Integration tests passing
- [ ] Tested on iOS and Android
- [ ] Code reviewed and approved
- [ ] Performance meets targets
- [ ] Security review passed (if applicable)
- [ ] Documentation updated
- [ ] Product owner approval
- [ ] Deployed to staging environment

### Sprint Risks & Mitigation
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| [Risk 1] | High/Med/Low | High/Med/Low | [Action plan] |
| [Risk 2] | High/Med/Low | High/Med/Low | [Action plan] |

### Team Agreements
- [ ] Sprint goal is clear and agreed upon
- [ ] All stories meet Definition of Ready
- [ ] Capacity planning accounts for holidays/PTO
- [ ] Daily standup time confirmed: [Time]
- [ ] Demo preparation owner: [Name]
- [ ] Sprint retrospective facilitator: [Name]

---

## Sprint Goal Template

### Example Sprint Goals by Phase

**Phase 1: MVP**
```
Sprint 1 Goal: "Establish authentication foundation and basic lobby creation"
Success Criteria:
- Users can register and login securely
- Users can create private lobbies with shareable codes
- Socket.io multiplayer connection established

Sprint 2 Goal: "Complete core lobby management and game selection"
Success Criteria:
- Players can join lobbies via codes
- Host can manage lobby (start, kick, settings)
- Game catalog UI displays 12+ games by category

Sprint 3 Goal: "Enable turn-based gameplay and democratic voting"
Success Criteria:
- Players can vote on games with point allocation
- Turn-based gameplay works asynchronously
- Real-time updates via Socket.io functional
```

**Phase 2: Social & Progression**
```
Sprint 4 Goal: "Launch social features for family/friend bonding"
Success Criteria:
- In-game chat with profanity filtering
- Emoji reactions working in real-time
- Vote-to-skip mechanics implemented

Sprint 5 Goal: "Establish progression system for retention"
Success Criteria:
- Weekly leaderboards displaying rankings
- 15+ badges unlockable across categories
- Streak tracking with multipliers functional
```

**Phase 3: Offline & Polish**
```
Sprint 6 Goal: "Enable reliable offline gameplay"
Success Criteria:
- Games fully playable without internet
- Sync queue automatically processes on reconnect
- Conflict resolution working (server wins)

Sprint 7 Goal: "Polish and optimize for production launch"
Success Criteria:
- Cross-platform multiplayer tested and stable
- Performance targets met (< 500ms API, >99.9% uptime)
- Analytics instrumentation complete
```

### Sprint Goal Quality Checklist
- [ ] Clearly states what the team wants to achieve
- [ ] Aligns with phase and epic objectives
- [ ] Serves at least one primary persona need
- [ ] Has 2-4 measurable success criteria
- [ ] Is achievable within sprint timeframe
- [ ] Provides focus and direction for the team
- [ ] Can be explained in one sentence

---

## Daily Standup Template

### Format: 15 Minutes Maximum

**Each Team Member Answers:**
1. **What did I complete yesterday?**
   - [Completed item 1]
   - [Completed item 2]

2. **What will I work on today?**
   - [Planned item 1]
   - [Planned item 2]

3. **Are there any blockers or impediments?**
   - [Blocker 1] - Need: [What's needed to unblock]
   - [Blocker 2] - Need: [What's needed to unblock]

### Standup Facilitation Notes
- **Time**: [Fixed time, e.g., 9:30 AM daily]
- **Location**: [Virtual link / Physical location]
- **Scrum Master**: Timekeep, track blockers
- **Parking Lot**: Deep discussions move offline
- **Update Board**: Visual board updated during standup

### Blocker Tracking
| Blocker | Owner | Status | Target Resolution |
|---------|-------|--------|-------------------|
| [Description] | [Name] | Open/In Progress/Resolved | [Date] |

### Sprint Burndown Check
```
Day [X] of [14]:
- Story Points Completed: [Y]
- Story Points Remaining: [Z]
- On Track: [Yes/No]
- Concerns: [List any concerns]
```

---

## Sprint Review Template

### Sprint Review Agenda (1 Hour)

**1. Sprint Overview (5 minutes)**
- Sprint goal and what was planned
- Sprint metrics and velocity
- Team composition and capacity

**2. Demo: What We Built (35 minutes)**

**Feature 1: [Feature Name]** - [Story Points]
- **Demo Owner**: [Name]
- **Persona Served**: [Persona name]
- **What to Show**:
  - [ ] Demo point 1
  - [ ] Demo point 2
  - [ ] Demo point 3
- **Acceptance Criteria Met**:
  - [x] Criterion 1 ✓
  - [x] Criterion 2 ✓
  - [ ] Criterion 3 - Deferred to next sprint
- **Feedback Captured**:
  - [Stakeholder comment 1]
  - [Stakeholder comment 2]

**Feature 2: [Feature Name]** - [Story Points]
- **Demo Owner**: [Name]
- **Persona Served**: [Persona name]
- **What to Show**:
  - [ ] Demo point 1
  - [ ] Demo point 2
- **Acceptance Criteria Met**:
  - [x] Criterion 1 ✓
  - [x] Criterion 2 ✓
- **Feedback Captured**:
  - [Stakeholder comment 1]

**3. What Didn't Get Done (5 minutes)**
- [ ] Incomplete item 1 - Reason: [Why] - Plan: [Carry over / Re-prioritize]
- [ ] Incomplete item 2 - Reason: [Why] - Plan: [Carry over / Re-prioritize]

**4. Sprint Metrics (5 minutes)**
```
Planned Story Points: [X]
Completed Story Points: [Y]
Sprint Velocity: [Y points]
Velocity Trend: [Up/Down/Stable]

Sprint Goal Achievement: [Fully Met / Partially Met / Not Met]
Success Criteria Met: [3/3 or X/Y]
```

**5. Backlog Refinement (5 minutes)**
- Next sprint candidates reviewed
- Top priorities reconfirmed
- New insights incorporated

**6. Q&A and Feedback (5 minutes)**
- Open discussion
- Stakeholder questions
- Action items captured

### Action Items from Review
| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| [Action 1] | [Name] | [Date] | Open/In Progress/Done |
| [Action 2] | [Name] | [Date] | Open/In Progress/Done |

---

## Sprint Retrospective Template

### Sprint Retrospective Agenda (1 Hour)

**Format**: Start-Stop-Continue + Action Items

**1. Set the Stage (5 minutes)**
- Review sprint metrics
- Remind of retrospective prime directive
- Set positive, constructive tone

**2. Gather Data (15 minutes)**

**What Went Well? 😊**
- [Thing that went well 1]
- [Thing that went well 2]
- [Thing that went well 3]

**What Could Be Improved? 🤔**
- [Thing to improve 1]
- [Thing to improve 2]
- [Thing to improve 3]

**What Puzzles Us? 🤷**
- [Confusing or unclear thing 1]
- [Confusing or unclear thing 2]

**3. Generate Insights (15 minutes)**

**Start Doing** (Things we should begin)
- [ ] [New practice 1]
- [ ] [New practice 2]

**Stop Doing** (Things we should eliminate)
- [ ] [Practice to eliminate 1]
- [ ] [Practice to eliminate 2]

**Continue Doing** (Things we should keep)
- [ ] [Good practice 1]
- [ ] [Good practice 2]

**4. Decide What to Do (15 minutes)**

**Top 3 Action Items for Next Sprint**
1. **Action**: [Specific, actionable item]
   - **Owner**: [Name]
   - **Success Criteria**: [How we'll know it worked]
   - **Review Date**: [When to check in]

2. **Action**: [Specific, actionable item]
   - **Owner**: [Name]
   - **Success Criteria**: [How we'll know it worked]
   - **Review Date**: [When to check in]

3. **Action**: [Specific, actionable item]
   - **Owner**: [Name]
   - **Success Criteria**: [How we'll know it worked]
   - **Review Date**: [When to check in]

**5. Close Retrospective (10 minutes)**
- Recap action items
- Assign owners and deadlines
- Team commitment to improvements
- Appreciation shout-outs

### Retrospective Themes to Explore

**Technical**
- Code quality and technical debt
- Testing coverage and quality
- Build and deployment process
- Performance and scalability
- Security considerations

**Process**
- Sprint planning effectiveness
- Story refinement quality
- Communication and collaboration
- Meeting efficiency
- Definition of Done adherence

**Team**
- Team morale and energy
- Work-life balance
- Skill development
- Knowledge sharing
- Team dynamics

**Product**
- Alignment with personas
- User feedback incorporation
- Feature value delivery
- Product vision clarity
- Stakeholder engagement

### Retrospective Prime Directive
> "Regardless of what we discover, we understand and truly believe that everyone did the best job they could, given what they knew at the time, their skills and abilities, the resources available, and the situation at hand."

---

## Sprint Health Check

### Sprint Health Indicators

**Green (Healthy Sprint)** ✅
- [ ] Sprint goal is clear and team understands it
- [ ] All committed stories meet Definition of Ready
- [ ] Team velocity is stable (within 10% of average)
- [ ] No critical blockers (> 1 day)
- [ ] Daily standups happening consistently
- [ ] Burndown chart tracking as expected
- [ ] Team morale is positive
- [ ] Stories being completed incrementally
- [ ] Code reviews happening within 24 hours
- [ ] All tests passing on CI/CD

**Yellow (At Risk)** ⚠️
- [ ] Sprint goal unclear or changing frequently
- [ ] Some stories don't meet Definition of Ready
- [ ] Velocity fluctuating (10-25% variance)
- [ ] 1-2 blockers lasting multiple days
- [ ] Standups occasionally skipped/rushed
- [ ] Burndown chart slightly behind
- [ ] Team expressing some concerns
- [ ] Stories piling up at end of sprint
- [ ] Code reviews delayed (2-3 days)
- [ ] Some test failures on CI/CD

**Red (Critical Issues)** 🚨
- [ ] Sprint goal not defined or abandoned
- [ ] Multiple stories missing acceptance criteria
- [ ] Velocity dropped >25% from average
- [ ] Multiple critical blockers (>3 days)
- [ ] Standups not happening regularly
- [ ] Burndown chart significantly behind
- [ ] Team morale low or conflicts present
- [ ] No stories completed mid-sprint
- [ ] Code reviews stalled (>5 days)
- [ ] Multiple test failures blocking progress

### Mid-Sprint Health Check (Day 7)

**Checkpoint Questions:**
1. Are we on track to meet the sprint goal?
   - [ ] Yes, on track
   - [ ] Mostly, with minor adjustments
   - [ ] At risk, need intervention
   - [ ] No, major issues

2. What percentage of stories are "In Progress"?
   - Ideal: 50-60% complete, 30-40% in progress, 10% not started

3. Are there any blockers older than 2 days?
   - [ ] No blockers
   - [ ] Blockers identified, resolution in progress
   - [ ] Blockers need escalation

4. Is the team feeling overwhelmed or underutilized?
   - [ ] Well-balanced workload
   - [ ] Slightly imbalanced but manageable
   - [ ] Need to redistribute work

### Actions Based on Health Check

**If Yellow (At Risk):**
1. Scrum Master facilitates focused problem-solving session
2. Consider descoping lower-priority stories
3. Address blockers with urgency
4. Increase communication frequency
5. Pair programming on complex items

**If Red (Critical):**
1. Emergency team meeting within 24 hours
2. Escalate to product owner and stakeholders
3. Reset sprint goal if necessary
4. Remove non-critical items from sprint
5. Focus on core deliverables only
6. Consider external help or resources

---

## Sprint Planning Checklist

### Pre-Sprint Planning (Day Before)
- [ ] Product owner reviews and prioritizes backlog
- [ ] Top 2 sprints worth of items are "Ready"
- [ ] Team capacity calculated (accounting for PTO, holidays)
- [ ] Previous sprint retrospective actions reviewed
- [ ] Previous sprint velocity calculated
- [ ] Sprint planning meeting scheduled and confirmed

### During Sprint Planning
- [ ] Sprint goal defined and agreed upon
- [ ] Stories selected based on priority and capacity
- [ ] All selected stories meet Definition of Ready
- [ ] Acceptance criteria clarified for each story
- [ ] Tasks broken down for each story
- [ ] Story points confirmed by team
- [ ] Dependencies identified and flagged
- [ ] Risks assessed and mitigation planned
- [ ] Team commits to sprint backlog

### Post-Sprint Planning
- [ ] Sprint backlog documented and visible
- [ ] Sprint goal posted in team workspace
- [ ] Stories moved to "Sprint Backlog" status
- [ ] Daily standup time confirmed
- [ ] Sprint tracking board prepared
- [ ] Stakeholders notified of sprint goal
- [ ] First day tasks assigned and ready

---

## Example Sprint (Sprint 3 - MVP Phase)

### Sprint Information
```
Sprint Number: Sprint 3
Sprint Duration: November 15 - November 28, 2025
Phase: MVP - Core Experience
Team Capacity: 45 story points
Team Members: 
  - Alice (Full Stack) - 10 pts
  - Bob (Full Stack) - 10 pts
  - Charlie (Full Stack) - 10 pts
  - Diana (Full Stack) - 10 pts
  - Eve (Tech Lead - 50% capacity) - 5 pts
```

### Sprint Goal
```
Sprint Goal: "Enable turn-based gameplay and democratic voting"

Success Criteria:
- Players can vote on games with point allocation in real-time
- Turn-based gameplay works asynchronously across all 12+ games
- Real-time updates via Socket.io are stable and functional
- All game states persist and resume correctly

Personas Served: 
  - Family Connector (democratic voting for multi-generational play)
  - Parent-Child Builder (async gameplay across schedules)
  - Competitive Sibling (fair turn-taking)
```

### Selected Backlog Items

#### Epic 3: Core Gameplay Experience

**Feature 3.2: Democratic Game Voting** - P0 - 13 points
- **Story**: As a player, I want to vote on which games to play so that everyone enjoys the session
- **Acceptance Criteria**:
  - [x] Players receive voting points (configurable by host)
  - [x] Can allocate points across multiple games
  - [x] Can change votes before voting ends
  - [x] Top voted games are selected
  - [x] Real-time vote count updates
- **Tasks**:
  - [x] Task 3.2.1: Voting service backend (COMPLETED ✅)
  - [ ] Task 3.2.2: Create voting UI with point allocation (5 pts) - Alice
  - [ ] Task 3.2.3: Add voting Socket.io events (3 pts) - Bob
  - [ ] Task 3.2.4: Implement multi-round voting logic (3 pts) - Charlie
- **Dependencies**: None
- **Risks**: Real-time updates may have latency issues - mitigation: extensive testing

**Feature 3.3: Turn-Based Gameplay** - P0 - 13 points
- **Story**: As a player, I want to take my turn when convenient so that I can play on my schedule
- **Acceptance Criteria**:
  - [x] Clear indication of whose turn it is
  - [x] Turn can be taken anytime (async)
  - [x] Turn data validated server-side
  - [x] Other players notified of turn completion
  - [x] Turn history visible
- **Tasks**:
  - [ ] Task 3.3.1: Implement turn management system (5 pts) - Diana
  - [ ] Task 3.3.2: Create turn UI components (3 pts) - Alice
  - [ ] Task 3.3.3: Add server-side turn validation (3 pts) - Bob
  - [ ] Task 3.3.4: Implement turn notifications (2 pts) - Charlie
- **Dependencies**: Requires Socket.io connection from Sprint 2
- **Risks**: Server-side validation complexity - mitigation: Eve (Tech Lead) to review

**Feature 3.5: Game State Management** - P1 - 8 points
- **Story**: As a player, I want my game state saved automatically so that I can resume anytime
- **Acceptance Criteria**:
  - [x] Game state saved after each action
  - [x] State persists across app restarts
  - [x] Synchronized across devices
  - [x] Handles offline state changes
  - [x] Conflict resolution (server wins)
- **Tasks**:
  - [ ] Task 3.5.1: Implement game state models (2 pts) - Diana
  - [ ] Task 3.5.2: Create state persistence in SQLite (3 pts) - Charlie
  - [ ] Task 3.5.3: Implement state synchronization (2 pts) - Bob
  - [ ] Task 3.5.4: Add state recovery (1 pt) - Alice
- **Dependencies**: None
- **Risks**: SQLite performance on older devices - mitigation: performance testing

**Tech Debt: Improve test coverage** - P2 - 5 points
- Add unit tests for multiplayer service
- Add integration tests for lobby management
- Owner: Eve (Tech Lead)

**Bug Fixes: Sprint 2 issues** - 6 points
- Fix: Lobby code sometimes not copying correctly (2 pts) - Charlie
- Fix: Profile avatar not saving on Android (2 pts) - Diana
- Fix: Socket connection drops on iOS background (2 pts) - Bob

### Sprint Backlog Summary
```
Total Story Points Committed: 45 points
Team Capacity: 45 points
Capacity Utilization: 100%

Breakdown by Priority:
- P0 (Critical): 26 points (58%)
- P1 (High): 8 points (18%)
- P2 (Medium): 5 points (11%)
- Bug Fixes: 6 points (13%)

Breakdown by Epic:
- Epic 3 (Core Gameplay): 34 points
- Tech Debt: 5 points
- Bug Fixes: 6 points
```

---

## Conclusion

These templates provide structure and consistency for sprint execution. Adapt them as needed based on team size, project phase, and organizational culture. The key is to maintain regular cadence, clear communication, and continuous improvement through retrospectives.

---

**Document Status**: Active  
**Next Review**: After Phase 1 Sprint 3  
**Owner**: Scrum Master  
**Contributors**: Product Owner, Tech Lead, Engineering Team

---

*Remember: Templates are starting points. The team should adapt and evolve these based on what works best for your specific context and needs.*
