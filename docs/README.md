# Mind Wars Documentation 📚

**Welcome to the Mind Wars documentation hub!**

This directory contains all project documentation organized by domain: business strategy, project management, social/community development, game design, and research archives.

---

## Documentation Structure

```
docs/
├── README.md (this file)
├── business/           # Business strategy, market analysis, monetization
├── project/            # Project management, sprints, technical specs
├── social/             # Community, marketing, social media strategy
├── games/              # Individual game design documents
└── research/           # Research archives and analysis
```

---

## Quick Navigation

### 🎯 Getting Started
- **New to the project?** Start with [Business Strategy Overview](business/STRATEGY_OVERVIEW.md)
- **Developer onboarding?** See [Project Documentation](project/DEVELOPER_ONBOARDING.md)
- **Marketing team?** Go to [Social Media Strategy](social/SOCIAL_MEDIA_STRATEGY.md)
- **Game designer?** Check [Game Design Process](games/DESIGN_PROCESS.md)

### 📊 Business Documentation
Located in: `docs/business/`

Essential business documents for strategy, planning, and market analysis:
- [Strategy Overview](business/STRATEGY_OVERVIEW.md) - Core business strategy and vision
- [Market Analysis](business/MARKET_ANALYSIS.md) - Competitive landscape and opportunities
- [Monetization Strategy](business/MONETIZATION_STRATEGY.md) - Revenue models and pricing
- [User Acquisition](business/USER_ACQUISITION.md) - Growth and marketing plans
- [Investor Relations](business/INVESTOR_RELATIONS.md) - Pitch decks and investor updates

### 🚀 Project Documentation
Located in: `docs/project/`

Project management, technical specifications, and development processes:
- [Developer Onboarding](project/DEVELOPER_ONBOARDING.md) - Getting started guide
- [Sprint Planning](project/SPRINT_PLANNING.md) - Sprint ceremonies and processes
- [Technical Architecture](project/TECHNICAL_ARCHITECTURE.md) - System design and infrastructure
- [API Documentation](project/API_DOCUMENTATION.md) - Backend API reference
- [Testing Strategy](project/TESTING_STRATEGY.md) - QA and testing approach
- [Deployment Guide](project/DEPLOYMENT_GUIDE.md) - CI/CD and release process

### 📱 Social & Community Documentation
Located in: `docs/social/`

Community management, marketing, and social media strategies:
- [Social Media Strategy](social/SOCIAL_MEDIA_STRATEGY.md) - Platform-specific strategies
- [Community Guidelines](social/COMMUNITY_GUIDELINES.md) - Rules and moderation
- [Content Calendar](social/CONTENT_CALENDAR.md) - Social media scheduling
- [Influencer Partnerships](social/INFLUENCER_PARTNERSHIPS.md) - Collaboration strategies
- [Brand Guidelines](social/BRAND_GUIDELINES.md) - Voice, tone, and visual identity
- [Crisis Management](social/CRISIS_MANAGEMENT.md) - Handling negative events

### 🎮 Game Design Documentation
Located in: `docs/games/`

Individual game design documents and processes:
- [Design Process](games/DESIGN_PROCESS.md) - Game design workflow
- [Game Design Template](games/GAME_DESIGN_TEMPLATE.md) - Standard GDD format
- Individual game documents (one per game)
  - [Quick Math Blitz](games/QUICK_MATH_BLITZ.md)
  - [Memory Matrix](games/MEMORY_MATRIX.md)
  - [Draw & Duel](games/DRAW_AND_DUEL.md)
  - ... (more games as developed)

### 🔬 Research Archive
Located in: `docs/research/`

Research documents, studies, and analysis:
- [Competitive Async Games Research](research/COMPETITIVE_ASYNC_MPG.md)
- [Brain Training Games Research](research/BRAIN_TRAINING_GAMES.md)
- [Cognitive Science Literature](research/COGNITIVE_SCIENCE.md)
- [User Research Studies](research/USER_RESEARCH.md)
- [A/B Test Results](research/AB_TEST_RESULTS.md)

---

## Documentation Standards

### Writing Guidelines

**Tone**: Professional, clear, and actionable
- Use active voice
- Write concisely
- Include examples
- Add visual aids when helpful

**Format**: Markdown with consistent structure
- Use headers (H1, H2, H3)
- Add table of contents for long documents
- Include metadata (author, date, version)
- Link to related documents

**Naming Convention**: `DESCRIPTIVE_NAME.md`
- All caps with underscores
- Descriptive and specific
- Keep under 30 characters when possible

### Document Template

```markdown
# Document Title

**Purpose**: Brief description of document purpose  
**Author**: Name(s)  
**Last Updated**: YYYY-MM-DD  
**Status**: Draft | Active | Archived  

---

## Table of Contents
1. [Section 1](#section-1)
2. [Section 2](#section-2)

---

## Section 1
Content here...

---

## References
- Link to related documents
- External resources
```

### Version Control

- **Major updates**: Change version number (v1.0 → v2.0)
- **Minor updates**: Increment minor version (v1.0 → v1.1)
- **Always update "Last Updated" date**
- **Add changelog section for significant documents**

---

## Contributing to Documentation

### Adding New Documents

1. **Choose the correct directory** based on content type
2. **Use the template** for consistency
3. **Name clearly** following naming convention
4. **Update this README** with link to new document
5. **Cross-reference** related documents

### Updating Existing Documents

1. **Check "Last Updated" date** to ensure you have latest version
2. **Make changes** following writing guidelines
3. **Update metadata** (version, date, author if adding significant content)
4. **Add changelog entry** for major changes
5. **Update cross-references** if structure changed

### Document Review Process

1. **Self-review** for clarity and completeness
2. **Peer review** for technical accuracy
3. **Leadership approval** for strategic documents
4. **Publish** and notify stakeholders

---

## Document Ownership

| Directory | Primary Owner | Review Frequency |
|-----------|---------------|------------------|
| `/business` | Product Manager | Monthly |
| `/project` | Engineering Lead | Weekly |
| `/social` | Community Manager | Weekly |
| `/games` | Game Designer | Per game release |
| `/research` | Research Lead | Quarterly |

---

## Frequently Asked Questions

### Where do I find...?

**Q: Business strategy and vision?**  
A: `docs/business/STRATEGY_OVERVIEW.md`

**Q: Technical architecture details?**  
A: `docs/project/TECHNICAL_ARCHITECTURE.md`

**Q: Game design specifications?**  
A: `docs/games/[GAME_NAME].md`

**Q: Social media guidelines?**  
A: `docs/social/SOCIAL_MEDIA_STRATEGY.md` and `docs/social/BRAND_GUIDELINES.md`

**Q: Research on cognitive benefits?**  
A: `docs/research/COGNITIVE_SCIENCE.md`

### How do I...?

**Q: Request a new document?**  
A: Create an issue or contact the directory owner

**Q: Suggest changes to existing document?**  
A: Submit a pull request or discuss with document owner

**Q: Archive outdated documents?**  
A: Move to `/archived` subdirectory within relevant folder and update status to "Archived"

---

## External Links

### Main Project Documents (Root Level)
These remain in the root directory for easy access:
- [README.md](../README.md) - Project overview
- [GAMES_EVALUATION_AND_ROADMAP.md](../GAMES_EVALUATION_AND_ROADMAP.md) - Game prioritization
- [PRODUCT_BACKLOG.md](../PRODUCT_BACKLOG.md) - Prioritized feature backlog
- [ROADMAP.md](../ROADMAP.md) - Development timeline
- [USER_PERSONAS.md](../USER_PERSONAS.md) - Target user personas
- [USER_STORIES.md](../USER_STORIES.md) - User stories and acceptance criteria
- [ARCHITECTURE.md](../ARCHITECTURE.md) - High-level architecture
- [BACKLOG_GUIDE.md](../BACKLOG_GUIDE.md) - Guide to backlog documentation

### Related Repositories
- [Mind Wars Backend](https://github.com/tescolopio/mind-wars-backend) - Server API
- [Mind Wars Design](https://github.com/tescolopio/mind-wars-design) - Design assets

---

## Document Update Log

| Date | Document | Change | Author |
|------|----------|--------|--------|
| 2025-11-09 | README.md | Initial documentation structure | Product Team |

---

**Questions or suggestions?**  
Contact: Product Manager or create an issue on GitHub

---

*Last Updated: 2025-11-09*  
*Document Version: 1.0*
