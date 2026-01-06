# Agent Zero - Development Guide

## Running Agent Zero

### Web UI (Recommended)
```bash
python run_ui.py
# Flask server on port 50001
# Access at http://localhost:50001
```

### CLI (Direct Execution)
```bash
python agent.py
# Run agent directly from command line
```

### Docker
```bash
docker pull agent0ai/agent-zero
docker run -p 50001:80 agent0ai/agent-zero
```

### Installation & Setup
```bash
pip install -r requirements.txt
python initialize.py  # First-time setup wizard
```

## Common Development Commands

### Testing
```bash
# Run all tests
python -m pytest tests/

# Run specific test file
python -m pytest tests/rate_limiter_test.py

# Run with verbose output
python -m pytest tests/ -v

# Run specific test function
python -m pytest tests/rate_limiter_test.py::test_function_name
```

### Other Commands
```bash
# Start tunnel service (for external access)
python run_tunnel.py

# Check health
curl http://localhost:50001/health

# Install in editable mode (for development)
pip install -e .
```

## Extending Agent Zero

### Adding Custom Tools

1. **Create tool file** - `python/tools/my_tool.py`
```python
from python.helpers.tool import Tool
from python.helpers.response import Response

class MyTool(Tool):
    async def execute(self) -> Response:
        # Your tool logic here
        return Response(...)
```

2. **Inherit from Tool base class** - Located in `python/helpers/tool.py`

3. **Implement async execute()** - Main tool logic

4. **Add prompt file** - `prompts/default/agent.system.tool.my_tool.md`
   - Instructs the agent on how to use your tool

5. **Tool is auto-discovered** - When agent mentions it in response

### Adding Extensions

1. **Create extension file** - `python/extensions/[extension_point]/[priority]_name.py`
   - Priority: 10=early, 90=late (determines execution order)

2. **Implement extend function**
```python
async def extend(loop_data, ...):
    # Modify loop_data to change state/history/prompt
    pass
```

3. **Modify loop_data** - Change state, history, or prompt

4. **File name priority** - Determines execution order

### Creating Agent Profiles

1. **Copy template** - `cp -r agents/_example/ agents/[new_profile]/`

2. **Add custom prompts** - In `prompts/` subfolder

3. **Override defaults** - Can override tools, settings, memory location

4. **Select profile** - In settings or via API

## Configuration

### Environment Variables (.env)
```bash
# API Keys
OPENROUTER_API_KEY=...      # Default LLM provider
OPENAI_API_KEY=...          # For OpenAI models
ANTHROPIC_API_KEY=...       # For Claude models

# Server Settings
HOST=localhost              # Default: localhost
PORT=50001                  # Default: 50001
SSL=false                   # Enable HTTPS

# Model Selection
CHAT_MODEL_PROVIDER=openrouter
CHAT_MODEL_NAME=...
UTILITY_MODEL_PROVIDER=...
EMBEDDING_MODEL_PROVIDER=...
```

### Model Configuration
- File: `conf/model_providers.yaml`
- Defines available LLM providers
- Supports 20+ providers via LiteLLM

## Important Files & Locations

### Core Files
- **agent.py** - Core Agent class, message loop entry (line 356)
- **models.py** - LLM model config and integration
- **initialize.py** - Setup wizard
- **run_ui.py** - Flask web server (main entry)
- **run_tunnel.py** - Remote access tunnel

### Backend Structure
- **python/api/** - 61+ Flask API endpoints
- **python/tools/** - ~20 built-in tools
- **python/extensions/** - 24 extension points
- **python/helpers/** - ~73 utility modules

### Frontend Structure
- **webui/index.html** - Main page
- **webui/index.js** - App initialization
- **webui/components/** - UI components
- **webui/js/** - JavaScript modules
- **webui/css/** - Stylesheets

### Configuration & Data
- **prompts/** - ~100 system prompt files
- **agents/** - Agent profiles
- **memory/** - FAISS indices
- **knowledge/** - Knowledge base for RAG
- **instruments/** - Custom automation scripts
- **logs/** - HTML chat logs

## Key Helper Modules

| Module | Purpose |
|--------|---------|
| call_llm.py | LLM interaction wrapper |
| memory.py | Vector DB memory system |
| history.py | Message history management |
| tool.py | Tool base class |
| extract_tools.py | Tool discovery from responses |
| extension.py | Extension loading system |
| settings.py | Settings management |
| context.py | Request context management |
| log.py | Logging system |
| shell_*.py | Shell execution (local, SSH) |
| files.py | File operations |
| mcp_handler.py | MCP server/client support |
| knowledge_import.py | Knowledge base management |

## Testing Structure

### Test Files
- Located in `/tests/` directory
- Named `test_*.py` or `*_test.py`
- Use pytest framework

### Running Tests
```bash
# All tests
python -m pytest tests/

# Specific file
python -m pytest tests/rate_limiter_test.py

# Verbose
python -m pytest tests/ -v

# Specific function
python -m pytest tests/rate_limiter_test.py::test_function_name
```

## Performance Optimization

### Context Window Management
- Automatic history compression
- Bulk summarization for long conversations
- Semantic memory retrieval to reduce context size

### Rate Limiting
- Per-model rate limits via LiteLLM
- Configurable limits in settings
- Prevents API quota exhaustion

### Memory Optimization
- FAISS vector database for efficient search
- Lazy loading of prompts and extensions
- Streaming responses to avoid buffering

## Debugging & Troubleshooting

### Logs
- **Chat logs** - Auto-saved HTML files in `/logs/`
- **Server logs** - Printed to console
- **Agent reasoning** - Visible in UI in real-time

### Common Issues
- **Tool not executing** - Check prompt includes tool instructions
- **Memory not loading** - Verify embedding model configured
- **LLM errors** - Check API key, rate limits, context window
- **UI not loading** - Ensure Flask server running, check port
- **Agent stuck** - Can intervene in real-time via UI

## Implementation Status

### ✅ Completed
1. **Self-Evolving Meta-Layer** - IMPLEMENTED
   - Agent learns and optimizes its own prompts through meta-learning
   - Located in `prompts/meta_learning.analyze.sys.md` and related files

### 🔄 Next Implementation Phases
2. **Security & Ethics Hardening** - Ethical guardrails and safety checks
3. **Plugin Ecosystem** - Formalize plugin/extension marketplace
4. **Cost/Efficiency Optimization** - Intelligent model routing
5. **Deployment Streamlining** - One-click cloud deployments
