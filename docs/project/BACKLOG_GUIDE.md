# Mind Wars - Backlog Quick Reference Guide 🎯

## Document Purpose
This is your quick reference guide to navigate the Mind Wars backlog system. Use this to quickly find what you need and understand how all the backlog documents work together.

**Last Updated**: November 2025  
**Version**: 1.0

---

## Documentation Map

### 📚 Product & User Research
1. **[USER_PERSONAS.md](../business/USER_PERSONAS.md)** (30KB) - 8 detailed user personas
   - **Use When**: Understanding who we're building for
   - **Key Content**: Family Connector, Competitive Sibling, Grandparent Gamer, etc.
   - **Audience**: Everyone on the team

2. **[USER_STORIES.md](../business/USER_STORIES.md)** (41KB) - Complete user stories library
   - **Use When**: Detailed requirements and acceptance criteria needed
   - **Key Content**: All Epics, Features, Tasks with full details
   - **Audience**: Product Owners, Engineers, QA

### 📋 Backlog Management
3. **[PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md)** (42KB) - **⭐ START HERE**
   - **Use When**: Planning sprints, prioritizing work
   - **Key Content**: Prioritized backlog (P0-P3), story points, sprint planning
   - **Audience**: Scrum Master, Product Owner, Tech Lead

4. **[SPRINT_TEMPLATES.md](SPRINT_TEMPLATES.md)** (19KB) - Sprint ceremony templates
   - **Use When**: Running sprints, standups, retrospectives
   - **Key Content**: All ceremony templates, checklists, examples
   - **Audience**: Scrum Master, entire team

5. **[ROADMAP.md](../../ROADMAP.md)** (23KB) - Visual timeline and milestones
   - **Use When**: Planning phases, tracking progress, stakeholder updates
   - **Key Content**: 6-month roadmap, milestones, success metrics
   - **Audience**: Product Manager, Leadership, Stakeholders

### 🏗️ Technical Documentation
6. **[ARCHITECTURE.md](../../ARCHITECTURE.md)** (9KB) - Technical architecture
   - **Use When**: Understanding technical implementation
   - **Key Content**: Tech stack, offline-first design, security
   - **Audience**: Engineers, Tech Lead

7. **[VALIDATION.md](VALIDATION.md)** (9KB) - Implementation validation
   - **Use When**: Checking if features are correctly implemented
   - **Key Content**: Validation checklists for all features
   - **Audience**: QA, Engineers

8. **[VOTING_SYSTEM.md](../../VOTING_SYSTEM.md)** (11KB) - Game voting system details
   - **Use When**: Implementing democratic game selection
   - **Key Content**: Voting mechanics, Socket.io events
   - **Audience**: Engineers working on voting feature

### 📖 General
9. **[README.md](../../README.md)** (9KB) - Project overview
   - **Use When**: Onboarding new team members
   - **Key Content**: Features, tech stack, setup instructions
   - **Audience**: Everyone, especially new team members

---

## Quick Navigation by Role

### Product Manager / Product Owner
**Daily Use:**
- [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) - Prioritizing and grooming backlog
- [USER_PERSONAS.md](USER_PERSONAS.md) - Validating persona alignment
- [ROADMAP.md](../../ROADMAP.md) - Tracking progress and milestones

**Weekly Use:**
- [SPRINT_TEMPLATES.md](SPRINT_TEMPLATES.md) - Sprint planning and reviews
- [USER_STORIES.md](../business/USER_STORIES.md) - Refining user stories

**Monthly Use:**
- [ROADMAP.md](../../ROADMAP.md) - Stakeholder updates and phase reviews

### Scrum Master
**Daily Use:**
- [SPRINT_TEMPLATES.md](SPRINT_TEMPLATES.md) - Standup facilitation
- [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) - Sprint progress tracking

**Weekly Use:**
- [SPRINT_TEMPLATES.md](SPRINT_TEMPLATES.md) - All sprint ceremonies
- [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) - Backlog grooming

**Sprint Boundaries:**
- [SPRINT_TEMPLATES.md](SPRINT_TEMPLATES.md) - Planning, review, retrospective

### Engineering Team
**Daily Use:**
- [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) - Task details and story points
- [USER_STORIES.md](../business/USER_STORIES.md) - Acceptance criteria and implementation details

**When Starting New Work:**
- [ARCHITECTURE.md](../../ARCHITECTURE.md) - Technical approach
- [USER_PERSONAS.md](USER_PERSONAS.md) - Understanding user needs

**Before Completing Work:**
- [VALIDATION.md](VALIDATION.md) - Feature validation checklist

### Tech Lead
**Daily Use:**
- [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) - Technical planning and dependencies
- [ARCHITECTURE.md](../../ARCHITECTURE.md) - Architecture decisions

**Weekly Use:**
- [SPRINT_TEMPLATES.md](SPRINT_TEMPLATES.md) - Sprint planning and reviews
- [USER_STORIES.md](../business/USER_STORIES.md) - Story refinement and estimation

**Monthly Use:**
- [ROADMAP.md](../../ROADMAP.md) - Technical roadmap and risk management

### QA / Test Engineer
**Daily Use:**
- [USER_STORIES.md](../business/USER_STORIES.md) - Acceptance criteria for testing
- [VALIDATION.md](VALIDATION.md) - Feature validation checklists

**When Testing Features:**
- [USER_PERSONAS.md](USER_PERSONAS.md) - Persona-based testing scenarios
- [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) - Story acceptance criteria

### UX/UI Designer
**Daily Use:**
- [USER_PERSONAS.md](USER_PERSONAS.md) - Designing for personas
- [USER_STORIES.md](../business/USER_STORIES.md) - User flows and requirements

**Weekly Use:**
- [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) - Upcoming design needs
- [ROADMAP.md](../../ROADMAP.md) - Design roadmap planning

### Leadership / Stakeholders
**Weekly Use:**
- [ROADMAP.md](../../ROADMAP.md) - Progress and milestones

**Monthly Use:**
- [ROADMAP.md](../../ROADMAP.md) - Phase reviews and success metrics
- [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) - Feature priorities

**Quarterly Use:**
- [USER_PERSONAS.md](USER_PERSONAS.md) - Persona validation
- [ROADMAP.md](../../ROADMAP.md) - Strategic alignment

---

## Common Workflows

### 1. Planning a New Sprint

**Steps:**
1. Open [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) - Review prioritized items
2. Open [SPRINT_TEMPLATES.md](SPRINT_TEMPLATES.md) - Use Sprint Planning Template
3. Select items from backlog that are "Ready" (Definition of Ready)
4. Calculate team velocity (40-50 points target)
5. Define sprint goal aligned with roadmap phase
6. Break down selected stories into tasks
7. Document in sprint planning template

**Key Documents:**
- Primary: PRODUCT_BACKLOG.md, SPRINT_TEMPLATES.md
- Reference: USER_STORIES.md, ROADMAP.md

### 2. Refining a User Story

**Steps:**
1. Open [USER_STORIES.md](../business/USER_STORIES.md) - Find the story
2. Open [USER_PERSONAS.md](USER_PERSONAS.md) - Identify target persona(s)
3. Review acceptance criteria
4. Add technical details from [ARCHITECTURE.md](../../ARCHITECTURE.md)
5. Estimate story points (use calibration guide in PRODUCT_BACKLOG.md)
6. Mark as "Ready" in [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md)

**Key Documents:**
- Primary: USER_STORIES.md, PRODUCT_BACKLOG.md
- Reference: USER_PERSONAS.md, ARCHITECTURE.md

### 3. Running Daily Standup

**Steps:**
1. Open [SPRINT_TEMPLATES.md](SPRINT_TEMPLATES.md) - Standup Template section
2. Each team member answers three questions:
   - What did I complete yesterday?
   - What will I work on today?
   - Any blockers?
3. Update sprint board with progress
4. Track blockers in template
5. Schedule parking lot discussions

**Key Documents:**
- Primary: SPRINT_TEMPLATES.md
- Reference: PRODUCT_BACKLOG.md (for sprint backlog)

### 4. Conducting Sprint Review

**Steps:**
1. Open [SPRINT_TEMPLATES.md](SPRINT_TEMPLATES.md) - Sprint Review Template
2. Prepare demos for completed features
3. Review sprint goal achievement
4. Collect stakeholder feedback
5. Update metrics (velocity, completion rate)
6. Capture action items

**Key Documents:**
- Primary: SPRINT_TEMPLATES.md
- Reference: PRODUCT_BACKLOG.md, ROADMAP.md

### 5. Running Sprint Retrospective

**Steps:**
1. Open [SPRINT_TEMPLATES.md](SPRINT_TEMPLATES.md) - Retrospective Template
2. Gather data (what went well, what to improve)
3. Generate insights (Start-Stop-Continue)
4. Define top 3 action items with owners
5. Document and commit to improvements

**Key Documents:**
- Primary: SPRINT_TEMPLATES.md

### 6. Validating Completed Feature

**Steps:**
1. Open [VALIDATION.md](VALIDATION.md) - Find feature checklist
2. Open [USER_STORIES.md](../business/USER_STORIES.md) - Review acceptance criteria
3. Test against all acceptance criteria
4. Verify persona needs are met (use USER_PERSONAS.md)
5. Check Definition of Done (in PRODUCT_BACKLOG.md)
6. Mark as complete if all criteria met

**Key Documents:**
- Primary: VALIDATION.md, USER_STORIES.md
- Reference: USER_PERSONAS.md, PRODUCT_BACKLOG.md

### 7. Updating the Roadmap

**Steps:**
1. Open [ROADMAP.md](../../ROADMAP.md) - Current phase section
2. Review milestone progress
3. Update completed features (✅)
4. Update in-progress features (🔄)
5. Adjust timeline if needed
6. Update success metrics with actual data
7. Document any roadmap changes

**Key Documents:**
- Primary: ROADMAP.md
- Reference: PRODUCT_BACKLOG.md (for velocity data)

---

## Key Concepts Reference

### Priority Levels (P0-P3)
- **P0 - Critical**: Launch blockers, must have
- **P1 - High**: Important for launch, should have
- **P2 - Medium**: Nice to have, can defer
- **P3 - Low**: Future enhancement, backlog

### Story Points (Fibonacci Scale)
- **1 pt**: Trivial (< 2 hours)
- **2 pts**: Simple (2-4 hours)
- **3 pts**: Small (1 day)
- **5 pts**: Medium (2-3 days)
- **8 pts**: Large (1 week)
- **13 pts**: Complex (2 weeks)
- **21 pts**: Epic-level (break down)

### Sprint Structure
- **Duration**: 2 weeks
- **Velocity**: 40-50 story points
- **Ceremonies**:
  - Planning: Monday, 2 hours
  - Daily Standup: Every day, 15 min
  - Review: Friday (Week 2), 1 hour
  - Retrospective: Friday (Week 2), 1 hour

### Development Phases
- **Phase 1** (Months 1-2): MVP - Core Experience (170 pts)
- **Phase 2** (Months 3-4): Social & Progression (96 pts)
- **Phase 3** (Months 5-6): Offline & Polish (89 pts)
- **Phase 4** (Month 7+): Advanced Features (TBD)

### 8 User Personas
1. **Competitive Sibling** (Alex, 24) - Family rivalry
2. **Family Connector** (Maria, 42) - Extended family bonding
3. **Grandparent Gamer** (Dr. James, 68) - Intergenerational connection
4. **Parent-Child Builder** (Sarah, 38) - Quality time across schedules
5. **Teen Squad Leader** (Emma, 16) - Friend groups & family
6. **Middle Schooler** (Jordan, 12) - Cousin groups & skill building
7. **Friend Circle Competitor** (Marcus, 28) - Friends staying connected
8. **Office Team Builder** (Jennifer, 35) - Team-building

---

## FAQ

### Q: Where do I start if I'm new to the project?
**A:** Start with [README.md](../../README.md) for overview, then [USER_PERSONAS.md](USER_PERSONAS.md) to understand our users, then [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) to see the prioritized work.

### Q: How do I know what to work on next?
**A:** Check [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) - items are prioritized P0 (highest) to P3 (lowest). Work on P0 items first.

### Q: Where can I find detailed acceptance criteria?
**A:** [USER_STORIES.md](../business/USER_STORIES.md) has complete acceptance criteria for every feature.

### Q: How do I estimate story points?
**A:** Use the calibration guide in [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) - compare to reference stories.

### Q: What ceremonies do we run in sprints?
**A:** All sprint ceremonies are documented in [SPRINT_TEMPLATES.md](SPRINT_TEMPLATES.md) with templates and examples.

### Q: How do I know if we're on track?
**A:** Check [ROADMAP.md](../../ROADMAP.md) for phase milestones and success metrics timeline.

### Q: Where do I find technical implementation details?
**A:** [ARCHITECTURE.md](../../ARCHITECTURE.md) for architecture, [USER_STORIES.md](../business/USER_STORIES.md) for feature-specific tasks.

### Q: How do I validate a completed feature?
**A:** Use [VALIDATION.md](VALIDATION.md) checklists and verify against acceptance criteria in [USER_STORIES.md](../business/USER_STORIES.md).

### Q: What if a persona's needs change?
**A:** Update [USER_PERSONAS.md](USER_PERSONAS.md), then review [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) to adjust priorities.

### Q: How often should we groom the backlog?
**A:** Weekly, per guidelines in [PRODUCT_BACKLOG.md](../../PRODUCT_BACKLOG.md) - Backlog Grooming section.

---

## Cheat Sheet

### Sprint Planning Checklist
```
Before Sprint:
☐ Review PRODUCT_BACKLOG.md for "Ready" items
☐ Calculate team capacity
☐ Prepare SPRINT_TEMPLATES.md planning template

During Sprint Planning:
☐ Define sprint goal (aligned with ROADMAP.md)
☐ Select stories from PRODUCT_BACKLOG.md
☐ Review USER_STORIES.md for acceptance criteria
☐ Break down into tasks
☐ Estimate story points
☐ Commit to sprint backlog

After Sprint Planning:
☐ Document in SPRINT_TEMPLATES.md
☐ Update sprint board
☐ Notify stakeholders of sprint goal
```

### Definition of Ready (Before Sprint)
```
☐ User story format complete
☐ Acceptance criteria defined
☐ Linked to persona(s) in USER_PERSONAS.md
☐ Story points estimated
☐ Dependencies identified
☐ Technical approach validated
☐ Design assets available (if UI)
☐ Team understands requirements
```

### Definition of Done (Feature Complete)
```
☐ All tasks completed and merged
☐ Unit tests written (>80% coverage)
☐ Integration tests passing
☐ Tested on iOS and Android
☐ Code reviewed and approved
☐ Performance meets targets
☐ Security review passed (if applicable)
☐ Documentation updated
☐ Product owner approval
☐ Deployed to staging
```

---

## Document Maintenance

### Who Maintains Each Document?

| Document | Primary Owner | Update Frequency |
|----------|---------------|------------------|
| PRODUCT_BACKLOG.md | Product Owner | Weekly (grooming) |
| SPRINT_TEMPLATES.md | Scrum Master | Per sprint |
| ROADMAP.md | Product Manager | Monthly |
| USER_PERSONAS.md | Product Team | Quarterly |
| USER_STORIES.md | Product Owner | Weekly (as stories refined) |
| ARCHITECTURE.md | Tech Lead | As architecture evolves |
| VALIDATION.md | QA Lead | Per phase |
| VOTING_SYSTEM.md | Tech Lead | As feature evolves |
| README.md | Tech Lead | Major changes only |

### Review Schedule
- **Weekly**: PRODUCT_BACKLOG.md, USER_STORIES.md (during grooming)
- **Per Sprint**: SPRINT_TEMPLATES.md (all ceremonies)
- **Monthly**: ROADMAP.md (phase reviews)
- **Quarterly**: USER_PERSONAS.md (persona validation)
- **Ad-hoc**: ARCHITECTURE.md, VALIDATION.md (as needed)

---

## Contact & Support

### Questions About Backlog?
- **Product Priorities**: Contact Product Owner
- **Sprint Processes**: Contact Scrum Master
- **Technical Questions**: Contact Tech Lead
- **Persona Research**: Contact Product Team

### Suggesting Improvements
1. Create issue in repository
2. Label: "documentation"
3. Describe improvement
4. Tag relevant document owner

---

## Version History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| Nov 2025 | 1.0 | Initial backlog system created | Product Team |

---

**Quick Links:**
- [Product Backlog](../../PRODUCT_BACKLOG.md) ⭐
- [Sprint Templates](SPRINT_TEMPLATES.md)
- [Roadmap](../../ROADMAP.md)
- [User Personas](USER_PERSONAS.md)
- [User Stories](../business/USER_STORIES.md)

---

*This guide is your compass for navigating the Mind Wars backlog system. Bookmark it, reference it often, and update it as the system evolves.*
