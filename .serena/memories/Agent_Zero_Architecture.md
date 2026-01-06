# Agent Zero - Architecture Deep Dive

## System Architecture

### High-Level Flow
```
User Message → AgentContext.communicate()
  ↓
monologue() starts [OUTER LOOP: monologues]
  ├─ Extension: monologue_start
  ├─ [INNER LOOP: message iterations]
  │   ├─ Extension: message_loop_start
  │   ├─ Prepare system prompt + message history
  │   ├─ Extension: before_main_llm_call
  │   ├─ Call LLM (streaming with callbacks)
  │   ├─ Extract and execute tools from response
  │   │   └─ Add tool results to history
  │   └─ Extension: message_loop_end
  │   ├─ Repeat loop if tools returned
  │   └─ Break loop if response_tool was used
  ├─ Extension: monologue_end
  └─ Return final response to superior/user
  ↓
WebSocket stream to UI (real-time)
```

## Key Components

| Component | File | Purpose |
|-----------|------|---------|
| **Agent Class** | agent.py | Core reasoning loop |
| **AgentContext** | agent.py | Request-scoped context |
| **Tool System** | python/tools/ | Dynamic capability execution |
| **Memory** | python/helpers/memory.py | FAISS vector database |
| **History** | python/helpers/history.py | Message history management |
| **Extensions** | python/extensions/ | 24 customization points |
| **Prompts** | prompts/ | ~100 system prompts |
| **API** | python/api/ | 61+ REST endpoints |
| **Web UI** | webui/ | Vanilla JS + Alpine |

## Tool System (20+ Tools)

### Built-in Tools
- **code_execution_tool** - Python/Node/Shell execution
- **browser_agent** - Web automation
- **call_subordinate** - Agent delegation
- **search_engine** - SearXNG integration
- **document_query** - Document RAG
- **memory_add** - Add to memory
- **memory_search** - Search memory
- **memory_delete** - Delete from memory
- **scheduler** - Task scheduling
- **response** - Response finalization
- **input** - User input
- **wait** - Wait for time
- **notify** - Send notifications
- **behaviour_adjustment** - Modify behavior
- And more...

### Tool Execution Flow
```
LLM response contains tool usage
  ↓
extract_tools.py parses tool patterns
  ↓
Tool class dynamically imported from python/tools/[name].py
  ↓
Tool.before_execution() called
  ↓
Tool.execute() called (actual work)
  ↓
Tool.after_execution() called
  ↓
Result added to message history
  ↓
Message loop continues
```

## Memory System

### Three-Tier Architecture
- **FAISS Vector Database** - Semantic search over embeddings
- **4 Memory Areas:**
  - MAIN - Facts and knowledge
  - FRAGMENTS - Code snippets and examples
  - SOLUTIONS - Patterns and solutions
  - INSTRUMENTS - Custom automation scripts

### Memory Flow
```
Conversation occurs
  ↓
Extensions capture important segments
  ↓
Utility LLM extracts and consolidates
  ↓
Store in memory areas
  ↓
Embed using sentence-transformers
  ↓
Index in FAISS vector database
  ↓
On next message: Semantic search retrieves relevant memories
  ↓
Memories loaded into context for agent
```

## Extension System (24 Points)

Located in `python/extensions/` with numbered files for execution order:

### Extension Points
- **agent_init** - Agent initialization
- **message_loop_start/end** - Message loop hooks
- **before_main_llm_call** - Pre-LLM hooks
- **reasoning_stream/response_stream** - Streaming hooks
- **hist_add_before/hist_add_tool_result** - History management
- **message_loop_prompts_*** - Prompt modification
- **error_format** - Error handling
- **behaviour_adjustment** - Behavior modification
- **monologue_start/end** - Monologue hooks
- **mcp_handler** - MCP integration
- **knowledge_loading** - Knowledge base loading
- And more...

### Extension Capabilities
Extensions can modify:
- State & history
- Prompts & context
- Tool execution
- Error handling
- Behavior rules

## Prompt System

### Hierarchical Loading
1. **Agent Profile Prompts** - `agents/[profile]/prompts/`
2. **Default Prompts** - `prompts/` (fallback)
3. **Framework Prompts** - Built-in system instructions (~100 files)
4. **Main Hub** - `agent.system.main.md` connects everything

### Prompt Files (~100 total)
- `agent.system.main.md` - Central hub
- `agent.system.main.role.md` - Agent role
- `agent.system.main.communication.md` - Communication style
- `agent.system.main.solving.md` - Problem-solving approach
- `agent.system.tools.md` - Tool catalog
- `agent.system.tool.*.md` - Individual tool instructions
- `behaviour.*.md` - Behavior rules
- And more...

## API System (61+ Endpoints)

### Main Endpoints
- **POST /message** - Send message and stream response
- **POST /message_async** - Async message with attachments
- **GET/POST /settings_*** - Settings management
- **GET/POST /memory/*** - Memory API
- **POST /chat_*** - Chat management
- **POST /backup_*** - Backup/restore
- **POST /upload** - File upload
- **GET /download_work_dir_file** - File download
- **/projects/*** - Project management
- **/mcp/*** - MCP integration
- **/rfc** - RFC endpoints

## Data Persistence

### Storage Layers
- **Chat Logs** - HTML files in `/logs/` (auto-generated per session)
- **Memory** - FAISS indices in `/memory/[agent]/`
- **Knowledge Base** - `/knowledge/` for RAG
- **Instruments** - `/instruments/` for custom scripts
- **Settings** - JSON configuration files
- **Projects** - Isolated workspaces with separate memory

## Security Architecture

### Security Mechanisms
- **Secrets Management** - Credentials stored separately, not leaked to prompts
- **CSRF Protection** - Token-based CSRF defense on all state-changing requests
- **Rate Limiting** - Per-model rate limits via LiteLLM
- **Code Sandboxing** - Code execution in isolated Docker containers
- **Session Management** - Cookie-based sessions with secure defaults
- **Loopback-only Default** - Web UI restricted to localhost unless configured
- **Login System** - Optional authentication for multi-user access

## Frontend Architecture

### Technology Stack
- **Vanilla JavaScript** - No frameworks, lightweight
- **Alpine.js** - Reactive components
- **WebSocket** - Real-time streaming
- **CSS** - Modern styling with variables

### Components
- Chat interface
- Sidebar navigation
- Settings panel
- Memory viewer
- Project management
- Real-time message streaming
