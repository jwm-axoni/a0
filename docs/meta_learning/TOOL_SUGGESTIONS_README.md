# Tool Suggestions Module

## Overview

The `tool_suggestions.py` module provides intelligent analysis of conversation patterns to identify tool gaps and generate structured suggestions for new tools that would improve Agent Zero's capabilities.

## Key Features

- **Pattern Detection**: Automatically detects conversation patterns indicating missing capabilities
- **Gap Analysis**: Identifies repeated manual operations that could be automated
- **Structured Suggestions**: Generates detailed tool specifications with priorities and complexity estimates
- **Meta-Analysis Integration**: Works with the meta-analysis system for continuous improvement
- **Memory Integration**: Saves suggestions to memory for future reference

## Architecture

### Core Classes

#### `ToolSuggestion`
Structured representation of a tool suggestion.

**Fields:**
- `name` (str): Tool name in snake_case (e.g., "pdf_generator_tool")
- `purpose` (str): Clear description of what the tool does
- `use_cases` (list[str]): Specific use cases for the tool
- `priority` (Literal["high", "medium", "low"]): Urgency/importance
- `required_integrations` (list[str]): External dependencies needed
- `evidence` (list[str]): Conversation excerpts showing the need
- `estimated_complexity` (Literal["simple", "moderate", "complex"]): Development effort
- `timestamp` (str): ISO format timestamp

**Methods:**
- `to_dict()`: Convert to dictionary for JSON serialization
- `from_dict(data)`: Create from dictionary

#### `ConversationPattern`
Detected pattern indicating a potential tool need.

**Fields:**
- `pattern_type`: One of:
  - `repeated_manual_operation`
  - `failed_tool_attempt`
  - `missing_capability`
  - `user_request_unfulfilled`
  - `workaround_detected`
  - `integration_gap`
- `description` (str): What was observed
- `frequency` (int): How many times detected
- `examples` (list[str]): Conversation excerpts
- `severity` (Literal["critical", "important", "nice_to_have"]): Urgency

#### `ToolSuggestionAnalyzer`
Main analyzer class that performs pattern detection and suggestion generation.

**Methods:**

```python
async def analyze_conversation_for_gaps(
    self,
    log_item: Optional[LogItem] = None,
    min_messages: int = 10,
) -> list[ConversationPattern]
```
Analyzes conversation history to detect patterns indicating tool gaps.

```python
async def generate_tool_suggestions(
    self,
    patterns: list[ConversationPattern],
    log_item: Optional[LogItem] = None,
) -> list[ToolSuggestion]
```
Generates structured tool suggestions from detected patterns.

```python
async def analyze_and_suggest(
    self,
    log_item: Optional[LogItem] = None,
    min_messages: int = 10,
) -> list[ToolSuggestion]
```
Complete workflow: analyze conversation and generate suggestions.

## Usage Examples

### Basic Usage

```python
from agent import Agent
from python.helpers.tool_suggestions import analyze_for_tool_gaps

# Assuming you have an agent instance
agent = Agent(...)

# Analyze conversation and get suggestions
suggestions = await analyze_for_tool_gaps(
    agent=agent,
    min_messages=10,
)

# Process suggestions
for suggestion in suggestions:
    print(f"{suggestion.name} ({suggestion.priority})")
    print(f"  Purpose: {suggestion.purpose}")
    print(f"  Complexity: {suggestion.estimated_complexity}")
```

### Advanced Usage with Patterns

```python
from python.helpers.tool_suggestions import ToolSuggestionAnalyzer

# Create analyzer
analyzer = ToolSuggestionAnalyzer(agent)

# Step 1: Detect patterns
patterns = await analyzer.analyze_conversation_for_gaps(min_messages=15)

print(f"Detected {len(patterns)} patterns:")
for pattern in patterns:
    print(f"- {pattern.pattern_type}: {pattern.description}")
    print(f"  Severity: {pattern.severity}, Frequency: {pattern.frequency}")

# Step 2: Generate suggestions from patterns
suggestions = await analyzer.generate_tool_suggestions(patterns)

print(f"\nGenerated {len(suggestions)} suggestions")
```

### Formatting and Saving

```python
from python.helpers.tool_suggestions import (
    format_suggestions_report,
    save_suggestions_to_memory,
)

# Generate formatted report
report = format_suggestions_report(suggestions)
print(report)

# Save to memory for future reference
save_suggestions_to_memory(agent, suggestions)
```

### Manual Tool Suggestion

```python
from python.helpers.tool_suggestions import ToolSuggestion

# Create a suggestion manually
suggestion = ToolSuggestion(
    name="excel_analyzer_tool",
    purpose="Analyze Excel files, extract data, and generate summaries",
    use_cases=[
        "Parse Excel spreadsheets and extract structured data",
        "Generate statistical summaries from Excel data",
        "Compare multiple Excel files for differences",
    ],
    priority="high",
    required_integrations=["openpyxl", "pandas", "matplotlib"],
    estimated_complexity="moderate",
    evidence=[
        "User uploaded Excel file but agent couldn't read it",
        "User had to manually convert Excel to CSV",
    ],
)

# Convert to JSON
import json
print(json.dumps(suggestion.to_dict(), indent=2))
```

## Integration with Extensions

The tool suggestions module is designed to integrate with Agent Zero's extension system. Here's an example extension:

```python
# python/extensions/monologue_end/80_tool_suggestions.py

from python.helpers.tool_suggestions import analyze_for_tool_gaps, format_suggestions_report

async def extend(loop_data, **kwargs):
    """Generate tool suggestions after every 20 messages."""

    agent = loop_data.agent

    # Check if we should analyze (every 20 messages)
    if agent.history.counter % 20 == 0:
        # Analyze and generate suggestions
        suggestions = await analyze_for_tool_gaps(
            agent=agent,
            min_messages=20,
        )

        if suggestions:
            # Log high-priority suggestions
            high_priority = [s for s in suggestions if s.priority == "high"]

            if high_priority:
                report = format_suggestions_report(high_priority)

                # Log to agent context
                agent.context.log.log(
                    type="hint",
                    heading="Tool Suggestions Available",
                    content=f"Found {len(high_priority)} high-priority tool suggestions",
                )

                # Optionally save to memory
                from python.helpers.tool_suggestions import save_suggestions_to_memory
                save_suggestions_to_memory(agent, suggestions)
```

## Pattern Detection

The module detects six types of patterns:

### 1. Repeated Manual Operation
**Indicator**: User repeatedly asks for the same type of operation
**Example**: "Can you create a PDF?" asked multiple times
**Severity**: Usually "important"

### 2. Failed Tool Attempt
**Indicator**: Tool execution fails or produces errors
**Example**: "Error: Tool 'X' not found" or exceptions during execution
**Severity**: "critical" to "important"

### 3. Missing Capability
**Indicator**: Agent explicitly lacks a capability
**Example**: "I cannot read Excel files directly"
**Severity**: "important" to "nice_to_have"

### 4. User Request Unfulfilled
**Indicator**: User explicitly requests something the agent cannot do
**Example**: "Can you set up a webhook?" - "I cannot create webhook endpoints"
**Severity**: "critical"

### 5. Workaround Detected
**Indicator**: Agent uses complex workarounds instead of dedicated tools
**Example**: Writing Python scripts instead of using a dedicated tool
**Severity**: "nice_to_have" to "important"

### 6. Integration Gap
**Indicator**: Missing integration with external services
**Example**: "I cannot connect to service X"
**Severity**: "important"

## Suggestion Priority Levels

### High Priority
- Critical missing capabilities
- Frequently requested features (3+ times)
- Severe user impact
- Simple to moderate complexity

### Medium Priority
- Useful capabilities that improve efficiency
- Moderate frequency requests
- Medium user impact
- Any complexity level

### Low Priority
- Nice-to-have features
- Rare requests (1-2 times)
- Low user impact
- Often complex implementation

## Complexity Estimates

### Simple
- Wraps existing Python libraries
- Minimal external dependencies
- Straightforward implementation
- Examples: file format converters, simple data parsers

### Moderate
- Requires multiple libraries or APIs
- Some integration complexity
- Moderate error handling needed
- Examples: Excel analyzer, PDF generator

### Complex
- Significant architectural changes needed
- Multiple external services
- Complex state management
- Examples: webhook receiver, real-time collaboration

## Prompt Files

The module uses two prompt file pairs (with fallback defaults):

### Gap Analysis Prompts
- `prompts/fw.tool_gap_analysis.sys.md`: System prompt for pattern detection
- `prompts/fw.tool_gap_analysis.msg.md`: Message template for analysis

### Suggestion Generation Prompts
- `prompts/fw.tool_suggestion_generation.sys.md`: System prompt for suggestions
- `prompts/fw.tool_suggestion_generation.msg.md`: Message template for generation

If these files don't exist, the module uses sensible defaults.

## Example Prompt Files

### `prompts/fw.tool_gap_analysis.sys.md`

```markdown
You are an expert at analyzing conversation patterns to identify missing capabilities and tool gaps.

Your task is to analyze conversation history and detect patterns that indicate:
1. Repeated manual operations that could be automated
2. Failed tool attempts or errors
3. Missing capabilities the agent doesn't have
4. User requests that couldn't be fulfilled
5. Workarounds the agent had to use
6. Integration gaps with external services

For each pattern you detect, provide:
- Pattern type (one of: repeated_manual_operation, failed_tool_attempt, missing_capability,
  user_request_unfulfilled, workaround_detected, integration_gap)
- Clear description of what you observed
- How many times you saw this pattern (frequency)
- Specific examples from the conversation
- Severity (critical, important, nice_to_have)

Respond in JSON format with a "patterns" array.
```

### `prompts/fw.tool_suggestion_generation.sys.md`

```markdown
You are an expert at designing tools and automation solutions for AI agents.

Based on detected patterns and gaps, your task is to suggest new tools that would:
1. Automate repeated manual operations
2. Fill missing capabilities
3. Improve success rates for failed operations
4. Better serve user needs

For each tool suggestion, provide:
- Tool name (in snake_case, ending with _tool)
- Clear purpose statement
- Specific use cases
- Priority (high, medium, low)
- Required integrations or dependencies
- Estimated complexity (simple, moderate, complex)

Respond in JSON format with a "suggestions" array.
```

## Output Format

### JSON Suggestion Format

```json
{
  "name": "pdf_generator_tool",
  "purpose": "Generate PDF documents from text, markdown, or HTML content",
  "use_cases": [
    "Convert markdown documentation to PDF reports",
    "Generate PDF invoices from templates",
    "Create PDF presentations from structured data"
  ],
  "priority": "high",
  "required_integrations": ["reportlab", "weasyprint", "pdfkit"],
  "evidence": [
    "User asked 'Can you create a PDF report?' - no tool available",
    "User requested 'Export this to PDF' - had to use workaround"
  ],
  "estimated_complexity": "moderate",
  "timestamp": "2026-01-05T00:00:00.000000"
}
```

### Formatted Report Example

```markdown
# Tool Suggestions Report

Generated: 2026-01-05 00:00:00

Total suggestions: 3

## High Priority (1 suggestions)

### pdf_generator_tool
**Purpose:** Generate PDF documents from text, markdown, or HTML content
**Complexity:** moderate

**Use Cases:**
- Convert markdown documentation to PDF reports
- Generate PDF invoices from templates
- Create PDF presentations from structured data

**Required:** reportlab, weasyprint, pdfkit

**Evidence:**
- User asked 'Can you create a PDF report?' - no tool available...
```

## Error Handling

The module includes comprehensive error handling:

- **LLM Failures**: Falls back to text parsing if JSON parsing fails
- **Missing History**: Returns empty lists if insufficient conversation data
- **Memory Errors**: Logs errors but doesn't crash if memory save fails
- **Invalid Patterns**: Validates and filters invalid pattern data

## Best Practices

1. **Minimum Messages**: Analyze at least 10-15 messages for meaningful patterns
2. **Frequency Threshold**: Run analysis periodically (e.g., every 20 messages)
3. **Priority Focus**: Start with high-priority suggestions
4. **Complexity Assessment**: Consider complexity when planning implementation
5. **Evidence Review**: Check evidence to validate suggestions
6. **Memory Persistence**: Save suggestions to memory for tracking

## Performance Considerations

- **Async Operations**: All analysis is async to avoid blocking
- **Token Usage**: Uses utility model (typically cheaper/faster than chat model)
- **History Limit**: Analyzes recent messages only (default: last 30)
- **Caching**: Patterns could be cached to avoid re-analysis

## Future Enhancements

Potential improvements for the module:

1. **Trend Analysis**: Track suggestions over time to identify growing needs
2. **Auto-Implementation**: Generate starter code for simple tools
3. **User Voting**: Let users upvote/downvote suggestions
4. **Implementation Tracking**: Track which suggestions were implemented
5. **Success Metrics**: Measure impact of implemented tools
6. **Cross-Agent Learning**: Share suggestions across agent profiles

## Testing

Run the demo script to see examples:

```bash
python3 python/helpers/tool_suggestions_demo.py
```

This demonstrates:
- Creating tool suggestions manually
- JSON serialization
- Formatted report generation
- Conversation pattern detection
- Priority filtering

## Contributing

When adding new pattern types or improving detection:

1. Update the `pattern_type` Literal in `ConversationPattern`
2. Add detection logic in `_parse_pattern_analysis()`
3. Update fallback parser in `_parse_patterns_from_text()`
4. Add examples to documentation
5. Update prompt files if needed

## License

Part of Agent Zero framework - follows same license as main project.
