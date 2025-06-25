# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Running Agent Zero
- **Web UI**: `python run_ui.py` - Starts the Flask web server with Web UI and API endpoints
- **CLI** (deprecated): `python run_cli.py` - Command-line interface (no longer actively maintained)
- **Dependencies**: `pip install -r requirements.txt` - Install Python dependencies

### Docker Operations
- **Pull Image**: `docker pull frdel/agent-zero-run` - Get the runtime container
- **Run Container**: `docker run -p 50001:80 -v /path/to/data:/a0 frdel/agent-zero-run`
- **Hacking Edition**: Use `frdel/agent-zero-run:hacking` for cybersecurity-focused variant

### Development Setup
- **Initialize**: `python initialize.py` - Framework initialization  
- **Prepare Environment**: `python prepare.py` - Environment preparation
- **Update Requirements**: `python update_reqs.py` - Update Python dependencies

### Testing and Development
- **Canvas Tool Test**: `python test_canvas.py` - Run Canvas functionality tests
- **Manual Canvas UI Test**: Open `canvas_test.html` with web UI running
- **Development Docker Script**: `docker/run/dev_docker.sh` - Development container setup
- **Note**: No comprehensive test framework currently configured

## Architecture Overview

Agent Zero is a hierarchical multi-agent framework designed around several core concepts:

### Agent Hierarchy
- **Agent 0**: Top-level agent that receives user instructions
- **Subordinate Agents**: Created dynamically to handle subtasks via `call_subordinate` tool
- **Superior-Subordinate Communication**: Agents report back up the hierarchy
- **Context Management**: Each agent maintains its own context and can delegate to others

### Core Components

**Tools** (`python/tools/`):
- `code_execution_tool.py` - Execute Python, Node.js, and Shell code
- `knowledge_tool.py` - Search web (SearXNG), memory, and knowledge base
- `memory_*.py` - Memory management (save, load, delete, forget)
- `call_subordinate.py` - Delegate tasks to subordinate agents
- `response.py` - Output responses to users
- `webpage_content_tool.py` - Fetch and analyze web content
- `behaviour_adjustment.py` - Modify agent behavior dynamically
- `canvas_tool.py` - HTML5 Canvas manipulation and graphics operations
- `browser_agent.py` - Automated browser interactions using browser-use
- `document_query.py` - Document Q&A and RAG functionality
- `scheduler.py` - Task scheduling and automation

**Memory System**:
- **Fragments**: Automatically stored conversation pieces
- **Solutions**: Successful task solutions for future reference
- **Vector Database**: FAISS-based embedding storage for retrieval
- **Summarization**: Dynamic message history compression

**Prompts** (`prompts/default/`):
- `agent.system.main.md` - Central hub referencing other prompts
- `agent.system.tool.*.md` - Individual tool prompt files
- `agent.system.main.role.md` - Agent role definition
- Custom prompts can be placed in subdirectories

### Key Files
- `agent.py` - Core Agent and AgentContext classes with hierarchical messaging
- `models.py` - LLM provider configurations (OpenAI, Anthropic, Ollama, Google, etc.)
- `run_ui.py` - Flask web server with authentication, API endpoints, and MCP server
- `initialize.py` - Agent configuration and startup logic
- `python/api/` - REST API endpoints for web UI communication
- `python/helpers/` - Utility modules for memory, browser automation, file handling

### Extensions Framework
Located in `python/extensions/`, organized by execution phase:
- `message_loop_start/` - Pre-processing extensions
- `message_loop_end/` - Post-processing extensions
- `monologue_start/` and `monologue_end/` - Agent session boundaries
- Files execute alphabetically (use numbered prefixes for order)

### Docker Integration
- **Runtime Container**: Houses complete framework with standardized environment
- **Volume Mounting**: `/a0` for data persistence
- **Port Mapping**: 80 for Web UI, 22 for SSH access
- **Security**: Containerization provides isolation and security

### Knowledge and Instruments
- **Knowledge**: User-provided files in `/knowledge/` (supports .txt, .pdf, .csv, .html, .json, .md)
- **Instruments**: Custom scripts in `/instruments/` recalled from memory when needed
- **Automatic Indexing**: Files are automatically processed and vectorized
- **Document Q&A**: RAG-based querying of knowledge base documents
- **Canvas Integration**: HTML5 canvas for graphics, drawing, and visualizations

## Development Patterns

### Tool Creation
1. Create prompt file: `prompts/default/agent.system.tool.TOOLNAME.md`
2. Reference in `prompts/default/agent.system.tools.md`
3. Implement tool class in `python/tools/` extending `Tool` base class
4. Follow existing patterns for consistency

### Extension Development
1. Place in appropriate `python/extensions/` subfolder
2. Use numbered prefixes for execution order
3. Extend `Extension` base class
4. Implement `execute()` method

### Custom Prompts
1. Create subdirectory in `prompts/` (e.g., `prompts/custom/`)
2. Copy and modify files from `prompts/default/`
3. Agent will merge custom files with defaults
4. Select in Settings page (Agent Config section)

## Configuration

### Model Configuration
- **Chat Model**: Primary conversation LLM
- **Utility Model**: Internal tasks (summarization, memory)  
- **Embedding Model**: Vector storage and retrieval
- **Browser Model**: Web interaction tasks

**Supported Providers** (configured in `models.py`):
- OpenAI (including Azure OpenAI)
- Anthropic
- Google (Gemini)
- Groq
- Ollama (local models)
- HuggingFace
- Mistral AI
- LM Studio
- OpenRouter
- SambaNova

### Settings Location
- `.env` - Environment variables and API keys (copy from `example.env`)
- `tmp/settings.json` - Web UI configuration
- `memory/` - Memory subdirectories for different instances
- `work_dir/` - Agent working directory for files and outputs
- `logs/` - HTML session logs
- `knowledge/` - User knowledge files (auto-indexed for RAG)
- `instruments/` - Custom scripts recalled from memory

### Authentication
- Basic auth for Web UI (AUTH_LOGIN, AUTH_PASSWORD)
- API key protection for external access
- Loopback-only restrictions for sensitive endpoints
- MCP server/client authentication and security protocols

## Recent Updates

- **MCP Integration**: Agent Zero now includes both MCP server and client functionality
- **Canvas Tool**: HTML5 canvas support for graphics and visualizations
- **Document RAG**: Enhanced document Q&A with automatic indexing
- **Browser Agent**: Automated web interactions using browser-use library
- **Hacking Edition**: Specialized cybersecurity variant available

## Important Notes

- Agent Zero is fully prompt-based - behavior is controlled via markdown files in `prompts/`
- The framework has no hard-coded rails; agents operate with complete freedom within their prompts
- Memory system provides both automatic learning and manual information storage
- MCP (Model Context Protocol) server and client functionality included
- All components are designed to be customizable and extensible
- Docker runtime is the primary deployment method for consistency and security
- **Web UI Port**: Default port 8080 (configurable via WEB_UI_PORT in .env)
- **API Endpoints**: All API routes are in `python/api/` and served via Flask
- **Dependency Management**: Uses Python virtual environment with comprehensive package requirements
- **Caution**: Agent Zero can perform potentially dangerous operations - always run in isolated environments