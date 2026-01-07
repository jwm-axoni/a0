# Tool Suggestions Module - Quick Reference

## Import
```python
from python.helpers.tool_suggestions import (
    analyze_for_tool_gaps,           # Main convenience function
    ToolSuggestionAnalyzer,           # Advanced usage
    ToolSuggestion,                   # Data structure
    ConversationPattern,              # Pattern data structure
    format_suggestions_report,        # Format output
    save_suggestions_to_memory,       # Persist to memory
    get_conversation_patterns,        # Just get patterns
)
```

## Quick Start (One-Liner)
```python
# Get suggestions immediately
suggestions = await analyze_for_tool_gaps(agent, min_messages=10)
```

## Common Workflows

### 1. Simple Analysis
```python
suggestions = await analyze_for_tool_gaps(agent, min_messages=10)

for s in suggestions:
    print(f"{s.name} ({s.priority}): {s.purpose}")
```

### 2. Filtered by Priority
```python
suggestions = await analyze_for_tool_gaps(agent)
high_priority = [s for s in suggestions if s.priority == "high"]

print(f"Found {len(high_priority)} high-priority tools to build")
```

### 3. Generate Report
```python
suggestions = await analyze_for_tool_gaps(agent)
report = format_suggestions_report(suggestions)
print(report)  # Markdown formatted
```

### 4. Save to Memory
```python
suggestions = await analyze_for_tool_gaps(agent)
save_suggestions_to_memory(agent, suggestions)
```

### 5. Pattern Detection Only
```python
patterns = await get_conversation_patterns(agent, min_messages=10)

for p in patterns:
    print(f"{p.pattern_type}: {p.description} (x{p.frequency})")
```

## Data Structures

### ToolSuggestion
```python
suggestion = ToolSuggestion(
    name="example_tool",                    # snake_case, ends with _tool
    purpose="What it does",                 # Clear description
    use_cases=["case 1", "case 2"],         # List of use cases
    priority="high",                        # high/medium/low
    required_integrations=["lib1", "lib2"], # Dependencies
    estimated_complexity="moderate",        # simple/moderate/complex
    evidence=["example 1", "example 2"],    # Conversation excerpts
)

# Serialization
json_data = suggestion.to_dict()            # For JSON
suggestion2 = ToolSuggestion.from_dict(json_data)
```

### ConversationPattern
```python
pattern = ConversationPattern(
    pattern_type="repeated_manual_operation",  # See types below
    description="What was observed",
    frequency=3,                               # How many times
    examples=["excerpt 1", "excerpt 2"],       # Conversation examples
    severity="important",                      # critical/important/nice_to_have
)
```

## Pattern Types
- `repeated_manual_operation` - Same request multiple times
- `failed_tool_attempt` - Tool errors or failures
- `missing_capability` - Agent lacks feature
- `user_request_unfulfilled` - User need not met
- `workaround_detected` - Complex workaround used
- `integration_gap` - Missing external integration

## Priority Levels
- `high` - Critical, frequently requested, high impact
- `medium` - Useful, moderate frequency, medium impact
- `low` - Nice-to-have, rare requests, low impact

## Complexity Levels
- `simple` - Wraps existing libraries, straightforward
- `moderate` - Multiple libraries, some complexity
- `complex` - Significant architecture, multiple services

## Advanced Usage

### Custom Analysis Flow
```python
analyzer = ToolSuggestionAnalyzer(agent)

# Step 1: Get patterns
patterns = await analyzer.analyze_conversation_for_gaps(
    min_messages=15
)

# Step 2: Filter patterns
critical = [p for p in patterns if p.severity == "critical"]

# Step 3: Generate suggestions
suggestions = await analyzer.generate_tool_suggestions(critical)

# Step 4: Process
for s in suggestions:
    # Create GitHub issue, log to dashboard, etc.
    pass
```

### With Progress Logging
```python
log_item = agent.context.log.log(
    type="util",
    heading="Analyzing for tool gaps..."
)

suggestions = await analyze_for_tool_gaps(
    agent=agent,
    log_item=log_item,
    min_messages=10,
)

log_item.update(
    heading=f"Found {len(suggestions)} suggestions",
    content=format_suggestions_report(suggestions)
)
```

### Manual Suggestion Creation
```python
# Create a suggestion manually
suggestion = ToolSuggestion(
    name="my_custom_tool",
    purpose="Does something specific",
    use_cases=["Use case 1", "Use case 2"],
    priority="medium",
    required_integrations=["library1"],
    estimated_complexity="simple",
)

# Add to list with analyzed suggestions
suggestions.append(suggestion)
```

## Extension Integration

### Periodic Analysis (Every 20 Messages)
```python
# python/extensions/monologue_end/80_tool_suggestions.py

from python.helpers.tool_suggestions import analyze_for_tool_gaps

async def extend(loop_data, **kwargs):
    agent = loop_data.agent

    # Run every 20 messages
    if agent.history.counter % 20 == 0:
        suggestions = await analyze_for_tool_gaps(agent, min_messages=20)

        high_priority = [s for s in suggestions if s.priority == "high"]

        if high_priority:
            agent.context.log.log(
                type="hint",
                heading=f"Tool Suggestions: {len(high_priority)} high-priority",
            )
```

### On-Demand Analysis
```python
# python/tools/suggest_tools.py

from python.helpers.tool import Tool, Response
from python.helpers.tool_suggestions import analyze_for_tool_gaps, format_suggestions_report

class SuggestTools(Tool):
    async def execute(self):
        suggestions = await analyze_for_tool_gaps(
            self.agent,
            min_messages=10,
        )

        report = format_suggestions_report(suggestions)

        return Response(
            message=report,
            break_loop=False,
        )
```

## Output Examples

### JSON
```json
{
  "name": "pdf_generator_tool",
  "purpose": "Generate PDF documents from content",
  "use_cases": ["Convert markdown to PDF", "Generate reports"],
  "priority": "high",
  "required_integrations": ["reportlab", "weasyprint"],
  "estimated_complexity": "moderate",
  "timestamp": "2026-01-05T00:00:00"
}
```

### Markdown Report
```markdown
# Tool Suggestions Report

## High Priority (2 suggestions)

### pdf_generator_tool
**Purpose:** Generate PDF documents
**Complexity:** moderate
**Use Cases:**
- Convert markdown to PDF
- Generate reports
**Required:** reportlab, weasyprint
```

## Configuration

### Minimum Messages
Default: 10 (configurable)
```python
suggestions = await analyze_for_tool_gaps(agent, min_messages=15)
```

### Prompt Files (Optional)
Create these to customize LLM analysis:
- `prompts/fw.tool_gap_analysis.sys.md`
- `prompts/fw.tool_gap_analysis.msg.md`
- `prompts/fw.tool_suggestion_generation.sys.md`
- `prompts/fw.tool_suggestion_generation.msg.md`

If not present, built-in fallbacks are used.

## Common Use Cases

### 1. Meta-Analysis Dashboard
```python
suggestions = await analyze_for_tool_gaps(agent)
high = [s for s in suggestions if s.priority == "high"]

# Display in dashboard
dashboard.show_suggestions(high)
```

### 2. Automated Issue Creation
```python
suggestions = await analyze_for_tool_gaps(agent)

for s in suggestions:
    if s.priority == "high":
        create_github_issue(
            title=f"[Tool] {s.name}",
            body=f"Purpose: {s.purpose}\n\nUse Cases:\n" +
                 "\n".join(f"- {uc}" for uc in s.use_cases),
            labels=["enhancement", "tool", s.priority],
        )
```

### 3. User Notification
```python
suggestions = await analyze_for_tool_gaps(agent)
critical = [s for s in suggestions if s.priority == "high"]

if critical:
    notify_user(
        f"Found {len(critical)} high-priority tool suggestions. "
        "Would you like to see them?"
    )
```

### 4. Implementation Tracking
```python
# Load saved suggestions from memory
memory = await Memory.get(agent)
saved = await memory.search_similarity_threshold(
    query="tool suggestion",
    limit=50,
    threshold=0.7,
    filter="type == 'tool_suggestion'"
)

# Check which are implemented
for doc in saved:
    tool_name = doc.metadata.get("tool_name")
    if tool_exists(tool_name):
        print(f"✓ {tool_name} - Implemented")
    else:
        print(f"○ {tool_name} - Pending")
```

## Error Handling

All functions include error handling and return empty lists on failure:

```python
try:
    suggestions = await analyze_for_tool_gaps(agent)
except Exception as e:
    print(f"Error: {e}")
    suggestions = []  # Graceful fallback

# Safe to iterate
for s in suggestions:
    process(s)
```

## Performance Tips

1. **Message Limit**: Set `min_messages` appropriately (10-30)
2. **Frequency**: Run periodically, not every message
3. **Filtering**: Filter by priority before detailed processing
4. **Caching**: Consider caching patterns for short periods
5. **Async**: Always use async/await, never block

## Demo Script

Run the demo to see examples:
```bash
python3 python/helpers/tool_suggestions_demo.py
```

Shows:
- Creating suggestions manually
- JSON serialization
- Report formatting
- Pattern detection
- Priority filtering

## Files Reference

- **Core Module**: `python/helpers/tool_suggestions.py` (750 lines)
- **Documentation**: `python/helpers/TOOL_SUGGESTIONS_README.md`
- **Demo**: `python/helpers/tool_suggestions_demo.py`
- **Examples**: `python/helpers/tool_suggestions_example.py`
- **This Reference**: `python/helpers/TOOL_SUGGESTIONS_QUICK_REF.md`

## Support

For detailed documentation, see:
- `TOOL_SUGGESTIONS_README.md` - Full documentation
- `TOOL_SUGGESTIONS_IMPLEMENTATION.md` - Implementation details
- Demo script for working examples

---

**Version**: 1.0
**Date**: 2026-01-05
**Status**: Production Ready
