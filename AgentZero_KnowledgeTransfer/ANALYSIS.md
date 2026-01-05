# Agent Zero - Comprehensive Codebase Analysis

**Analysis Date:** January 4, 2026
**Project Version:** v0.9.7 (Projects feature with isolated workspaces)
**Repository Statistics:**
- **Total Files:** 1,066 files
- **Total Tokens:** ~4.98M tokens
- **Total Characters:** ~14.66M characters
- **Primary Language:** Python (backend) + JavaScript/HTML (frontend)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Overview](#architecture-overview)
3. [Core Components](#core-components)
4. [Technology Stack](#technology-stack)
5. [Directory Structure](#directory-structure)
6. [Key Architectural Patterns](#key-architectural-patterns)
7. [Data Flow](#data-flow)
8. [Configuration System](#configuration-system)
9. [Extension System](#extension-system)
10. [Testing Structure](#testing-structure)
11. [Docker Setup](#docker-setup)
12. [API Overview](#api-overview)
13. [Frontend Architecture](#frontend-architecture)
14. [Notable Features](#notable-features)

---

## Project Overview

**Agent Zero** is a dynamic, open-source agentic AI framework designed as a personal, organic assistant that grows and learns with use. It is **not** a pre-programmed solution but a general-purpose framework that uses the computer as a tool to accomplish goals through:

- **Hierarchical multi-agent cooperation** - Agents can delegate to subordinate agents
- **Persistent memory** - Three-tier FAISS vector database for semantic knowledge retention
- **Extensible tool systems** - 20+ built-in tools + custom tool support
- **Prompt-driven architecture** - Everything is customizable via prompts (100+ system prompt files)
- **Zero hard-coded logic** - Behavior defined entirely through LLM prompts and extensions

### Key Characteristics

- Fully Dockerized with web UI and CLI interfaces
- Completely customizable and extensible (24+ extension points)
- Supports 20+ LLM providers via LiteLLM abstraction
- Real-time streaming responses to web UI
- Project-based workspace isolation (v0.9.7+)

---

## Architecture Overview

Agent Zero uses a **hierarchical multi-agent system** with these core architectural principles:

### 1. Message Loop (The Heartbeat)

The **message loop** is the core event processing engine, located in `agent.py` at the `Agent.monologue()` method (line 356). This is where all reasoning and tool execution occurs:

```
User Message → AgentContext.communicate()
  ↓
monologue() [OUTER LOOP: monologues]
  ├─ Extension: monologue_start
  ├─ [INNER LOOP: message iterations until response_tool]
  │   ├─ Extension: message_loop_start
  │   ├─ Build system prompt + message history
  │   ├─ Extension: before_main_llm_call
  │   ├─ Call LLM (streaming with callbacks)
  │   ├─ Extract tools from response (via extract_tools.py)
  │   ├─ Execute tools and get results
  │   ├─ Add tool results to history
  │   ├─ Extension: message_loop_end
  │   └─ Loop again if more reasoning needed
  ├─ Extension: monologue_end
  └─ Return final response to UI/superior agent
```

**Key Principle:** The agent loops internally, using tools and reasoning on their results, until it explicitly uses the `response_tool` to finalize and return the answer.

### 2. Tool System (Dynamic Capability Execution)

Tools are the primary mechanism for agent action execution:

- **~20 built-in tools** in `python/tools/`:
  - `code_execution_tool.py` - Python/Node/Shell code execution
  - `browser_agent.py` - Browser automation with browser-use library
  - `call_subordinate.py` - Delegate to child agents
  - `search_engine.py` - SearXNG/DuckDuckGo integration
  - `document_query.py` - Document RAG with LangChain
  - `memory_*.py` - Memory management (save, load, delete, forget)
  - `scheduler.py` - Task scheduling
  - `response.py` - Response finalization
  - `behavior_adjustment.py` - Dynamic behavior modification
  - `input.py` - User input collection
  - `wait.py` - Timed waiting
  - `notify_user.py` - Notifications

- **Dynamic discovery** - Tools are extracted from LLM responses by `extract_tools.py`
- **Tool base class** - All tools inherit from `Tool` in `python/helpers/tool.py`
- **Execution flow**:
  1. LLM response is parsed for tool mentions
  2. Tool class dynamically imported
  3. `Tool.before_execution()` called (logging, display)
  4. `Tool.execute()` called (main logic)
  5. `Tool.after_execution()` called (post-processing)
  6. Result added to message history

### 3. Memory System (Three-Tier Persistent Learning)

The memory system provides semantic understanding and persistent learning:

- **FAISS Vector Database** - Stores embeddings for semantic search
- **Four memory areas**:
  - `MAIN` - Core facts and knowledge
  - `FRAGMENTS` - Short snippets and pieces
  - `SOLUTIONS` - Patterns and solutions discovered
  - `INSTRUMENTS` - Custom automation scripts
- **Embedding Model** - Sentence-transformers for semantic embedding
- **Semantic search** - Retrieve relevant memories based on context
- **Auto-extraction** - Extensions automatically extract and consolidate memories from conversations
- **Persistence** - Memories persist across sessions in `memory/` directory

### 4. Extension System (24 Customization Hook Points)

The extension system allows non-invasive customization throughout the message loop:

- **24 extension points** located in `python/extensions/`:
  - `agent_init/` - Agent initialization
  - `message_loop_start/` - Start of each message iteration
  - `before_main_llm_call/` - Before LLM is called
  - `response_stream/` - Stream callbacks
  - `message_loop_end/` - End of each iteration
  - `monologue_start/` - Start of monologue
  - `monologue_end/` - End of monologue
  - `hist_add_tool_result/` - Tool results added to history
  - `message_loop_prompts_before/` - Before prompt assembly
  - `message_loop_prompts_after/` - After prompt assembly
  - `reasoning_stream/` - During reasoning output
  - `error_format/` - Error handling
  - `knowledge_loading/` - Knowledge base loading
  - `mcp_handler/` - MCP server integration
  - And more...

- **Priority-based execution** - Numbered files (e.g., `_10_`, `_50_`, `_90_`) execute in order
- **Agent profile overrides** - Extensions in `agents/[profile]/extensions/` override defaults
- **Dynamic loading** - Extensions loaded at runtime, no core code modification needed

### 5. Prompt System (Hierarchical, Fallback-Based)

Agent behavior is entirely defined through prompts (~100 prompt files):

- **Hierarchical loading**:
  1. Agent profile prompts: `agents/[profile]/prompts/`
  2. Default prompts: `prompts/` (fallback)
  3. Framework prompts: Built-in system instructions

- **Main hub** - `agent.system.main.md` connects all prompts
- **Prompt categories**:
  - `agent.system.main.*.md` - Main agent instructions (role, communication, solving, etc.)
  - `agent.system.tool.*.md` - Per-tool instructions
  - `agent.system.behaviour.md` - Behavior rules and guidelines
  - `agent.system.memories.md` - Memory management instructions
  - `fw.*.md` - Framework prompts (errors, interventions, tool results)
  - `memory.*.md` - Memory operation prompts
  - And many more...

### 6. Model Integration (LiteLLM Abstraction)

LLM integration is abstracted through LiteLLM to support multiple providers:

- **ModelConfig dataclass** - Defines model configuration
- **Four model types**:
  - **Chat Model** - Main reasoning LLM (e.g., Claude, GPT-4, OpenRouter models)
  - **Utility Model** - Summarization and consolidation
  - **Embedding Model** - Sentence-transformers for memory embeddings
  - **Browser Model** - Specialized model for browser automation
- **20+ supported providers**:
  - OpenAI, Anthropic, OpenRouter, Azure, local models
  - Venice.ai, GitHub Copilot, and more
- **Streaming support** - Real-time callbacks for UI updates
- **Rate limiting** - Per-model rate limits via RateLimiter helper
- **Token counting** - Approximate token counting via `approximate_tokens()`

---

## Core Components

### 1. Agent Class (`agent.py`)

**File:** `/Users/johnmbwambo/ai_projects/agentzero/agent.py` (922 lines)

**Key Components:**

```python
class AgentContext:
    """Global context for an agent conversation"""
    - _contexts: dict[str, AgentContext]  # All active contexts
    - id: str  # Unique context ID
    - config: AgentConfig  # Agent configuration
    - log: Log  # Logging system
    - agent0: Agent  # Main agent instance
    - type: AgentContextType  # USER, TASK, or BACKGROUND

class Agent:
    """Core agent class implementing the reasoning loop"""
    - config: AgentConfig  # Agent settings
    - context: AgentContext  # Associated context
    - profile: str  # Agent profile name
    - hist: list[BaseMessage]  # Message history
    - mono_count: int  # Monologue iteration counter
    - mono_responses: list  # Collected responses

    async def monologue(self):
        """Main message loop (line 356) - Core reasoning engine"""
        # 1. Initialize extensions
        # 2. Load system prompt + history
        # 3. Call LLM with streaming
        # 4. Extract and execute tools
        # 5. Add results to history
        # 6. Loop until response_tool is used
        # 7. Return final response
```

**Key Methods:**
- `monologue()` - Main reasoning loop
- `hist_add_message()` - Add message to history
- `hist_add_tool_result()` - Record tool execution result
- `communicate()` - Public API for sending messages
- `get_llm_config()` - Get current model configuration

### 2. Configuration System (`models.py`)

**File:** `/Users/johnmbwambo/ai_projects/agentzero/models.py` (919 lines)

**Key Components:**

```python
@dataclass
class ModelConfig:
    """Configuration for a model"""
    type: ModelType  # CHAT or EMBEDDING
    provider: str  # e.g., "openai", "anthropic", "openrouter"
    name: str  # Model name
    api_base: str  # Optional custom API endpoint
    ctx_length: int  # Context window size
    limit_requests: int  # Request rate limit
    limit_input: int  # Input token limit
    limit_output: int  # Output token limit
    vision: bool  # Supports vision/images
    kwargs: dict  # Provider-specific kwargs

class ChatGenerationResult:
    """Processes streaming chat responses"""
    - response: str  # Final response text
    - reasoning: str  # LLM reasoning (if available)
    - thinking: bool  # Whether in thinking tags
    - native_reasoning: bool  # Native reasoning support
```

**Key Functions:**
- `turn_off_logging()` - Suppress debug logging
- `build_kwargs()` - Construct provider-specific kwargs
- `_process_thinking_chunk()` - Parse thinking tags
- LiteLLM integration for completion and embedding calls

### 3. Web Server (`run_ui.py`)

**File:** `/Users/johnmbwambo/ai_projects/agentzero/run_ui.py` (285 lines)

**Key Features:**
- Flask async server on port 50001
- CSRF protection tokens
- 61+ API endpoints
- WebSocket streaming for real-time responses
- Login system (optional)
- Session management

### 4. History Management (`python/helpers/history.py`)

**Purpose:** Manage message history with automatic compression

**Key Features:**
- Sliding window history (keeps last N messages)
- Bulk summarization when history grows
- Message compression via utility LLM
- Role-aware (system, user, assistant, tool)
- Context window management

### 5. Tool Extraction (`python/helpers/extract_tools.py`)

**Purpose:** Parse LLM responses and discover tools

**Key Functions:**
- `extract_tool_pattern()` - Parse tool usage from response
- `load_classes_from_folder()` - Dynamically load tool classes
- `get_toolname_by_method()` - Map method names to tools
- Regex-based tool discovery

### 6. Extension Loading (`python/helpers/extension.py`)

**Purpose:** Load and execute extension hooks

**Key Functions:**
- `call_extensions(extension_point, agent)` - Execute extensions at a point
- `_get_extensions(folder)` - Load extension classes from folder
- Priority-based execution (file name prefix determines order)
- Caching of loaded extensions

---

## Technology Stack

### Backend Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Core Framework** | Python 3.10+ | Agent implementation |
| **Web Server** | Flask 3.0.3 + async | HTTP API server |
| **LLM Integration** | LiteLLM | Multi-provider LLM abstraction |
| **Embeddings** | Sentence-Transformers 3.0.1 | Semantic embeddings for memory |
| **Vector Database** | FAISS 1.11.0 | Vector similarity search |
| **Document Processing** | LangChain 0.3.x + Unstructured | RAG and document parsing |
| **Browser Automation** | Browser-use 0.5.11 + Playwright 1.52.0 | Web interaction |
| **Code Execution** | Code execution sandbox | Python/Node/Shell code running |
| **Search** | SearXNG, DuckDuckGo | Web search integration |
| **Scheduling** | crontab 1.0.1 | Task scheduling |
| **Shell Integration** | Paramiko 3.5.0 | SSH support for remote execution |
| **MCP Support** | FastMCP 2.3.4 + MCP 1.13.1 | Model Context Protocol |
| **LLMs** | OpenAI, Anthropic, OpenRouter, etc. | 20+ provider support via LiteLLM |

### Frontend Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Framework** | Vanilla JavaScript + Alpine.js | Reactive UI |
| **Styling** | CSS3 + Responsive Design | UI styling |
| **Markdown** | Marked.js + KaTeX | Message rendering |
| **Code Highlighting** | Ace Editor | Code display |
| **Speech** | Web Speech API + Whisper | Text-to-speech and speech-to-text |
| **File Management** | Fetch API | File upload/download |
| **Real-time Updates** | WebSocket | Live streaming |
| **Storage** | LocalStorage | Client-side persistence |

### DevOps & Deployment

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Containerization** | Docker + Docker Compose | Container orchestration |
| **Base Environment** | Ubuntu-based | Container base image |
| **Package Management** | pip | Python dependencies |
| **Web Server** | Nginx | Reverse proxy (in Docker) |
| **Process Supervisor** | Supervisor | Process management (in Docker) |
| **Port Mapping** | Port 50001 → 80 (Docker) | External access |

### Dependencies (Top Level)

```
Core:
- flask[async]==3.0.3
- langchain-core==0.3.49
- langchain-community==0.3.19
- sentence-transformers==3.0.1
- faiss-cpu==1.11.0

LLM:
- litellm (implicit, via langchain)
- openai-whisper==20240930

Browser & Automation:
- browser-use==0.5.11
- playwright==1.52.0
- selenium-based browser automation

Documents & Search:
- langchain-unstructured[all-docs]==0.1.6
- unstructured[all-docs]==0.16.23
- newspaper3k==0.2.8
- duckduckgo-search==6.1.12

Infrastructure:
- docker==7.1.0
- paramiko==3.5.0 (SSH)
- GitPython==3.1.43 (Git integration)

Utilities:
- pydantic==2.11.7
- python-dotenv==1.1.0
- tiktoken==0.8.0
- pypdf==6.0.0
- pymupdf==1.25.3
```

---

## Directory Structure

```
/agentzero/
├── agent.py                    # Core Agent class, message loop (922 lines)
├── models.py                   # LLM integration & ModelConfig (919 lines)
├── initialize.py               # Setup wizard
├── run_ui.py                   # Flask web server (285 lines)
├── run_tunnel.py               # Remote tunnel service
├── requirements.txt            # Python dependencies
│
├── /python/                    # Backend codebase (100+ files)
│   ├── __init__.py
│   ├── /api/                   # 61+ Flask API endpoints
│   │   ├── message.py          # Main message processing API
│   │   ├── chat_*.py           # Chat management (create, load, reset, etc.)
│   │   ├── settings_*.py       # Settings management endpoints
│   │   ├── memory_*.py         # Memory operations
│   │   ├── backup_*.py         # Backup/restore functionality
│   │   ├── projects.py         # Project management
│   │   ├── mcp_server*.py      # MCP server management
│   │   ├── scheduler_*.py      # Task scheduling
│   │   ├── notification_*.py   # Notifications
│   │   └── ... (61+ total)
│   │
│   ├── /tools/                 # ~20 built-in tools
│   │   ├── code_execution_tool.py    # Python/Node/Shell execution
│   │   ├── browser_agent.py          # Browser automation
│   │   ├── call_subordinate.py       # Agent delegation
│   │   ├── search_engine.py          # Web search
│   │   ├── document_query.py         # Document RAG
│   │   ├── memory_*.py               # Memory management
│   │   ├── scheduler.py              # Scheduled tasks
│   │   ├── behaviour_adjustment.py   # Behavior modification
│   │   ├── response.py               # Response finalization
│   │   ├── input.py                  # User input
│   │   ├── wait.py                   # Timed waiting
│   │   ├── notify_user.py            # Notifications
│   │   ├── a2a_chat.py               # Agent-to-agent chat
│   │   ├── vision_load.py            # Vision capabilities
│   │   └── unknown.py                # Unknown tool handler
│   │
│   ├── /extensions/            # 24+ extension points
│   │   ├── agent_init/
│   │   ├── message_loop_start/
│   │   ├── message_loop_end/
│   │   ├── monologue_start/
│   │   ├── monologue_end/
│   │   ├── before_main_llm_call/
│   │   ├── response_stream/
│   │   ├── hist_add_before/
│   │   ├── hist_add_tool_result/
│   │   ├── message_loop_prompts_before/
│   │   ├── message_loop_prompts_after/
│   │   ├── reasoning_stream/
│   │   ├── error_format/
│   │   ├── knowledge_loading/
│   │   ├── mcp_handler/
│   │   └── ... (more)
│   │
│   └── /helpers/               # ~73 utility modules
│       ├── call_llm.py         # LLM interaction wrapper
│       ├── memory.py           # FAISS vector DB integration
│       ├── history.py          # Message history management
│       ├── tool.py             # Tool base class
│       ├── settings.py         # Settings persistence
│       ├── dotenv.py           # Environment configuration
│       ├── extract_tools.py    # Tool discovery
│       ├── extension.py        # Extension loading
│       ├── mcp_handler.py      # MCP server/client
│       ├── knowledge_import.py # Knowledge base
│       ├── browser.py          # Browser utilities
│       ├── browser_use.py      # Browser-use library
│       ├── browser_use_monkeypatch.py
│       ├── shell_local.py      # Local shell execution
│       ├── shell_ssh.py        # SSH remote execution
│       ├── files.py            # File operations
│       ├── context.py          # Request context
│       ├── log.py              # Logging system
│       ├── notification.py     # Notification manager
│       ├── memory_consolidation.py
│       ├── rate_limiter.py     # Rate limiting
│       ├── vector_db.py        # Vector DB utilities
│       ├── task_scheduler.py   # Task scheduling
│       ├── tokens.py           # Token counting
│       ├── rfc.py              # RFC protocol
│       ├── mcp_server.py       # MCP server impl
│       ├── projects.py         # Project management
│       ├── backup.py           # Backup system
│       ├── email_client.py     # Email integration
│       ├── git.py              # Git operations
│       └── ... (more)
│
├── /webui/                     # Frontend (vanilla JS + Alpine.js)
│   ├── index.html              # Main page
│   ├── index.js                # App initialization
│   ├── index.css               # Main styles
│   ├── login.html              # Login page
│   ├── login.css               # Login styles
│   │
│   ├── /components/            # UI components
│   │   ├── chat/               # Chat message display
│   │   ├── sidebar/            # Left sidebar
│   │   ├── toolbar/            # Top toolbar
│   │   ├── modals/             # Modal dialogs
│   │   ├── settings/           # Settings panels
│   │   ├── attachments/        # File attachments
│   │   └── ... (more)
│   │
│   ├── /js/                    # JavaScript modules
│   │   ├── api.js              # API client
│   │   ├── messages.js         # Message handling
│   │   ├── settings.js         # Settings management
│   │   ├── components.js       # Component utilities
│   │   ├── modals.js           # Modal handling
│   │   ├── shortcuts.js        # Keyboard shortcuts
│   │   ├── AlpineStore.js      # Alpine.js store
│   │   ├── speech_browser.js   # TTS/STT
│   │   ├── scheduler.js        # Scheduler UI
│   │   ├── device.js           # Device detection
│   │   └── ... (more)
│   │
│   ├── /css/                   # Stylesheets
│   │   ├── messages.css
│   │   ├── buttons.css
│   │   ├── settings.css
│   │   ├── notification.css
│   │   ├── modals.css
│   │   └── ... (more)
│   │
│   └── /public/                # Static assets
│       └── /vendor/            # Third-party libraries
│
├── /prompts/                   # ~100 system prompt files
│   ├── agent.system.main.md              # Central hub
│   ├── agent.system.main.role.md         # Agent identity
│   ├── agent.system.main.communication.md
│   ├── agent.system.main.solving.md
│   ├── agent.system.main.environment.md
│   ├── agent.system.tools.md             # Tool catalog
│   ├── agent.system.tool.*.md            # Per-tool instructions
│   ├── agent.system.behaviour.md
│   ├── agent.system.memories.md
│   ├── agent.system.projects.md
│   ├── fw.*.md                           # Framework prompts
│   ├── memory.*.md                       # Memory operation prompts
│   ├── behaviour.*.md                    # Behavior rules
│   ├── browser_agent.system.md
│   └── ... (more)
│
├── /agents/                    # Agent profiles (configurations)
│   ├── default/                # Default configuration
│   │   └── _context.md
│   ├── developer/              # Developer assistant
│   │   ├── _context.md
│   │   └── prompts/
│   ├── researcher/             # Research assistant
│   │   ├── _context.md
│   │   └── prompts/
│   ├── hacker/                 # Security assistant
│   │   ├── _context.md
│   │   └── prompts/
│   ├── agent0/                 # Custom profile
│   │   ├── _context.md
│   │   └── prompts/
│   └── _example/               # Template for new profiles
│       ├── extensions/
│       ├── prompts/
│       └── tools/
│
├── /memory/                    # Persistent memory storage
│   ├── .gitkeep
│   └── /[agent_profile]/       # Per-agent memory
│       ├── index.faiss         # Vector index
│       └── ... (FAISS data)
│
├── /knowledge/                 # Knowledge base for RAG
│   ├── custom/                 # User-provided knowledge
│   │   └── main/
│   │   └── solutions/
│   └── default/                # Framework knowledge
│       ├── main/
│       │   └── about/
│       └── solutions/
│
├── /instruments/               # Custom automation scripts
│   ├── custom/                 # User-created tools
│   └── default/                # Framework tools
│       ├── yt_download/
│       └── ... (more)
│
├── /logs/                      # HTML chat logs
│   └── [timestamp].html        # Chat session logs
│
├── /tests/                     # Test suite
│   ├── test_*.py
│   ├── *_test.py
│   ├── rate_limiter_test.py
│   ├── email_parser_test.py
│   └── ... (5+ test files)
│
├── /docker/                    # Docker configuration
│   ├── /base/                  # Base image
│   │   ├── Dockerfile
│   │   ├── build.txt
│   │   └── /fs/                # Filesystem overlays
│   │       ├── /etc/
│   │       └── /ins/           # Installation scripts
│   │
│   └── /run/                   # Runtime container
│       ├── Dockerfile
│       ├── docker-compose.yml
│       └── /fs/                # Container filesystem
│           ├── /etc/
│           ├── /exe/           # Executables
│           ├── /ins/           # Install scripts
│           └── /per/           # Persistent config
│
├── /docs/                      # Documentation
│   ├── README.md
│   ├── architecture.md
│   ├── installation.md
│   ├── usage.md
│   ├── development.md
│   ├── extensibility.md
│   ├── connectivity.md
│   ├── mcp_setup.md
│   ├── troubleshooting.md
│   ├── designs/                # Design specifications
│   └── res/                    # Resources (images, videos)
│
├── /conf/                      # Configuration
│   ├── model_providers.yaml    # Available LLM providers
│   └── projects.default.gitignore
│
├── /lib/                       # Client-side libraries
│   └── /browser/               # Browser utilities
│       ├── click.js
│       ├── extract_dom.js
│       └── init_override.js
│
├── .github/
│   └── FUNDING.yml
│
├── README.md
├── LICENSE
├── requirements.txt
└── CLAUDE.md                   # Project guidelines

```

---

## Key Architectural Patterns

### 1. Message Loop Pattern

The **message loop** is the primary execution pattern:
- Agents reason in a loop until they explicitly respond with `response_tool`
- Each iteration: LLM call → tool extraction → tool execution → result addition
- Automatic history management prevents context overflow
- Extensions can intercept at 20+ points

### 2. Tool Abstraction Pattern

All capabilities are modeled as tools:
- Tool base class defines interface: `execute()`, `before_execution()`, `after_execution()`
- Dynamic discovery from responses (regex-based parsing)
- Result collection for further reasoning
- Promotes composability and extensibility

### 3. Extension Hook Pattern

Non-invasive customization through numbered extension points:
- Extensions inherit from `Extension` base class
- File naming determines execution order (`_10_`, `_50_`, `_90_`)
- Can modify state, history, prompts without changing core
- Both framework and agent-profile-specific extensions
- Async-first design enables non-blocking operations

### 4. Context Management Pattern

Request-scoped context object provides isolation:
- `AgentContext` contains all state for a conversation
- Multiple contexts can coexist
- Nested hierarchies for agent delegation
- Shared access to memory, logs, settings

### 5. Prompt-Driven Configuration

All behavior defined through prompts:
- ~100 prompt files define agent personality and capabilities
- Hierarchical loading (agent profile → defaults → framework)
- No hard-coded business logic
- Tool instructions embedded in prompts
- Behavior adjustable without code changes

### 6. Vector Memory Pattern

FAISS-backed semantic memory:
- Persistent across sessions
- Automatic memory extraction and consolidation
- Semantic search for context-aware retrieval
- Four memory areas (MAIN, FRAGMENTS, SOLUTIONS, INSTRUMENTS)

### 7. Streaming Response Pattern

Real-time streaming to frontend:
- WebSocket-based communication
- LLM responses streamed token-by-token
- Callbacks for UI updates during reasoning
- Support for thinking/reasoning tokens

### 8. Rate Limiting Pattern

Per-model rate limiting:
- `RateLimiter` class enforces per-provider limits
- Configurable via ModelConfig
- Prevents API abuse and quota issues
- LiteLLM integration handles multiple providers

---

## Data Flow

### Message Processing Flow

```
1. User Input (UI or API)
   └─> POST /message or /message_async
       └─> AgentContext.communicate()

2. Context Initialization
   └─> AgentContext.__init__()
   └─> Agent.__init__()
   └─> Extension: agent_init

3. Message Loop (Agent.monologue())

   ITERATION LOOP:
   ├─> Extension: monologue_start
   ├─> Extension: message_loop_start
   │
   ├─> Prepare System Prompt
   │   ├─> Load main prompts (agent.system.main.md)
   │   ├─> Load tool prompts (agent.system.tool.*.md)
   │   ├─> Load behavior prompts
   │   └─> Extension: message_loop_prompts_before
   │
   ├─> Load Message History
   │   ├─> Apply compression if needed
   │   ├─> Load relevant memories (semantic search)
   │   └─> Extension: message_loop_prompts_after
   │
   ├─> Extension: before_main_llm_call
   │
   ├─> Call LLM (Streaming)
   │   ├─> Use ModelConfig for provider settings
   │   ├─> Stream tokens to callbacks
   │   ├─> Extension: reasoning_stream_* (during streaming)
   │   ├─> Extension: response_stream_* (during streaming)
   │   └─> Collect full response
   │
   ├─> Extract Tools from Response
   │   ├─> Regex-based tool pattern matching
   │   ├─> Dynamic tool class loading
   │   └─> Parse tool arguments (JSON/dirty JSON)
   │
   ├─> Execute Tool(s)
   │   ├─> Tool.before_execution()
   │   ├─> Tool.execute() (actual work)
   │   ├─> Tool.after_execution()
   │   └─> Collect response
   │
   ├─> Add Tool Result to History
   │   ├─> Extension: hist_add_before (modify before adding)
   │   ├─> hist_add_tool_result()
   │   ├─> Extension: hist_add_tool_result (post-add)
   │   └─> Update context.log
   │
   ├─> Check for Response Tool
   │   ├─> If response_tool used → break loop
   │   └─> Else → continue loop (goto ITERATION LOOP)
   │
   └─> Extension: message_loop_end

   AFTER LOOP:
   ├─> Extension: monologue_end
   ├─> Auto-save memory fragments
   ├─> Auto-save memory solutions
   └─> Return final response

4. Response Streaming to UI
   └─> WebSocket stream
   └─> Real-time updates to chat UI

5. History Persistence
   └─> Extension: message_loop_end → _90_save_chat.py
   └─> Save to chat JSON file
   └─> Auto-generate HTML log
```

### Memory System Flow

```
Conversation Occurs
  └─> Agent executes tools and reasons

Extensions Extract Important Information
  └─> monologue_end/_50_memorize_fragments.py
  └─> monologue_end/_51_memorize_solutions.py

Utility LLM Consolidates
  └─> Call utility_model with consolidation prompt
  └─> Extract key insights
  └─> Format as memory entries

Store in Memory Areas
  └─> Memory.save_memory()
  └─> Choose area (MAIN, FRAGMENTS, SOLUTIONS, INSTRUMENTS)
  └─> Add metadata (timestamp, source, etc.)

Embed Using Sentence-Transformers
  └─> Embedding model generates vectors
  └─> Store vectors in FAISS index

Index in FAISS
  └─> Add to appropriate memory area index
  └─> Persist to disk (memory/[subdir]/)

On Next Message
  └─> Semantic search retrieves relevant memories
  └─> extension: message_loop_prompts_after/_50_recall_memories.py
  └─> Memories injected into system prompt
  └─> Agent uses memories in reasoning
```

### Tool Execution Flow

```
LLM Response Contains Tool Usage
  └─> "I'll use code_execution_tool to run Python"
  └─> Tool: code_execution_tool
  └─> method: "execute_python"
  └─> args: {"code": "print('hello')"}

Extract Tools (extract_tools.py)
  └─> Parse response with regex
  └─> Identify tool name and arguments
  └─> Handle JSON/dirty JSON parsing
  └─> Return list of ToolCall objects

Load Tool Class Dynamically
  └─> Import from python/tools/[name].py
  └─> Instantiate Tool subclass
  └─> Pass agent, args, message, loop_data

Tool.before_execution()
  └─> Log tool usage to UI
  └─> Display arguments
  └─> Initialize log entry

Tool.execute()
  └─> Perform actual work
  └─> Return Response object
  └─> Response contains: message, break_loop, additional

Tool.after_execution()
  └─> Add result to message history
  └─> Update log with response
  └─> Display result to user

Add to Message History
  └─> hist_add_tool_result()
  └─> Create tool result message
  └─> Add to agent.hist list
  └─> Will be included in next LLM call
```

---

## Configuration System

### Environment Variables (.env)

```bash
# API Keys and Credentials
OPENROUTER_API_KEY=...      # Default LLM provider
OPENAI_API_KEY=...          # OpenAI models
ANTHROPIC_API_KEY=...       # Claude models
GOOGLE_API_KEY=...          # Google models

# Server Settings
HOST=localhost              # Default: localhost
PORT=50001                  # Default: 50001
SSL=false                   # Enable HTTPS (needs cert/key)
SECRET_KEY=...              # Flask secret key
BASIC_AUTH_USERNAME=...     # Optional basic auth
BASIC_AUTH_PASSWORD=...

# Model Selection
CHAT_MODEL_PROVIDER=openrouter
CHAT_MODEL_NAME=...
UTILITY_MODEL_PROVIDER=...
UTILITY_MODEL_NAME=...
EMBEDDING_MODEL_PROVIDER=...
EMBEDDING_MODEL_NAME=...

# Features
ENABLE_RFC=true             # Remote File Collaboration
ENABLE_MCP=true             # Model Context Protocol
ENABLE_VISION=false         # Vision model support
ENABLE_LOGIN=false          # Require authentication

# Paths
WORK_DIR=./work             # Working directory
MEMORY_DIR=./memory         # Memory storage
KNOWLEDGE_DIR=./knowledge   # Knowledge base
INSTRUMENTS_DIR=./instruments
LOGS_DIR=./logs
```

### Model Configuration (`conf/model_providers.yaml`)

Defines available LLM providers and their settings:
- Provider credentials
- Default models
- Model-specific settings (temperature, top_p, etc.)
- API endpoints
- Rate limits

### Agent Profiles (`agents/[profile]/`)

Each profile can customize:
- Prompts (in `prompts/` subfolder)
- Tools (enable/disable)
- Memory location
- Extensions
- Settings defaults

**Built-in profiles:**
- `default` - General-purpose agent
- `developer` - Developer assistant with code focus
- `researcher` - Research assistant with knowledge focus
- `hacker` - Security/hacking profile
- `agent0` - Custom configuration example
- `_example` - Template for new profiles

### Settings Management (`python/helpers/settings.py`)

Persistent settings storage:
- Per-profile settings
- Per-agent settings
- User preferences
- API configuration
- Feature flags

Settings are stored in `.env` and loaded at runtime.

---

## Extension System

### 24 Extension Points

Extensions allow customization without modifying core code:

| Extension Point | Purpose | Key Use Cases |
|---|---|---|
| `agent_init` | Agent initialization | Load initial messages, profile settings |
| `message_loop_start` | Before each message iteration | Reset counters, prepare state |
| `message_loop_end` | After each iteration | Save chat, organize history |
| `monologue_start` | Before monologue begins | Initialize memory, rename chat |
| `monologue_end` | After monologue completes | Save memories, finalize response |
| `before_main_llm_call` | Before LLM is called | Log for streaming, modify prompt |
| `reasoning_stream` | During reasoning output | Process thinking tokens |
| `response_stream` | During response output | Stream to UI |
| `message_loop_prompts_before` | Before prompt assembly | Prepare prompt components |
| `message_loop_prompts_after` | After prompt assembly | Inject memories, datetime, info |
| `hist_add_before` | Before adding to history | Mask sensitive content |
| `hist_add_tool_result` | After tool result added | Save tool call files |
| `error_format` | Error handling | Mask errors, custom formatting |
| `knowledge_loading` | Loading knowledge base | Custom knowledge injection |
| `mcp_handler` | MCP protocol handling | MCP server integration |
| `behaviour_adjustment` | Behavior modification | Dynamic behavior changes |
| And more... | | |

### Creating an Extension

```python
# File: python/extensions/message_loop_end/_50_my_extension.py
from python.helpers.extension import Extension
from agent import LoopData

class MyExtension(Extension):
    async def execute(self, loop_data: LoopData, **kwargs):
        # Modify loop_data or perform side effects
        loop_data.prompt += "\n\nAdditional instruction"
        # Return nothing (modifies by reference)
```

**Key Principles:**
1. File naming: `_[priority]_[name].py` (10=early, 90=late)
2. Inherit from `Extension` base class
3. Implement async `execute()` method
4. Extensions execute in order by priority
5. Agent-profile extensions override defaults

---

## Testing Structure

**Test Directory:** `/Users/johnmbwambo/ai_projects/agentzero/tests/`

**Test Files:**
- `rate_limiter_test.py` - Rate limiting functionality
- `email_parser_test.py` - Email parsing utilities
- `chunk_parser_test.py` - Chunk parsing logic
- `test_fasta2a_client.py` - FASTA-to-ASCII client
- `test_file_tree_visualize.py` - File tree visualization

**Running Tests:**

```bash
# Run all tests
python -m pytest tests/

# Run specific test file
python -m pytest tests/rate_limiter_test.py

# Verbose output
python -m pytest tests/ -v

# Specific test function
python -m pytest tests/rate_limiter_test.py::test_function_name
```

**Test Framework:** pytest

**Coverage Areas:**
- Rate limiting logic
- Email parsing
- Chunk parsing
- Client libraries
- File utilities

---

## Docker Setup

### Architecture

Agent Zero uses a **two-stage Docker build**:

1. **Base Image** (`docker/base/Dockerfile`)
   - Ubuntu base
   - System dependencies
   - Python installation
   - SearXNG installation (search engine)
   - SSH setup

2. **Runtime Image** (`docker/run/Dockerfile`)
   - Builds on base image
   - Copies Agent Zero code
   - Installs Python dependencies
   - Sets up Nginx, Supervisor
   - Configures entrypoint

### Docker Compose

File: `/Users/johnmbwambo/ai_projects/agentzero/docker/run/docker-compose.yml`

**Services:**
- Agent Zero (Flask app on port 80)
- Nginx (reverse proxy)
- SearXNG (search engine)
- Supervisor (process management)

### Running with Docker

```bash
# Pull pre-built image
docker pull agent0ai/agent-zero

# Run container
docker run -p 50001:80 agent0ai/agent-zero

# Access on http://localhost:50001
```

### Docker Volumes

```yaml
volumes:
  - ./work:/app/work              # Working directory
  - ./memory:/app/memory          # Memory persistence
  - ./knowledge:/app/knowledge    # Knowledge base
  - ./logs:/app/logs              # Chat logs
```

### Docker Environment

Container sets up:
- Python virtual environment
- Node.js (for code execution)
- Browser automation (Playwright)
- SSH server (optional, for remote execution)
- Systemd/Supervisor (process management)

---

## API Overview

### Main API Endpoints

Agent Zero provides 61+ REST API endpoints:

#### Message Processing
- `POST /message` - Send message and stream response
- `POST /message_async` - Async message with attachments
- `POST /poll` - Poll for response status
- `POST /pause` - Pause agent execution
- `POST /nudge` - Send nudge/interrupt signal
- `POST /terminate_chat` - Kill current operation

#### Chat Management
- `POST /chat_create` - Create new chat
- `POST /chat_load` - Load existing chat
- `POST /chat_remove` - Delete chat
- `POST /chat_reset` - Reset chat history
- `POST /chat_export` - Export chat as JSON/HTML
- `GET /chat_files_path_get` - List chat files

#### Settings
- `GET /settings_get` - Get all settings
- `POST /settings_set` - Update settings
- `GET /ctx_window_get` - Get context window info

#### Memory System
- `POST /memory_save` - Save to memory
- `POST /memory_load` - Query memory
- `POST /memory_delete` - Delete memory entry
- `GET /memory_dashboard` - Memory statistics
- `POST /memory_forget` - Clear memory area

#### Knowledge Base
- `POST /import_knowledge` - Import knowledge files
- `POST /knowledge_reindex` - Reindex knowledge base
- `GET /knowledge_path_get` - Get knowledge path

#### Files & Attachments
- `POST /upload` - Upload files
- `POST /upload_work_dir_files` - Upload to work directory
- `GET /download_work_dir_file` - Download file
- `GET /get_work_dir_files` - List work directory
- `POST /delete_work_dir_file` - Delete file
- `GET /file_info` - Get file information

#### Backup & Restore
- `POST /backup_create` - Create backup
- `POST /backup_restore` - Restore from backup
- `POST /backup_preview_grouped` - Preview backup
- `GET /backup_get_defaults` - Get backup defaults

#### Scheduling
- `POST /scheduler_task_create` - Create scheduled task
- `POST /scheduler_task_update` - Update task
- `POST /scheduler_task_delete` - Delete task
- `GET /scheduler_tasks_list` - List all tasks
- `POST /scheduler_task_run` - Run task immediately
- `POST /scheduler_tick` - Internal scheduler tick

#### Notifications
- `POST /notification_create` - Create notification
- `GET /notifications_history` - Get notification history
- `POST /notifications_clear` - Clear notifications
- `POST /notifications_mark_read` - Mark as read

#### Project Management
- `POST /projects` - Project operations
  - create, load, remove, list, update

#### MCP (Model Context Protocol)
- `GET /mcp_servers_status` - Get MCP server status
- `POST /mcp_servers_apply` - Apply MCP configuration
- `GET /mcp_server_get_detail` - Get server details
- `GET /mcp_server_get_log` - Get server logs

#### Audio/Speech
- `POST /synthesize` - Text-to-speech
- `POST /transcribe` - Speech-to-text (Whisper)

#### Other
- `POST /rfc` - Remote File Collaboration
- `POST /restart` - Restart agent
- `GET /health` - Health check
- `GET /csrf_token` - Get CSRF token
- `POST /tunnel` - Tunnel service
- `GET /image_get` - Get image
- `GET /history_get` - Get chat history
- `GET /api_log_get` - Get API logs

### API Request Format

```python
# HTTP POST /message
{
    "message": "user message text",
    "attachments": [
        {
            "type": "file",
            "path": "/path/to/file"
        },
        {
            "type": "image",
            "data": "base64_encoded_image"
        }
    ]
}
```

### API Response Format

```python
# Streaming response (WebSocket)
{
    "type": "message_start",
    "data": {...}
}

{
    "type": "text",
    "data": "response text chunk"
}

{
    "type": "tool_call",
    "data": {
        "tool_name": "code_execution_tool",
        "args": {...}
    }
}

{
    "type": "message_end",
    "data": {...}
}
```

---

## Frontend Architecture

### Technology Stack

- **Framework:** Vanilla JavaScript + Alpine.js
- **UI Components:** Custom components (chat, sidebar, modals)
- **Styling:** CSS3 with responsive design
- **Real-time Updates:** WebSocket for streaming responses
- **Markdown Rendering:** Marked.js + KaTeX
- **Code Display:** Ace Editor
- **Speech:** Web Speech API + OpenAI Whisper
- **Icons:** Icon fonts + SVG

### Main Pages

#### 1. Chat Interface (`index.html`)

Main application interface with:
- **Left Sidebar** - Chat list, quick actions, tasks
- **Center Panel** - Chat messages with markdown rendering
- **Top Toolbar** - Settings, audio controls, profile
- **Input Area** - Message input with attachments
- **Real-time Streaming** - WebSocket updates

#### 2. Login Page (`login.html`)

Authentication interface (optional):
- Username/password form
- Session management
- CSRF token handling

### Key Components

| Component | Purpose |
|---|---|
| **Chat Display** | Render messages with markdown, code syntax highlighting, math |
| **Message Input** | Text input with file/image attachments, voice recording |
| **Sidebar** | Chat history, quick actions, task list, notifications |
| **Settings Panel** | Agent configuration, model selection, API keys |
| **Modals** | Dialogs for confirm, file browser, settings, etc. |
| **Toolbar** | Top navigation with audio controls, profile, menu |
| **Notifications** | Toast notifications, notification history |
| **Attachments** | File/image preview and management |
| **Scheduler** | Task scheduling UI with date/time picker |

### State Management

Uses **Alpine.js** for reactive data binding:

```javascript
// AlpineStore.js - Shared application state
const store = {
    messages: [],
    settings: {},
    chats: [],
    notifications: [],
    tasks: [],
    // ... more state
}

// Components update and react to state changes
<div x-data="{ count: 0 }">
    <button x-on:click="count++">{{ count }}</button>
</div>
```

### API Communication

**api.js** - Centralized API client:

```javascript
async function sendMessage(message) {
    const response = await fetch('/message', {
        method: 'POST',
        body: JSON.stringify({ message })
    });
    // Stream response via WebSocket
}

async function getSetting(key) {
    return await fetch(`/settings_get?key=${key}`)
        .then(r => r.json());
}
```

### Real-time Updates

WebSocket streaming for:
- Message tokens (as they're generated)
- Tool execution (progress updates)
- Reasoning tokens (if supported)
- Chat status updates
- Notifications

---

## Notable Features

### 1. Hierarchical Multi-Agent System

Agents can create and delegate to subordinate agents:
- Call tool: `call_subordinate`
- Create new agent context with isolated state
- Inherit knowledge and memory
- Return results to parent

### 2. Persistent Memory with Semantic Search

- FAISS vector database stores embeddings
- Four memory areas: MAIN, FRAGMENTS, SOLUTIONS, INSTRUMENTS
- Automatic memory extraction from conversations
- Semantic search retrieves relevant context
- Memories persist across sessions

### 3. Dynamic Tool System

- ~20 built-in tools covering common needs
- Easy to add custom tools
- Tools discovered dynamically from LLM responses
- Tool instructions embedded in system prompts

### 4. Extensive Customization

- 24 extension points throughout execution
- 100+ system prompts for fine-grained control
- Agent profiles for different use cases
- No hard-coded logic - all prompt-driven

### 5. Multi-Provider LLM Support

- Supports 20+ LLM providers via LiteLLM
- Easy provider/model switching in settings
- Per-model rate limiting
- Streaming support for real-time UI updates

### 6. Browser Automation

- Integrated browser-use library for web interaction
- Playwright support for advanced automation
- DOM extraction and analysis
- Screenshot capabilities

### 7. Document RAG

- LangChain integration for document processing
- Support for PDF, Word, HTML, plain text
- Automatic chunking and embedding
- Semantic document search

### 8. Project-Based Workspaces

- Isolated workspaces per project
- Separate memory, knowledge, instruments per project
- Project switching in UI
- Project configuration (.gitignore, etc.)

### 9. Real-time Streaming

- WebSocket-based streaming
- Token-by-token response display
- Tool execution progress updates
- Non-blocking async operations

### 10. MCP (Model Context Protocol) Support

- FastMCP for server implementation
- MCP client for resource access
- Server discovery and management
- Tool integration via MCP

### 11. Code Execution Sandbox

- Python, Node.js, Shell code execution
- Isolated execution environment
- Output capture and streaming
- Error handling and recovery

### 12. Email Integration

- IMAP client support
- Email reading and composition
- Calendar integration (Exchange)
- Notification system for email

### 13. Task Scheduling

- Cron-based task scheduling
- Web UI for creating scheduled tasks
- Task history and logging
- Background task execution

### 14. Authentication & Security

- Optional login system
- CSRF protection on all state-changing requests
- Session management
- API rate limiting

### 15. Backup & Restore

- Chat backup to JSON/ZIP
- Memory backup
- Incremental backups
- Restore from backup

---

## Key Statistics

### Codebase Metrics

| Metric | Value |
|---|---|
| **Total Files** | 1,066 |
| **Total Lines (estimated)** | 400,000+ |
| **Python Files** | ~180+ |
| **JavaScript Files** | ~40+ |
| **Prompt Files** | ~100 |
| **Tool Files** | ~20 |
| **Extension Points** | 24 |
| **API Endpoints** | 61+ |
| **Helper Modules** | ~73 |
| **Test Files** | 5+ |

### Largest Files by Token Count

1. `webui/vendor/ace-min/worker-xquery.js` - 823,697 tokens (vendor library)
2. `webui/js/transformers@3.0.2.js` - 247,288 tokens (ML model library)
3. `webui/vendor/ace-min/worker-javascript.js` - 228,583 tokens (vendor library)
4. `webui/vendor/ace-min/ace.js` - 143,208 tokens (code editor)
5. `webui/vendor/ace/ace.js` - 143,168 tokens (code editor)

### Core Module Sizes

| Module | Lines | Purpose |
|---|---|---|
| `agent.py` | 922 | Core Agent class |
| `models.py` | 919 | LLM integration |
| `run_ui.py` | 285 | Flask server |
| `history.py` | ~400 | Message history |
| `memory.py` | ~600 | FAISS integration |
| `extract_tools.py` | ~300 | Tool discovery |

---

## Important Design Principles

1. **Prompt-First Design**
   - Behavior defined through prompts, not code
   - 100+ modular prompt files
   - Easy to customize without programming
   - Fallback system for profile-specific prompts

2. **Extension-Based Customization**
   - 24 hook points throughout execution
   - Numbered files for execution order
   - Non-invasive modifications to core behavior
   - Profile-specific extensions override defaults

3. **Tool Abstraction**
   - All capabilities modeled as tools
   - Dynamic discovery and loading
   - Composable tool execution
   - Easy to add new tools

4. **Memory-Driven Intelligence**
   - Semantic memory for learning across sessions
   - Automatic memory extraction
   - Context-aware memory retrieval
   - Persistent vector database

5. **Async-First Architecture**
   - Non-blocking operations throughout
   - Real-time streaming to UI
   - Concurrent tool execution
   - Proper async/await patterns

6. **Multi-Provider Support**
   - LiteLLM abstraction for any LLM
   - Easy provider switching
   - Per-model configuration
   - Rate limiting per provider

7. **Context Isolation**
   - Per-conversation contexts
   - Hierarchical context nesting for delegation
   - Isolated memory per agent profile
   - Workspace isolation in v0.9.7+

8. **Zero Hard-Coded Logic**
   - Behavior entirely prompt-driven
   - Extensions for customization
   - Dynamic tool discovery
   - Configuration-based feature flags

---

## File Organization Summary

**By Purpose:**

**Core Logic:** `agent.py`, `models.py`, `run_ui.py`

**Tool System:** `python/tools/` (20 tools) + `python/helpers/extract_tools.py`

**Memory:** `python/helpers/memory.py`, `python/helpers/memory_consolidation.py`, `memory/` (FAISS indices)

**Extensions:** `python/extensions/` (24 points) + `agents/[profile]/extensions/`

**API:** `python/api/` (61+ endpoints)

**Frontend:** `webui/` (HTML, JS, CSS, components)

**Configuration:** `.env`, `conf/model_providers.yaml`, `agents/[profile]/`

**Knowledge:** `knowledge/` (user and default knowledge)

**Prompts:** `prompts/` (~100 files) + `agents/[profile]/prompts/`

**Instruments:** `instruments/` (custom automation scripts)

**Docs:** `docs/` (architecture, usage, development guides)

**Tests:** `tests/` (pytest-based test suite)

**Docker:** `docker/` (base and runtime configurations)

---

## Conclusion

Agent Zero is a sophisticated, production-ready agentic AI framework built on:

1. **Solid Architecture** - Multi-agent system with clear separation of concerns
2. **Extensibility** - 24 hook points + custom tools + agent profiles
3. **Advanced Features** - Memory persistence, semantic search, multi-provider LLM support
4. **Developer-Friendly** - Well-documented, modular design, comprehensive API
5. **Enterprise-Ready** - Docker containerization, rate limiting, backup/restore, authentication
6. **Zero Hard-Coding** - All behavior driven by prompts and configuration

The codebase demonstrates excellent software engineering practices: async-first design, extension patterns, prompt-driven architecture, and comprehensive testing. It's suitable for building sophisticated AI applications with customizable agents, persistent learning, and multi-tool reasoning capabilities.

