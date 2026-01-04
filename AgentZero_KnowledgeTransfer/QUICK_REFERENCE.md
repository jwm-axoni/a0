# Agent Zero - Quick Reference Guide

## Project Essentials

**Project:** Agent Zero - Dynamic Agentic AI Framework
**Version:** v0.9.7 (Projects feature with isolated workspaces)
**Language:** Python (backend) + JavaScript (frontend)
**Type:** Open-source, fully customizable AI agent framework

**Repository Stats:**
- 1,066 files
- 4.98M tokens
- 14.66M characters
- 922-line core (agent.py)
- 100+ prompt files
- 20 built-in tools
- 24 extension points

---

## Quick Start

### Running the Application

```bash
# Web UI (Flask server on port 50001)
python run_ui.py

# CLI (direct agent execution)
python agent.py

# Docker
docker pull agent0ai/agent-zero
docker run -p 50001:80 agent0ai/agent-zero

# Installation
pip install -r requirements.txt
python initialize.py
```

### Common Commands

```bash
# Run tests
python -m pytest tests/

# Run specific test
python -m pytest tests/rate_limiter_test.py -v

# Start tunnel service (for external access)
python run_tunnel.py

# Check health
curl http://localhost:50001/health
```

---

## Core Architecture

### The Message Loop (agent.py:356)

```python
async def monologue(self):
    # LOOP: Iterate until response_tool is used
    while True:
        # 1. Build system prompt
        # 2. Load message history
        # 3. Call LLM (streaming)
        # 4. Extract tools from response
        # 5. Execute tool(s)
        # 6. Add results to history
        # 7. If response_tool -> break
        # 8. Else -> continue loop
```

### Key Components

| Component | File | Purpose |
|-----------|------|---------|
| **Agent Class** | `agent.py` | Core reasoning loop |
| **AgentContext** | `agent.py` | Request-scoped context |
| **Tool System** | `python/tools/` | Dynamic capability execution |
| **Memory** | `python/helpers/memory.py` | FAISS vector database |
| **History** | `python/helpers/history.py` | Message history management |
| **Extensions** | `python/extensions/` | 24 customization points |
| **Prompts** | `prompts/` | ~100 system prompts |
| **API** | `python/api/` | 61+ REST endpoints |
| **Web UI** | `webui/` | Vanilla JS + Alpine |

---

## Tool System

### Built-in Tools (20+)

```
1. code_execution_tool    - Python/Node/Shell execution
2. browser_agent         - Web automation
3. call_subordinate      - Agent delegation
4. search_engine         - Web search
5. document_query        - Document RAG
6. memory_save           - Save to memory
7. memory_load           - Query memory
8. memory_delete         - Delete memory entry
9. memory_forget         - Clear memory area
10. scheduler            - Task scheduling
11. behaviour_adjustment - Dynamic behavior
12. response             - Finalize response
13. input                - Request user input
14. wait                 - Timed waiting
15. notify_user          - Send notification
16. a2a_chat             - Agent-to-agent chat
17. vision_load          - Vision data loading
... and more
```

### Using a Tool

Tool usage extracted from LLM response:
```
"I'll use code_execution_tool to run Python"
Tool: code_execution_tool
method: execute_python
args: {"code": "print('hello')"}
```

### Creating a Custom Tool

```python
# File: python/tools/my_tool.py
from python.helpers.tool import Tool, Response

class MyTool(Tool):
    async def execute(self, **kwargs) -> Response:
        # Do work
        result = "Success"
        return Response(
            message=result,
            break_loop=False  # Continue loop
        )
```

Add prompt: `prompts/agent.system.tool.my_tool.md`

---

## Memory System

### Four Memory Areas

- **MAIN** - Core facts and knowledge
- **FRAGMENTS** - Short snippets
- **SOLUTIONS** - Patterns and solutions
- **INSTRUMENTS** - Custom code/tools

### Memory Flow

```
Conversation → Extract (extensions) → Consolidate (Utility LLM)
  ↓
Store in memory area → Embed (Sentence-Transformers)
  ↓
Index in FAISS → Persist to disk
  ↓
Next message: Semantic search retrieves relevant memories
```

### Using Memory API

```bash
# Save to memory
POST /memory_save
{"area": "main", "content": "Important fact"}

# Query memory
GET /memory_load?query=fact

# Delete entry
POST /memory_delete?id=entry_id

# Clear area
POST /memory_forget?area=main

# View statistics
GET /memory_dashboard
```

---

## Extension System

### 24 Extension Points

**Initialization:**
- `agent_init` - Agent initialization
- `message_loop_start` - Start of iteration

**Prompt Building:**
- `message_loop_prompts_before` - Prepare structure
- `message_loop_prompts_after` - Inject context, memories, datetime

**LLM Interaction:**
- `before_main_llm_call` - Final prompt tweaks

**Streaming:**
- `reasoning_stream` - Process thinking tokens
- `response_stream` - Stream to UI

**History Management:**
- `hist_add_before` - Mask sensitive content
- `hist_add_tool_result` - Post-tool processing

**Monologue:**
- `monologue_start` - Initialize
- `monologue_end` - Memory saving, finalization

**Others:**
- `message_loop_end` - Save chat
- `error_format` - Error handling
- `knowledge_loading` - Knowledge base
- `mcp_handler` - MCP integration
- And more...

### Creating an Extension

```python
# File: python/extensions/[point]/_[priority]_name.py
from python.helpers.extension import Extension

class MyExtension(Extension):
    async def execute(self, loop_data, **kwargs):
        # Modify prompt
        loop_data.prompt += "\n\nCustom instruction"
```

File naming: `_[priority]_[name].py`
- Priority 10-29: early
- Priority 30-69: mid
- Priority 70-99: late

### Override in Agent Profile

```
agents/[profile]/extensions/[point]/_[priority]_name.py
```

---

## Prompt System

### ~100 Prompt Files

**Main Prompts:**
- `agent.system.main.md` - Central hub
- `agent.system.main.role.md` - Agent identity
- `agent.system.main.solving.md` - Problem-solving approach
- `agent.system.main.communication.md` - Communication style
- `agent.system.main.environment.md` - Environment knowledge

**Tool Prompts:**
- `agent.system.tools.md` - Tool catalog
- `agent.system.tool.[name].md` - Per-tool instructions

**Behavior:**
- `agent.system.behaviour.md` - Rules and guidelines
- `agent.system.memories.md` - Memory management

**Framework:**
- `fw.*.md` - Error handling, interventions
- `memory.*.md` - Memory operations

**Agent Profiles:**
- `agents/[profile]/prompts/[name].md` - Profile-specific overrides

### Prompt Hierarchy

1. Agent profile prompts (override defaults)
2. Default prompts (fallback)
3. Framework prompts (core instructions)

---

## Configuration

### Environment Variables (.env)

```bash
# API Keys
OPENROUTER_API_KEY=...
OPENAI_API_KEY=...
ANTHROPIC_API_KEY=...

# Server
HOST=localhost
PORT=50001
SSL=false

# Models
CHAT_MODEL_PROVIDER=openrouter
CHAT_MODEL_NAME=...
UTILITY_MODEL_PROVIDER=...
EMBEDDING_MODEL_PROVIDER=...

# Features
ENABLE_RFC=true
ENABLE_MCP=true
ENABLE_VISION=false
```

### Model Configuration

File: `conf/model_providers.yaml`
- Defines available providers
- Model-specific settings
- API endpoints
- Rate limits

### Agent Profiles

Directory: `agents/[profile]/`
- `_context.md` - Profile description
- `prompts/` - Custom prompts
- `extensions/` - Custom extensions
- `tools/` - Tool configurations

**Built-in Profiles:**
- `default` - General-purpose
- `developer` - Code-focused
- `researcher` - Knowledge-focused
- `hacker` - Security-focused
- `agent0` - Example custom profile

---

## API Overview

### Main Endpoints

**Messages:**
- `POST /message` - Send message + stream
- `POST /message_async` - Async with attachments

**Chat:**
- `POST /chat_create` - New chat
- `POST /chat_load` - Load chat
- `POST /chat_remove` - Delete chat
- `POST /chat_export` - Export as JSON/HTML

**Settings:**
- `GET /settings_get` - Get settings
- `POST /settings_set` - Update settings

**Memory:**
- `POST /memory_save` - Save to memory
- `GET /memory_load` - Query memory
- `POST /memory_delete` - Delete entry
- `GET /memory_dashboard` - Statistics

**Knowledge:**
- `POST /import_knowledge` - Import documents
- `POST /knowledge_reindex` - Reindex KB

**Files:**
- `POST /upload` - Upload files
- `GET /download_work_dir_file` - Download
- `GET /get_work_dir_files` - List files

**Backup:**
- `POST /backup_create` - Create backup
- `POST /backup_restore` - Restore

**Scheduler:**
- `POST /scheduler_task_create` - Create task
- `GET /scheduler_tasks_list` - List tasks

**Projects:**
- `POST /projects` - Project operations

**Other:**
- `GET /health` - Health check
- `POST /rfc` - Remote collaboration
- `POST /synthesize` - Text-to-speech
- `POST /transcribe` - Speech-to-text

---

## Web UI

### Technology Stack

- **Framework:** Vanilla JavaScript + Alpine.js
- **Styling:** CSS3
- **Real-time:** WebSocket
- **Markdown:** Marked.js + KaTeX
- **Code:** Ace Editor
- **Speech:** Web Speech API + Whisper

### Main Pages

- `index.html` - Main chat interface
- `login.html` - Login page (optional)

### Components

- Chat display with message rendering
- Sidebar with chat history
- Settings panel
- Modal dialogs
- Notification system
- File attachments
- Message input with formatting

---

## Frontend Structure

### JavaScript Files

```
/webui/js/
├─ api.js           - API client
├─ messages.js      - Message handling
├─ settings.js      - Settings UI
├─ modals.js        - Modal dialogs
├─ components.js    - Component utils
├─ shortcuts.js     - Keyboard shortcuts
├─ speech_browser.js - TTS/STT
├─ scheduler.js     - Scheduler UI
├─ AlpineStore.js   - State management
└─ ... (more)
```

### Components

```
/webui/components/
├─ /sidebar/       - Left sidebar
├─ /chat/          - Chat display
├─ /input/         - Message input
├─ /toolbar/       - Top toolbar
├─ /settings/      - Settings panel
├─ /modals/        - Dialogs
└─ /notifications/ - Notifications
```

---

## Docker

### Quick Start

```bash
# Pull image
docker pull agent0ai/agent-zero

# Run container
docker run -p 50001:80 agent0ai/agent-zero

# With volumes
docker run -p 50001:80 \
  -v $(pwd)/work:/app/work \
  -v $(pwd)/memory:/app/memory \
  -v $(pwd)/logs:/app/logs \
  agent0ai/agent-zero
```

### Docker Compose

File: `docker/run/docker-compose.yml`
- Agent Zero service
- Nginx reverse proxy
- SearXNG search engine
- Process supervisor

### Build Locally

```bash
# Build base image
cd docker/base
docker build -t agent0ai/agent-zero-base .

# Build runtime image
cd ../run
docker build -t agent0ai/agent-zero .

# Run
docker run -p 50001:80 agent0ai/agent-zero
```

---

## Testing

### Running Tests

```bash
# All tests
python -m pytest tests/

# Specific test file
python -m pytest tests/rate_limiter_test.py

# Verbose
python -m pytest tests/ -v

# Specific test
python -m pytest tests/rate_limiter_test.py::test_function_name
```

### Test Files

- `rate_limiter_test.py` - Rate limiting
- `email_parser_test.py` - Email parsing
- `chunk_parser_test.py` - Chunk parsing
- `test_fasta2a_client.py` - Client tests
- `test_file_tree_visualize.py` - File utilities

---

## Key Files

### Core Logic
- `agent.py` (922 lines) - Agent class, message loop
- `models.py` (919 lines) - LLM integration
- `run_ui.py` (285 lines) - Flask server

### Tool System
- `python/helpers/extract_tools.py` - Tool discovery
- `python/helpers/tool.py` - Tool base class
- `python/tools/` - Tool implementations

### Memory
- `python/helpers/memory.py` - FAISS integration
- `python/helpers/memory_consolidation.py` - Auto consolidation

### Extensions
- `python/helpers/extension.py` - Extension loading
- `python/extensions/` - Extension implementations

### API
- `python/api/message.py` - Main message endpoint
- `python/api/` - 61+ endpoints

### Frontend
- `webui/index.html` - Main page
- `webui/index.js` - App initialization
- `webui/js/` - JavaScript modules

### Configuration
- `prompts/` - System prompts (~100 files)
- `agents/` - Agent profiles
- `.env` - Environment variables

---

## Important Concepts

### Message Loop Pattern
Agent loops internally, using tools and reasoning on results, until `response_tool` is used to finalize.

### Tool Abstraction
All capabilities are tools. Dynamic discovery from LLM responses. Easy to add custom tools.

### Prompt-Driven Architecture
All behavior defined through prompts, not code. 100+ modular prompt files.

### Extension Hooks
24 customization points throughout execution. Non-invasive modifications via numbered extensions.

### Memory Persistence
FAISS vector database stores semantic embeddings. Memories retrieved via semantic search. Persistent across sessions.

### Multi-Provider LLM Support
LiteLLM abstraction. Supports 20+ providers. Easy provider/model switching.

### Context Isolation
Per-conversation contexts. Hierarchical nesting for agent delegation. Isolated memory per profile.

### Async-First Design
Non-blocking operations throughout. Real-time streaming to UI. Concurrent tool execution.

---

## Troubleshooting

### Agent not responding
- Check logs in `/logs/` directory
- Verify API keys in `.env`
- Check rate limits (may be throttled)
- Restart agent: `POST /restart`

### Memory not working
- Verify embedding model is configured
- Check FAISS indices exist in `/memory/`
- Reindex knowledge: `POST /knowledge_reindex`

### Tools not executing
- Check tool is listed in prompts
- Verify tool file exists in `python/tools/`
- Check tool prompt file exists in `prompts/`
- Verify agent knows about tool

### UI not loading
- Check Flask server running: `python run_ui.py`
- Verify port 50001 is accessible
- Clear browser cache
- Check browser console for errors

### High memory usage
- Compress history: adjust history.py settings
- Clear old chats: `POST /chat_remove`
- Reduce memory indices size
- Consider chunking large documents

### LLM errors
- Verify API key is valid
- Check rate limits not exceeded
- Verify model name is correct
- Check context window availability
- See logs for detailed errors

---

## Common Development Tasks

### Add a Custom Tool

```bash
# 1. Create tool file
touch python/tools/my_tool.py

# 2. Implement Tool class
# (See python/tools/response.py for example)

# 3. Create prompt file
touch prompts/agent.system.tool.my_tool.md

# 4. Tool auto-discovered on restart
```

### Add an Extension

```bash
# 1. Create extension file
touch python/extensions/[point]/_[priority]_name.py

# 2. Implement Extension class
# (See python/extensions/message_loop_end/_90_save_chat.py for example)

# 3. Extension auto-loaded on restart
```

### Create Agent Profile

```bash
# 1. Copy example profile
cp -r agents/_example agents/my_profile

# 2. Edit _context.md

# 3. Add custom prompts in prompts/

# 4. Select in UI settings
```

### Extend Prompts

```bash
# 1. Copy default prompt
cp prompts/agent.system.main.role.md \
   agents/my_profile/prompts/agent.system.main.role.md

# 2. Edit custom version

# 3. Profile prompt overrides default
```

---

## Performance Optimization

### Reduce History Size
```python
# In models.py or history.py
MAX_HISTORY_LENGTH = 10  # Smaller = faster
```

### Enable Compression
```python
# Auto-compress history when > threshold
COMPRESS_AFTER = 3000  # tokens
```

### Optimize Memory Search
```python
# Limit memory retrieval
TOP_K_MEMORIES = 5  # Fewer = faster
```

### Rate Limiting
```yaml
# conf/model_providers.yaml
limit_requests: 10  # Per minute
limit_input: 100000  # Input tokens/min
```

### Async Operations
- Ensure async/await properly used
- Avoid blocking operations
- Use concurrent tool execution

---

## Resource Limits

### Default Limits
- **Context window:** 128K tokens (model-dependent)
- **History:** Auto-compresses after ~3000 tokens
- **Memory search:** Top 5 similar memories by default
- **Rate limit:** Per-model configuration
- **Timeout:** 300 seconds per request

### Adjusting Limits

```bash
# .env
CONTEXT_WINDOW=128000
HISTORY_COMPRESS_THRESHOLD=3000
MEMORY_TOP_K=10
REQUEST_TIMEOUT=300
```

---

## Security Checklist

- [ ] API keys in `.env`, not in code
- [ ] CSRF protection enabled
- [ ] Rate limiting configured
- [ ] Login system enabled (if multi-user)
- [ ] SSL/HTTPS enabled (production)
- [ ] Secrets masked in logs
- [ ] Regular backups scheduled
- [ ] Access logs monitored

---

## Documentation

Full documentation in `/docs/`:
- `architecture.md` - System design
- `installation.md` - Setup guide
- `usage.md` - User guide
- `development.md` - Developer guide
- `extensibility.md` - Extension guide
- `connectivity.md` - API guide
- `mcp_setup.md` - MCP integration
- `troubleshooting.md` - Fixes
- `contribution.md` - Contributing

---

## Resources

- **GitHub:** [Agent Zero Repository](https://github.com/fsendergit/agent-zero)
- **Docker:** `docker pull agent0ai/agent-zero`
- **Issues:** GitHub Issues for bug reports
- **Discussions:** GitHub Discussions for questions
- **Docs:** `/docs/` directory in repository

---

**Last Updated:** January 2026
**Version:** 0.9.7
**Status:** Production-ready

