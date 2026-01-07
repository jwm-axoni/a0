# Meta-Learning System Documentation

## Table of Contents

1. [Quick Navigation](#quick-navigation)
2. [Overview](#overview)
3. [What is Meta-Learning?](#what-is-meta-learning)
4. [How It Works](#how-it-works)
5. [Architecture](#architecture)
6. [Configuration](#configuration)
7. [Usage Guide](#usage-guide)
8. [Safety Features](#safety-features)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)
11. [Testing](#testing)
12. [Further Reading](#further-reading)
13. [Version History](#version-history)

---

## Quick Navigation

### Getting Started
- **[QUICKSTART.md](QUICKSTART.md)** - 2-minute quick start guide
- **[README_TESTS.md](README_TESTS.md)** - How to run the test suite

### Understanding the System
- **[meta_learning.md](meta_learning.md)** - Complete system guide (main reference)
- **[TEST_SUMMARY.md](TEST_SUMMARY.md)** - Test coverage overview
- **[TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md)** - Visual diagrams and architecture

### Reference
- **[INDEX.md](INDEX.md)** - Comprehensive file index
- **[DELIVERABLES.md](DELIVERABLES.md)** - Project deliverables summary

---

## Overview

Agent Zero's meta-learning system is a **self-evolving framework** that acts as a **reflective meta-layer** analyzing the agent's performance over time and automatically generating suggestions to improve its own behavior. This creates a feedback loop where the agent learns from experience and continuously refines its capabilities.

### Key Capabilities

- **Pattern Detection** - Identifies repeated failures and successes in conversations
- **Prompt Evolution** - Suggests refinements to system prompts based on observed behavior
- **Tool Discovery** - Recommends new tools to build based on unmet needs
- **Gap Analysis** - Detects missing instructions and guidance
- **Automatic Application** - Optionally applies high-confidence improvements automatically
- **Version Control** - Maintains full history with rollback capabilities

### Use Cases

- **Personal Assistant** - Adapts to your communication style and preferences over time
- **Domain Specialization** - Learns domain-specific patterns and terminology
- **Performance Optimization** - Identifies and fixes recurring mistakes automatically
- **Tool Development** - Discovers gaps where new tools would be beneficial
- **Behavior Refinement** - Fine-tunes responses based on success patterns

---

## What is Meta-Learning?

### The Concept

Traditional AI systems have fixed prompts written by developers. Agent Zero's meta-learning system adds a **reflective layer** that:

1. **Observes** the agent's interactions with users
2. **Analyzes** patterns of success and failure
3. **Generates** specific improvement suggestions
4. **Applies** changes (with safety controls)
5. **Tracks** all modifications with version control

### Why It Matters

- **No Manual Tuning** - The system evolves based on real usage, not guesswork
- **Personalization** - Adapts to your specific needs and workflows
- **Continuous Improvement** - Gets better with every interaction
- **Self-Documenting** - Analysis results become part of agent's memory
- **Recoverable** - Full version history with one-click rollback

### Real-World Example

```
User asks: "Find all TODO comments in my codebase"

Agent's first attempt:
- Uses grep to search files one by one
- Misses TODOs in binary file exclusions
- Takes too long for large codebases

Meta-Learning System observes:
- Pattern: "Inefficient file search with grep"
- Frequency: 3 times in 50 interactions
- Impact: High (user frustration, slow results)

Generated Suggestion:
- File: "agent.system.tool.code_exe.md"
- Refinement: Add guidance about using `git grep` for code search
- Confidence: 0.85
- Reason: "User repeatedly needed codebase-wide search"

Next time:
- Agent uses `git grep` automatically
- Fast, accurate results
- User satisfaction
```

---

## How It Works

### The Meta-Learning Loop

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interactions                        │
│  (Questions, Tasks, Tool Usage, Successes, Failures)        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Message History Accumulation                   │
│  (All conversations stored in agent.history)                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│               Meta-Analysis Trigger                         │
│  (Manual: prompt_evolution tool)                            │
│  (Auto: Every N monologues via extension)                   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│          Utility LLM Meta-Analysis                          │
│  • Extract recent history (up to MAX_HISTORY messages)      │
│  • Analyze with specialized meta-learning prompt            │
│  • Identify patterns (failures, successes, gaps)            │
│  • Generate structured suggestions (JSON)                   │
│  • Filter by CONFIDENCE_THRESHOLD                           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│            Analysis Result Processing                       │
│  • Store in memory (SOLUTIONS area)                         │
│  • Log findings to agent context                            │
│  • Generate human-readable summary                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
         ┌───────────┴───────────┐
         ▼                       ▼
┌──────────────────┐   ┌──────────────────────┐
│  Manual Review   │   │  Auto-Apply Mode     │
│  (Safe Default)  │   │  (Advanced Users)    │
├──────────────────┤   ├──────────────────────┤
│ • Suggestions    │   │ • Create backup      │
│   stored in      │   │ • Apply high-        │
│   memory         │   │   confidence changes │
│ • User reviews   │   │ • Log applications   │
│ • Manually apply │   │ • Version tracking   │
│   via API/UI     │   │                      │
└──────────────────┘   └──────────────────────┘
         │                       │
         └───────────┬───────────┘
                     ▼
┌─────────────────────────────────────────────────────────────┐
│               Prompt Versioning System                      │
│  • Snapshots created before each change                     │
│  • Metadata tracking (timestamp, reason, confidence)        │
│  • Rollback capability (one command)                        │
│  • Auto-cleanup of old versions                             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Improved Agent Behavior                        │
│  (Next interactions benefit from refined prompts)           │
└─────────────────────────────────────────────────────────────┘
```

### Key Features

✨ **Pattern Detection** - Identifies repeated failures and successes  
🎯 **Smart Suggestions** - Generates specific, actionable improvements  
🔄 **Version Control** - Automatic backups before every change  
↩️ **Safe Rollback** - Revert to any previous version instantly  
🤖 **Auto-Apply (Optional)** - Automatic application with manual review by default  

---

## Architecture

### File Structure

```
/agentzero/
├── docs/meta_learning/
│   ├── README.md                    # This file
│   ├── QUICKSTART.md               # Quick start (2 minutes)
│   ├── meta_learning.md            # Complete guide
│   ├── README_TESTS.md             # Test documentation
│   ├── TEST_SUMMARY.md             # Test coverage
│   ├── TEST_ARCHITECTURE.md        # Architecture diagrams
│   ├── INDEX.md                    # Comprehensive index
│   └── DELIVERABLES.md            # Project summary
│
├── python/
│   ├── tools/
│   │   └── prompt_evolution.py     # Meta-analysis tool
│   ├── helpers/
│   │   └── prompt_versioning.py    # Version control system
│   ├── api/
│   │   └── meta_learning.py        # API endpoints
│   └── extensions/
│       └── monologue_end/
│           └── _85_prompt_evolution.py  # Auto-trigger
│
├── prompts/
│   ├── meta_learning.analyze.sys.md # Meta-analysis prompt
│   ├── versioned/                  # Prompt version backups
│   │   ├── 20260105_143022/        # Timestamp-based snapshots
│   │   │   ├── metadata.json
│   │   │   └── *.md (all prompts)
│   │   └── pre_rollback_*/
│   └── *.md                        # Current active prompts
│
├── memory/
│   └── [agent]/
│       └── solutions/              # Meta-analysis results stored here
│
└── .env                            # Configuration
```

### Data Flow

#### Input: Conversation History

```python
[
  {"role": "user", "content": "Find all Python files"},
  {"role": "assistant", "content": "Tool: code_execution_tool..."},
  {"role": "tool", "content": "find . -name '*.py'"},
  # ... more messages ...
]
```

#### Processing: Meta-Analysis

The utility LLM receives:
- Recent history (up to `PROMPT_EVOLUTION_MAX_HISTORY` messages)
- Specialized meta-analysis prompt
- Instructions to output structured JSON

#### Output: Analysis Result

```json
{
  "failure_patterns": [
    {
      "pattern": "Inefficient file search using find instead of git grep",
      "frequency": 3,
      "severity": "medium",
      "affected_prompts": ["agent.system.tool.code_exe.md"],
      "example_messages": [42, 58, 71]
    }
  ],
  "success_patterns": [
    {
      "pattern": "Effective use of memory_query for retrieving past solutions",
      "frequency": 8,
      "confidence": 0.9,
      "related_prompts": ["agent.system.memories.md"]
    }
  ],
  "missing_instructions": [
    {
      "gap": "No guidance on handling rate limits gracefully",
      "impact": "high",
      "suggested_location": "agent.system.main.solving.md",
      "proposed_addition": "When encountering rate limits..."
    }
  ],
  "tool_suggestions": [
    {
      "tool_name": "git_search_tool",
      "purpose": "Fast codebase-wide search using git grep",
      "use_case": "When user needs to search code across entire repository",
      "priority": "high",
      "required_integrations": ["git"]
    }
  ],
  "prompt_refinements": [
    {
      "file": "agent.system.tool.code_exe.md",
      "section": "File Search Strategies",
      "current": "Use find command for file search",
      "proposed": "Use git grep for codebase search when in git repo, otherwise use find",
      "reason": "User repeatedly needed faster, more accurate code search",
      "confidence": 0.85
    }
  ],
  "meta": {
    "timestamp": "2026-01-05T14:30:22",
    "monologue_count": 42,
    "history_size": 100,
    "confidence_threshold": 0.7
  }
}
```

#### Storage: Memory Database

Analysis formatted as markdown and stored with embeddings:

```markdown
# Meta-Learning Analysis
**Date:** 2026-01-05T14:30:22
**Monologue:** #42
**History Analyzed:** 100 messages

## Failure Patterns Detected
- **Inefficient file search using find instead of git grep**
  - Frequency: 3
  - Severity: medium
  - Affected: agent.system.tool.code_exe.md

## Success Patterns Identified
- **Effective use of memory_query for retrieving past solutions**
  - Frequency: 8
  - Confidence: 0.90

...
```

### Key Components

#### 1. Prompt Evolution Tool (`python/tools/prompt_evolution.py`)

The core meta-analysis engine that:
- Analyzes conversation history
- Detects patterns
- Generates suggestions
- Stores results in memory
- Checks if meta-learning is enabled
- Validates minimum interaction threshold
- Orchestrates the analysis process
- Handles storage and application of results

#### 2. Prompt Versioning (`python/helpers/prompt_versioning.py`)

Version control system for prompts:
- Automatic snapshots before changes
- Rollback to any previous version
- Change tracking with metadata
- Diff between versions
- Creates snapshots before changes
- Stores metadata (timestamp, reason, confidence)
- Provides rollback functionality
- Auto-cleanup of old versions
- Export/import capabilities

#### 3. Meta-Learning API (`python/api/meta_learning.py`)

REST endpoints for:
- Triggering analysis
- Listing suggestions
- Applying changes
- Managing versions
- Dashboard queries

#### 4. Auto-Trigger Extension (`python/extensions/monologue_end/_85_prompt_evolution.py`)

Automatically triggers analysis:
- Every N monologues (configurable)
- Can be disabled per configuration
- Non-blocking async operation

#### 5. Meta-Analysis System Prompt (`prompts/meta_learning.analyze.sys.md`)

Specialized instructions for the utility LLM:
- Defines analysis methodology
- Specifies output format (JSON schema)
- Sets pattern detection rules
- Establishes confidence scoring

#### 6. Memory Integration

Analysis results are stored in the SOLUTIONS memory area:
- Semantic search retrieval
- Cross-session persistence
- Queryable via `memory_query` tool
- Feeds back into future decisions

---

## Configuration

### Environment Variables

All meta-learning settings are configured in `.env` (use `example.env` as template):

#### Core Settings

```bash
# Enable/disable meta-learning
ENABLE_PROMPT_EVOLUTION=true
```

**Values:**
- `true`: Meta-learning enabled (tool available)
- `false`: Meta-learning disabled (default for safety)

**When to enable:**
- After 50+ interactions with the agent
- When you trust the agent's judgment
- When actively monitoring changes (if auto-apply enabled)

---

#### Interaction Threshold

```bash
# Minimum interactions before analysis
PROMPT_EVOLUTION_MIN_INTERACTIONS=20
```

**Values:**
- `10-20`: Frequent analysis, less data (development)
- `20-50`: Balanced (recommended for most users)
- `50-100`: Robust analysis, less frequent (production)

**Trade-offs:**
- Lower values = More frequent feedback, less reliable patterns
- Higher values = More reliable patterns, slower adaptation

---

#### History Limit

```bash
# Maximum messages to analyze
PROMPT_EVOLUTION_MAX_HISTORY=100
```

**Values:**
- `50-100`: Light analysis (fast, lower token cost)
- `100-200`: Standard (recommended)
- `200-500`: Deep analysis (expensive, thorough)

**Considerations:**
- Longer history = Better pattern detection
- Longer history = Higher token costs
- Longer history = Slower analysis

---

#### Confidence Threshold

```bash
# Minimum confidence for suggestions (0.0-1.0)
PROMPT_EVOLUTION_CONFIDENCE_THRESHOLD=0.7
```

**Values:**
- `0.5-0.6`: Aggressive (many suggestions, some noise)
- `0.7-0.8`: Balanced (recommended)
- `0.8-0.9`: Conservative (only high-confidence changes)

**Use cases:**
- Start with 0.8 for safety
- Lower to 0.7 after validating quality
- Raise to 0.9 if getting too many false positives

---

#### Auto-Apply Mode

```bash
# Automatically apply high-confidence changes
AUTO_APPLY_PROMPT_EVOLUTION=false
```

**Values:**
- `false`: Safe mode (manual review required) **[RECOMMENDED]**
- `true`: Autonomous mode (automatic application)

**IMPORTANT:**
- Start with `false` until you trust the system
- Monitor several manual analyses first
- Enable auto-apply only after validating quality
- Always check prompt versions after auto-apply

---

#### Trigger Interval

```bash
# Monologues between auto-triggers (if extension enabled)
PROMPT_EVOLUTION_TRIGGER_INTERVAL=10
```

**Values:**
- `5-10`: Frequent meta-analysis
- `10-20`: Standard (recommended)
- `20-50`: Infrequent analysis

**Note:** Only applies if auto-trigger extension is installed.

---

#### Version Management

```bash
# Maximum prompt versions to keep
PROMPT_EVOLUTION_MAX_VERSIONS=50
```

**Values:**
- `20-50`: Standard (recommended)
- `50-100`: Extended history
- `0`: Disable auto-cleanup

**Storage:** Each version is ~100KB-500KB depending on prompt count.

---

### Configuration Profiles

#### Profile 1: Safe Default (Recommended for New Users)

```bash
ENABLE_PROMPT_EVOLUTION=false
PROMPT_EVOLUTION_MIN_INTERACTIONS=50
PROMPT_EVOLUTION_MAX_HISTORY=100
PROMPT_EVOLUTION_CONFIDENCE_THRESHOLD=0.8
AUTO_APPLY_PROMPT_EVOLUTION=false
PROMPT_EVOLUTION_TRIGGER_INTERVAL=20
PROMPT_EVOLUTION_MAX_VERSIONS=50
```

**Characteristics:**
- Disabled by default
- High quality threshold
- Manual review required
- Good for learning the system

---

#### Profile 2: Active Learning (Experienced Users)

```bash
ENABLE_PROMPT_EVOLUTION=true
PROMPT_EVOLUTION_MIN_INTERACTIONS=20
PROMPT_EVOLUTION_MAX_HISTORY=150
PROMPT_EVOLUTION_CONFIDENCE_THRESHOLD=0.7
AUTO_APPLY_PROMPT_EVOLUTION=false
PROMPT_EVOLUTION_TRIGGER_INTERVAL=10
PROMPT_EVOLUTION_MAX_VERSIONS=100
```

**Characteristics:**
- Enabled, but manual review
- Frequent analysis
- Balanced confidence
- Extended version history

---

#### Profile 3: Autonomous Evolution (Advanced Users)

```bash
ENABLE_PROMPT_EVOLUTION=true
PROMPT_EVOLUTION_MIN_INTERACTIONS=30
PROMPT_EVOLUTION_MAX_HISTORY=200
PROMPT_EVOLUTION_CONFIDENCE_THRESHOLD=0.75
AUTO_APPLY_PROMPT_EVOLUTION=true
PROMPT_EVOLUTION_TRIGGER_INTERVAL=15
PROMPT_EVOLUTION_MAX_VERSIONS=100
```

**Characteristics:**
- Fully enabled with auto-apply
- Moderate analysis frequency
- Balanced risk/reward
- Good for experienced users

---

## Usage Guide

### Manual Trigger

```
User: Analyze my recent interactions using meta-learning.

Agent: [Analyzes last 100 messages for patterns]

Output:
- 2 failure patterns detected
- 3 success patterns found
- 4 prompt refinements suggested
- 2 new tools recommended
```

### Query Results

```
User: Show me the meta-learning suggestions from my last session.

Agent: [Retrieves from SOLUTIONS memory area]

Results: Full analysis with:
- Specific improvements recommended
- Confidence scores for each
- Files affected
- Rationale for changes
```

### Apply Changes

```
User: Apply the top 3 suggestions from the meta-learning analysis.

Agent: [Creates backup, applies changes, reports results]
```

---

## Safety Features

🔒 **Automatic Versioning** - Every change creates a backup  
✔️ **Confidence Scoring** - Only high-confidence suggestions shown  
📋 **Pattern Validation** - Minimum 2 occurrences required  
↩️ **One-Command Rollback** - Revert to any previous state  
🔍 **Audit Trail** - Full history of all changes  
🧪 **Test Coverage** - Comprehensive test suite included  

---

## Best Practices

✅ **Start with manual review** (AUTO_APPLY=false)  
✅ **Run 50+ interactions first** before enabling analysis  
✅ **Review suggestions carefully** before applying  
✅ **Apply changes gradually** (1-2 at a time)  
✅ **Monitor impact** after each change  
✅ **Maintain version history** for rollback capability  
✅ **Check confidence scores** - higher is better  

❌ **Don't enable auto-apply immediately**  
❌ **Don't apply all suggestions at once**  
❌ **Don't ignore low-confidence suggestions**  
❌ **Don't skip the backup step**  

---

## Troubleshooting

### Issue: "Insufficient history"
**Solution:** Run more interactions (default: 20 minimum)
```bash
export PROMPT_EVOLUTION_MIN_INTERACTIONS=5  # Lower threshold
```

### Issue: "No suggestions generated"
**Solution:** Lower confidence threshold
```bash
export PROMPT_EVOLUTION_CONFIDENCE_THRESHOLD=0.5  # Default: 0.7
```

### Issue: "Changes reverted unexpectedly"
**Solution:** Check the rollback feature - you may have rolled back
```bash
# List versions to see what happened
python3 -c "from python.helpers.prompt_versioning import PromptVersionManager as P; print([v['version_id'] for v in P().list_versions()])"
```

### Issue: "Meta-learning not triggering"
**Solution:** Verify it's enabled
```bash
# Check environment
echo $ENABLE_PROMPT_EVOLUTION  # Should be "true"

# Check frequency
echo $PROMPT_EVOLUTION_FREQUENCY  # Default: 10
```

---

## Testing

The system includes a comprehensive test suite:

```bash
# Quick verification (no dependencies)
python3 tests/meta_learning/verify_test_structure.py

# Full test suite (requires dependencies)
python3 tests/meta_learning/manual_test_prompt_evolution.py
```

See [README_TESTS.md](README_TESTS.md) for detailed test documentation.

---

## Further Reading

| Document | Purpose |
|----------|---------|
| [QUICKSTART.md](QUICKSTART.md) | Get running in 2 minutes |
| [meta_learning.md](meta_learning.md) | Complete system guide |
| [README_TESTS.md](README_TESTS.md) | How to run tests |
| [TEST_SUMMARY.md](TEST_SUMMARY.md) | Test coverage details |
| [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md) | Visual diagrams |
| [INDEX.md](INDEX.md) | File reference |
| [DELIVERABLES.md](DELIVERABLES.md) | Project summary |

## Getting Help

1. **Quick questions?** → Check [QUICKSTART.md](QUICKSTART.md)
2. **How to use?** → See [meta_learning.md](meta_learning.md)
3. **How to test?** → Read [README_TESTS.md](README_TESTS.md)
4. **Need details?** → Review [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md)
5. **Want overview?** → Look at [INDEX.md](INDEX.md)

## Contributing

To improve the meta-learning system:

1. Review the [test suite](README_TESTS.md)
2. Run tests to establish baseline
3. Make your changes
4. Add test scenarios for new features
5. Update documentation
6. Submit with full test coverage

---

## Version History

- **v1.0** (2026-01-05) - Initial implementation and test suite
  - Core prompt evolution tool
  - Prompt versioning system
  - Meta-learning API
  - Comprehensive test suite
  - Full documentation

---

## License

Agent Zero Meta-Learning System is part of the Agent Zero project.
See LICENSE file in project root for details.

---

**Last Updated:** 2026-01-05  
**Status:** Production Ready  
**Test Coverage:** 19 scenarios, 30+ assertions