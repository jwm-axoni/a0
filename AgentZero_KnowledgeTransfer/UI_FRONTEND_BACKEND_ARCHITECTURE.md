# Agent Zero - UI & Frontend-Backend Architecture

## Overview
Agent Zero uses a Vanilla JavaScript + Alpine.js frontend connected to a Python Flask backend via REST APIs and polling for real-time updates.

## Technology Stack
### Frontend (webui/)
- **Framework:** Vanilla JavaScript + Alpine.js for reactivity
- **State Management:** Custom AlpineStore.js with createStore() proxy pattern
- **Markdown:** Marked.js + KaTeX for math rendering
- **Code Display:** Ace Editor
- **Styling:** CSS3 with custom components

### Backend (Python)
- **Web Framework:** Flask 3.0.3 with async support
- **Port:** 50001 (local), 80 (Docker)
- **API Endpoints:** 61+ REST endpoints in python/api/

## Frontend-Backend Communication

### 1. API Client (webui/js/api.js)
```javascript
export async function fetchApi(url, request) {
  // Adds CSRF token automatically
  // Handles 403 errors and retry
  // Redirects to login if session expired
}
```

### 2. Message Sending (webui/index.js)
```javascript
export async function sendMessage() {
  // Collects message + attachments
  // Uses FormData for file uploads
  // Calls /message_async endpoint
  // Receives context ID in response
}
```

### 3. Real-Time Updates (Polling System)
- **NOT WebSocket** - Uses polling via `/poll` endpoint
- **Interval:** Configurable, fetches logs, contexts, notifications
- **Response includes:** logs, context state, tasks, notifications

```javascript
export async function poll() {
  // Sends current log version
  // Receives new logs since last version
  // Updates UI with setMessage() for each log entry
}
```

### 4. Backend Poll Handler (python/api/poll.py)
Returns:
- logs (new messages since log_from)
- contexts (active chat contexts)
- tasks (scheduled tasks)
- notifications
- progress state (for progress bar)
- paused state

## Key Components

### Frontend Structure
```
webui/
├── index.html       # Main app page
├── index.js         # App initialization, sendMessage(), poll()
├── index.css        # Main styles
├── js/
│   ├── api.js       # API client with CSRF handling
│   ├── messages.js  # Message rendering (setMessage, drawMessage*)
│   ├── AlpineStore.js # State management
│   ├── settings.js  # Settings UI
│   └── ...
├── components/
│   ├── sidebar/     # Left sidebar (chats, tasks)
│   ├── chat/        # Chat display, input, attachments
│   ├── settings/    # Settings panels
│   ├── modals/      # Dialogs (file browser, history, etc.)
│   └── notifications/
└── css/             # Component styles
```

### Backend API Structure
```
python/api/
├── message.py       # Main message processing
├── message_async.py # Async message with attachments
├── poll.py          # Real-time polling endpoint
├── chat_*.py        # Chat management (create, load, reset, remove)
├── settings_*.py    # Settings get/set
├── memory_*.py      # Memory operations
├── projects.py      # Project management
└── ... (61+ endpoints)
```

## Message Flow
1. User types message in UI (chatInput)
2. sendMessage() called → POST /message_async
3. Backend creates AgentContext, starts agent.monologue()
4. Agent processes, logs are added to context.log
5. Frontend polls /poll endpoint every ~250ms
6. Poll returns new logs since last version
7. Frontend renders each log via setMessage()

## Docker Architecture
- **Base Image:** Ubuntu with Python, Node.js, SearXNG, SSH
- **Supervisor:** Manages multiple processes:
  - run_ui (Flask app on port 80)
  - run_searxng (search engine)
  - run_sshd (SSH for remote code execution)
  - run_tunnel_api (external access tunnel)
  - run_cron (scheduled tasks)
- **Volumes:** /a0 mounted from host for persistence
- **Port Mapping:** 50080:80 (external:internal)

## UI Upgrade Considerations
1. **State Management:** Uses Alpine.js stores - can be upgraded to more robust solutions
2. **Real-time Updates:** Polling-based - could be upgraded to WebSockets/SSE
3. **Component Structure:** HTML components with -store.js files - modular but not true components
4. **Styling:** Plain CSS - could benefit from Tailwind or CSS-in-JS
5. **Build System:** No build step currently - all vanilla JS modules

## Design Guidelines

When building or upgrading UI components, refer to the **Frontend Design Skill** in:
- `.augment/FRONTEND_DESIGN_SKILL.md` (detailed skill reference)
- `.augment/instructions.md` (Augment Code)
- `.github/copilot-instructions.md` (GitHub Copilot)
- `CLAUDE.md` (Claude Code)

Key principles:
- **Bold aesthetic direction** - Choose a clear conceptual direction (minimalist, brutalist, retro-futuristic, etc.)
- **Distinctive typography** - Avoid generic fonts (Inter, Roboto, Arial)
- **Intentional color** - Dominant colors with sharp accents, not timid palettes
- **Meaningful motion** - High-impact animations at key moments
- **Unexpected layouts** - Asymmetry, overlap, grid-breaking elements

