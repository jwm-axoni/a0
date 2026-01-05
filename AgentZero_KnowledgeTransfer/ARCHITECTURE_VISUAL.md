# Agent Zero - Architecture Visualization

## System Overview Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AGENT ZERO FRAMEWORK                              │
└─────────────────────────────────────────────────────────────────────────────┘

                              ┌──────────────────┐
                              │   USER INTERFACE │
                              │   (Web UI/CLI)   │
                              └────────┬─────────┘
                                       │
                                       ▼
                        ┌──────────────────────────┐
                        │   FLASK API SERVER       │
                        │   Port 50001             │
                        │   61+ Endpoints          │
                        └────────────┬─────────────┘
                                     │
                ┌────────────────────┼────────────────────┐
                │                    │                    │
                ▼                    ▼                    ▼
        ┌──────────────┐     ┌──────────────┐    ┌──────────────┐
        │ Chat Messages│     │   Settings   │    │   Memory API │
        │   Processing │     │  Management  │    │   &Knowledge │
        └──────────────┘     └──────────────┘    └──────────────┘
                │
                ▼
        ┌─────────────────────────────────────┐
        │      AGENT CONTEXT (Isolated)       │
        │  - Request scope                    │
        │  - Message history                  │
        │  - Logs & output                    │
        └──────────────┬──────────────────────┘
                       │
                       ▼
        ┌─────────────────────────────────────┐
        │    AGENT CLASS (Message Loop)       │
        │  agent.py - Core reasoning engine   │
        │  Line 356: async monologue()        │
        └──────────────┬──────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │   MESSAGE LOOP (Iteration)  │
        │                             │
        │  1. Build system prompt     │
        │  2. Load message history    │
        │  3. Call LLM (streaming)    │
        │  4. Extract tools           │
        │  5. Execute tool(s)         │
        │  6. Add results to history  │
        │  7. Loop until response_tool│
        └──────────────┬──────────────┘
                       │
        ┌──────────────┴─────────────────────────┐
        │         EXTENSION SYSTEM (24 Points)   │
        │                                        │
        │  ┌──────────────────────────────────┐ │
        │  │ agent_init                       │ │
        │  ├──────────────────────────────────┤ │
        │  │ monologue_start/end              │ │
        │  ├──────────────────────────────────┤ │
        │  │ message_loop_start/end           │ │
        │  ├──────────────────────────────────┤ │
        │  │ before_main_llm_call             │ │
        │  ├──────────────────────────────────┤ │
        │  │ reasoning_stream/response_stream │ │
        │  ├──────────────────────────────────┤ │
        │  │ hist_add_before/tool_result      │ │
        │  ├──────────────────────────────────┤ │
        │  │ message_loop_prompts_*           │ │
        │  ├──────────────────────────────────┤ │
        │  │ error_format                     │ │
        │  ├──────────────────────────────────┤ │
        │  │ ... (and more)                   │ │
        │  └──────────────────────────────────┘ │
        │                                        │
        │  Can modify:                           │
        │  - State & history                    │
        │  - Prompts & context                  │
        │  - Tool execution                     │
        │  - Error handling                     │
        └────────────────────────────────────────┘
                       │
        ┌──────────────┴─────────────────────────┐
        │        THREE CORE SUBSYSTEMS           │
        │                                        │
        │  ┌─────────────────────────────────┐  │
        │  │   1. TOOL SYSTEM (20 tools)     │  │
        │  │   ┌──────────────────────────┐  │  │
        │  │   │ Built-in Tools:          │  │  │
        │  │   │ - code_execution_tool    │  │  │
        │  │   │ - browser_agent          │  │  │
        │  │   │ - call_subordinate       │  │  │
        │  │   │ - search_engine          │  │  │
        │  │   │ - document_query         │  │  │
        │  │   │ - memory_*               │  │  │
        │  │   │ - scheduler              │  │  │
        │  │   │ - behaviour_adjustment   │  │  │
        │  │   │ - response, input, wait  │  │  │
        │  │   │ - ... (more)             │  │  │
        │  │   └──────────────────────────┘  │  │
        │  └──────────────┬────────────────────┘  │
        │                 │                       │
        │                 ▼                       │
        │  ┌─────────────────────────────────┐  │
        │  │  Tool Base Class (tool.py)      │  │
        │  │  ├─ before_execution()          │  │
        │  │  ├─ execute()                   │  │
        │  │  └─ after_execution()           │  │
        │  └─────────────────────────────────┘  │
        │                                        │
        │  ┌─────────────────────────────────┐  │
        │  │   2. MEMORY SYSTEM              │  │
        │  │   (FAISS Vector Database)       │  │
        │  │   ┌──────────────────────────┐  │  │
        │  │   │ Four Memory Areas:       │  │  │
        │  │   │ - MAIN (facts)           │  │  │
        │  │   │ - FRAGMENTS (snippets)   │  │  │
        │  │   │ - SOLUTIONS (patterns)   │  │  │
        │  │   │ - INSTRUMENTS (code)     │  │  │
        │  │   │                          │  │  │
        │  │   │ Features:                │  │  │
        │  │   │ - Semantic search        │  │  │
        │  │   │ - Auto-consolidation    │  │  │
        │  │   │ - Persistent storage    │  │  │
        │  │   │ - Embedding via S-T     │  │  │
        │  │   └──────────────────────────┘  │  │
        │  └─────────────────────────────────┘  │
        │                                        │
        │  ┌─────────────────────────────────┐  │
        │  │   3. PROMPT SYSTEM              │  │
        │  │   (~100 Prompt Files)           │  │
        │  │   ┌──────────────────────────┐  │  │
        │  │   │ Hierarchical Loading:    │  │  │
        │  │   │ 1. Agent profile prompts │  │  │
        │  │   │ 2. Default prompts       │  │  │
        │  │   │ 3. Framework prompts     │  │  │
        │  │   │                          │  │  │
        │  │   │ Prompt Categories:       │  │  │
        │  │   │ - Main (role, solving)   │  │  │
        │  │   │ - Tool instructions      │  │  │
        │  │   │ - Behavior rules         │  │  │
        │  │   │ - Memory operations      │  │  │
        │  │   │ - Framework helpers      │  │  │
        │  │   └──────────────────────────┘  │  │
        │  └─────────────────────────────────┘  │
        └────────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────────────────┐
        │      LLM INTEGRATION (Multi-Provider)   │
        │                                         │
        │  LiteLLM Abstraction Layer              │
        │  ┌───────────────────────────────────┐ │
        │  │ Four Model Types:                 │ │
        │  │ - Chat Model (main reasoning)     │ │
        │  │ - Utility Model (summarization)   │ │
        │  │ - Embedding Model (memory)        │ │
        │  │ - Browser Model (web tasks)       │ │
        │  │                                   │ │
        │  │ 20+ Provider Support:             │ │
        │  │ - OpenAI, Anthropic, OpenRouter  │ │
        │  │ - Azure, local, Venice, GitHub   │ │
        │  │ - Cohere, Groq, Mistral, etc.   │ │
        │  │                                   │ │
        │  │ Features:                         │ │
        │  │ - Streaming with callbacks        │ │
        │  │ - Rate limiting per model         │ │
        │  │ - Token counting                  │ │
        │  │ - Error handling & retries        │ │
        │  └───────────────────────────────────┘ │
        └────────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────────────────┐
        │       SUPPORTING SYSTEMS                │
        │                                         │
        │  ┌───────────────────────────────────┐ │
        │  │ History Management                │ │
        │  │ - Sliding window history          │ │
        │  │ - Auto-compression                │ │
        │  │ - Bulk summarization              │ │
        │  └───────────────────────────────────┘ │
        │  ┌───────────────────────────────────┐ │
        │  │ Logging & Monitoring              │ │
        │  │ - Real-time logs                  │ │
        │  │ - Chat persistence                │ │
        │  │ - HTML logs                       │ │
        │  └───────────────────────────────────┘ │
        │  ┌───────────────────────────────────┐ │
        │  │ Agent Profiles                    │ │
        │  │ - default, developer, researcher  │ │
        │  │ - hacker, agent0, custom          │ │
        │  │ - Profile-specific prompts        │ │
        │  │ - Profile-specific extensions     │ │
        │  │ - Profile-specific memory         │ │
        │  └───────────────────────────────────┘ │
        │  ┌───────────────────────────────────┐ │
        │  │ Document RAG                      │ │
        │  │ - LangChain integration           │ │
        │  │ - PDF/Word/HTML processing        │ │
        │  │ - Semantic search                 │ │
        │  └───────────────────────────────────┘ │
        │  ┌───────────────────────────────────┐ │
        │  │ Browser Automation                │ │
        │  │ - browser-use library             │ │
        │  │ - Playwright support              │ │
        │  │ - DOM extraction                  │ │
        │  └───────────────────────────────────┘ │
        │  ┌───────────────────────────────────┐ │
        │  │ Security & Authentication         │ │
        │  │ - Optional login system           │ │
        │  │ - CSRF protection                 │ │
        │  │ - Session management              │ │
        │  │ - Rate limiting                   │ │
        │  └───────────────────────────────────┘ │
        └────────────────────────────────────────┘
```

---

## Message Loop Flow (Core Processing)

```
┌────────────────────────────────────────────────────────────────────┐
│                    USER MESSAGE ARRIVES                            │
│                (via Web UI or API /message endpoint)               │
└────────────────────┬───────────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │   Create/Use AgentContext              │
        │   (Isolated request scope)             │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │   Initialize Agent                     │
        │   ├─ Load configuration                │
        │   ├─ Initialize memory                 │
        │   └─ Extension: agent_init             │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ╔════════════════════════════════════════╗
        ║      MONOLOGUE LOOP (Outer)            ║
        ║   (Can iterate multiple times)         ║
        ╚════════════┬═══════════════════════════╝
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │ Extension: monologue_start             │
        │ ├─ Initialize memory                   │
        │ ├─ Rename chat if needed               │
        │ └─ Prepare state                       │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ╔════════════════════════════════════════╗
        ║    MESSAGE ITERATION LOOP (Inner)      ║
        ║  (Loop until response_tool is used)    ║
        ╚════════════┬═══════════════════════════╝
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │ Extension: message_loop_start          │
        │ ├─ Increment iteration counter         │
        │ └─ Reset state                         │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │ BUILD SYSTEM PROMPT                    │
        │ ├─ Load main prompts (main.md)         │
        │ ├─ Load tool instructions              │
        │ ├─ Load behavior rules                 │
        │ └─ Compose final system prompt         │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │ PREPARE MESSAGE HISTORY                │
        │ ├─ Load conversation history           │
        │ ├─ Auto-compress if too large          │
        │ ├─ Add role/behavior context           │
        │ └─ Extension: message_loop_prompts_bfr │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │ INJECT CONTEXT                         │
        │ ├─ Semantic memory search (FAISS)      │
        │ ├─ Include current datetime            │
        │ ├─ Include agent info                  │
        │ ├─ Include project info                │
        │ └─ Extension: message_loop_prompts_aft │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │ Extension: before_main_llm_call        │
        │ └─ Final prompt modifications          │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │   CALL LLM (Streaming)                 │
        │   ├─ Use ModelConfig settings          │
        │   ├─ Stream tokens to callbacks        │
        │   ├─ Callback: reasoning_stream        │
        │   ├─ Callback: response_stream         │
        │   └─ Collect full response             │
        │                                        │
        │   [Streaming to UI happens here]       │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │ EXTRACT TOOLS FROM RESPONSE            │
        │ ├─ Parse with regex patterns           │
        │ ├─ Identify tool names & args          │
        │ ├─ Handle JSON/dirty JSON              │
        │ └─ Return list of ToolCall objects     │
        └────────────┬───────────────────────────┘
                     │
           ┌─────────┴──────────┐
           │                    │
           ▼                    ▼
      ┌─────────┐          ┌──────────────┐
      │ No tools│          │ Tool(s) used │
      │  found  │          │              │
      └────┬────┘          └────────┬─────┘
           │                        │
           │                   ┌────▼─────────────────────┐
           │                   │ EXECUTE TOOL(S)          │
           │                   │                          │
           │                   │ For each tool:           │
           │                   │ ├─ Load tool class       │
           │                   │ ├─ Tool.before_exe()     │
           │                   │ ├─ Tool.execute()        │
           │                   │ ├─ Tool.after_exe()      │
           │                   │ └─ Collect response      │
           │                   │                          │
           │                   │ [Tool execution updates] │
           │                   │  sent to UI              │
           │                   └────┬────────────────────┘
           │                        │
           │                   ┌────▼──────────────────────┐
           │                   │ ADD RESULTS TO HISTORY    │
           │                   │ ├─ Ext: hist_add_before   │
           │                   │ ├─ Add tool result msg    │
           │                   │ └─ Ext: hist_add_tool_res │
           │                   └────┬─────────────────────┘
           │                        │
           └────────────┬───────────┘
                        │
                        ▼
           ┌────────────────────────────────┐
           │ CHECK: response_tool used?     │
           └────────────┬───────────────────┘
                        │
           ┌────────────┴────────────┐
           │                         │
           ▼ YES                     ▼ NO
      ┌─────────┐              ┌──────────────┐
      │ BREAK   │              │ CONTINUE     │
      │ INNER   │              │ INNER LOOP   │
      │ LOOP    │              │ (goto        │
      └────┬────┘              │  MESSAGE     │
           │                   │  ITERATION)  │
           │                   └──────┬───────┘
           │                          │
           └──────────────┬───────────┘
                          │
                          ▼
        ┌────────────────────────────────────────┐
        │ Extension: message_loop_end            │
        │ ├─ Organize history                    │
        │ ├─ Save chat to disk                   │
        │ └─ Update logs                         │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │ COLLECT RESPONSE(S)                    │
        │ (From tool results or LLM response)    │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │ Extension: monologue_end               │
        │ ├─ Save memory fragments               │
        │ ├─ Save memory solutions               │
        │ └─ Finalize response                   │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │ STREAM FINAL RESPONSE TO UI            │
        │ (via WebSocket)                        │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │ RESPONSE COMPLETE                      │
        │ (Chat saved, memory updated)           │
        └────────────────────────────────────────┘
```

---

## Memory System Flow

```
┌──────────────────────────────────────────────────────────────┐
│              MEMORY SYSTEM (FAISS-Based)                    │
└──────────────────────────────────────────────────────────────┘

CONVERSATION HAPPENS
├─ Agent executes tools
├─ Gains knowledge
└─ Generates insights

                    ▼

MEMORY EXTRACTION (Extension: monologue_end)
├─ monologue_end/_50_memorize_fragments.py
│  └─ Extract snippets and facts
├─ monologue_end/_51_memorize_solutions.py
│  └─ Extract patterns and solutions
└─ Identify important segments

                    ▼

CONSOLIDATION (Utility LLM)
├─ Call utility_model with consolidation prompt
├─ Extract key insights
├─ Format as memory entries
└─ Generate metadata (timestamp, source)

                    ▼

STORAGE (Memory.save_memory())
├─ Choose memory area:
│  ├─ MAIN (facts and core knowledge)
│  ├─ FRAGMENTS (snippets and pieces)
│  ├─ SOLUTIONS (patterns and solutions)
│  └─ INSTRUMENTS (custom code/tools)
├─ Create Document object
├─ Add metadata
└─ Store in memory dict

                    ▼

EMBEDDING (Sentence-Transformers)
├─ Load embedding model
├─ Generate vector embeddings
│  (768-1024 dimensions)
└─ Prepare for storage

                    ▼

INDEXING (FAISS)
├─ Add vectors to FAISS index
├─ Update in-memory docstore
├─ Persist to disk:
│  └─ memory/[agent_profile]/
│     ├─ main.faiss
│     ├─ fragments.faiss
│     ├─ solutions.faiss
│     └─ instruments.faiss
└─ Update metadata

                    ▼

PERSISTENCE
├─ Save index to disk
├─ Save docstore
└─ Accessible on next session


MEMORY RETRIEVAL (Extension: message_loop_prompts_after)
      ↓
message_loop_prompts_after/_50_recall_memories.py
      ├─ Prepare search query
      ├─ Semantic search via FAISS:
      │  ├─ Compare query embedding to stored vectors
      │  ├─ Find K nearest neighbors
      │  └─ Return top matches with similarity scores
      ├─ Retrieve matching memories
      ├─ Organize by area (MAIN, FRAGMENTS, etc.)
      ├─ Format as markdown
      └─ Inject into system prompt
            │
            ├─ "Relevant memories:"
            ├─ "- [Memory 1] (similarity: 0.85)"
            ├─ "- [Memory 2] (similarity: 0.78)"
            └─ "- [Memory 3] (similarity: 0.72)"
            │
            ▼
      Agent uses memories in reasoning
      ├─ References past solutions
      ├─ Applies learned patterns
      ├─ Builds on previous knowledge
      └─ Grows more intelligent over time

MEMORY MANAGEMENT (Tools)
├─ memory_save.py - Save to memory
├─ memory_load.py - Query memory
├─ memory_delete.py - Delete entry
├─ memory_forget.py - Clear area
└─ memory_consolidation.py - Auto consolidation

API ACCESS
├─ POST /memory_save - Save custom memory
├─ GET /memory_load - Query with filters
├─ POST /memory_delete - Delete specific entry
├─ GET /memory_dashboard - Statistics & visualization
└─ POST /memory_forget - Clear memory area
```

---

## Tool Execution Pipeline

```
┌──────────────────────────────────────────────────────────────┐
│         TOOL SYSTEM (Dynamic Discovery & Execution)         │
└──────────────────────────────────────────────────────────────┘

LLM RESPONSE CONTAINS TOOL USAGE
Example: "I need to run some code. Tool: code_execution_tool"

                    ▼

TOOL EXTRACTION (extract_tools.py)
├─ Parse response with regex patterns
├─ Pattern: "Tool: [name]"
├─ Extract arguments (JSON or dirty JSON)
├─ Handle multiple tool calls
└─ Return ToolCall objects
   └─ { tool_name, method, args }

                    ▼

TOOL DISCOVERY (Dynamic Loading)
├─ Look up tool class
├─ Import from python/tools/[name].py
├─ Verify inherits from Tool base class
├─ Instantiate with:
│  ├─ agent reference
│  ├─ name, method
│  ├─ args dict
│  ├─ message context
│  └─ loop_data for state
└─ Handle unknown tools → unknown.py

                    ▼

TOOL EXECUTION PIPELINE
├─ Tool.before_execution()
│  ├─ Log tool usage to console/UI
│  ├─ Display arguments
│  ├─ Create log entry
│  └─ Initialize progress tracking
│
├─ Tool.execute()  ← MAIN WORK HAPPENS HERE
│  ├─ Perform actual task
│  ├─ Handle errors gracefully
│  ├─ Set progress updates
│  ├─ Return Response object:
│  │  ├─ message: str (result text)
│  │  ├─ break_loop: bool (should stop?)
│  │  └─ additional: dict (metadata)
│  └─ [Tool sends updates to UI]
│
└─ Tool.after_execution()
   ├─ Process response
   ├─ Add result to message history
   ├─ Update log with result
   ├─ Display result to user
   └─ [Result visible in chat]

                    ▼

ADD TO MESSAGE HISTORY
├─ Create ToolResult message
├─ Extension: hist_add_before (modify before)
├─ Add to agent.hist list
├─ Extension: hist_add_tool_result (post-add)
└─ Will be included in next LLM call

                    ▼

CONTINUE MESSAGE LOOP
├─ Check if response_tool was used
├─ If yes: finish and return
├─ If no: loop again
│  └─ Agent sees tool result and reasons more

BUILT-IN TOOLS (20+)

1. code_execution_tool
   ├─ execute_python: Python code execution
   ├─ execute_node: Node.js code
   └─ execute_shell: Shell commands

2. browser_agent
   ├─ navigate: Go to URL
   ├─ interact: Click, type, scroll
   ├─ screenshot: Take screenshot
   └─ extract: Parse DOM

3. call_subordinate
   ├─ delegate: Create child agent
   └─ execute: Run with parameters

4. search_engine
   ├─ search: Web search
   └─ news: News search

5. document_query
   ├─ query: Search documents
   ├─ list: List available docs
   └─ index: Index new document

6. memory_save
   └─ Save to memory (MAIN/FRAGMENTS/SOLUTIONS)

7. memory_load
   └─ Query memory by keywords

8. memory_delete
   └─ Remove memory entry

9. memory_forget
   └─ Clear entire memory area

10. scheduler
    ├─ create_task: Schedule task
    ├─ list_tasks: Show scheduled
    └─ delete_task: Remove task

11. behaviour_adjustment
    └─ Modify own behavior dynamically

12. response
    └─ Finalize and return response

13. input
    └─ Request user input

14. wait
    └─ Wait for duration

15. notify_user
    └─ Send notification

16. a2a_chat
    └─ Chat with another agent

17. vision_load
    └─ Load vision/image data

18-20. ... (more specialized tools)

TOOL ARGUMENTS
├─ Extracted from LLM response
├─ Parsed as JSON or dirty JSON
├─ Mapped to tool class
└─ Validated before execution

TOOL PROMPTS
├─ Located in prompts/agent.system.tool.[name].md
├─ Instruct agent how to use tool
├─ Include examples
├─ Specify parameters
└─ Loaded into system prompt

CUSTOM TOOLS
├─ Create file: python/tools/my_tool.py
├─ Inherit from Tool class
├─ Implement execute() method
├─ Return Response object
├─ Create prompt: prompts/agent.system.tool.my_tool.md
└─ Automatically discovered
```

---

## Extension Hook Architecture

```
┌──────────────────────────────────────────────────────────────┐
│         EXTENSION SYSTEM (24 Customization Points)          │
└──────────────────────────────────────────────────────────────┘

EXTENSION TYPES

1. INITIALIZATION
   ├─ agent_init
   │  └─ Load initial message
   │  └─ Load profile settings
   │
   └─ message_loop_start
      └─ Iteration initialization

2. PROMPT BUILDING
   ├─ message_loop_prompts_before
   │  └─ Organize history, prepare structure
   │
   └─ message_loop_prompts_after
      ├─ Recall memories (FAISS search)
      ├─ Include current datetime
      ├─ Include agent info
      ├─ Include project extras
      └─ Recall wait/delay info

3. LLM INTERACTION
   ├─ before_main_llm_call
   │  └─ Log for streaming, final prompt tweaks
   │
   └─ (no direct after_llm - use response_stream)

4. STREAMING
   ├─ reasoning_stream
   │  └─ Process thinking/reasoning tokens
   │
   └─ response_stream
      └─ Process response tokens, send to UI

5. MESSAGE HISTORY
   ├─ hist_add_before
   │  └─ Mask sensitive content
   │
   └─ hist_add_tool_result
      └─ Save tool call files

6. MESSAGE LOOP COMPLETION
   └─ message_loop_end
      ├─ Organize history
      ├─ Save chat
      └─ Update logs

7. MONOLOGUE LIFECYCLE
   ├─ monologue_start
   │  ├─ Initialize memory
   │  └─ Rename chat
   │
   └─ monologue_end
      ├─ Memorize fragments
      ├─ Memorize solutions
      └─ Waiting for input message

8. ERROR HANDLING
   └─ error_format
      └─ Mask errors, custom formatting

9. SPECIAL PURPOSE
   ├─ knowledge_loading
   │  └─ Load knowledge base
   │
   ├─ mcp_handler
   │  └─ MCP protocol integration
   │
   ├─ behaviour_adjustment
   │  └─ Dynamic behavior changes
   │
   └─ ... (and more)


EXECUTION ORDER (by file name)

File format: python/extensions/[point]/_[priority]_[name].py

Priority levels:
├─ 10-29: Early extensions
├─ 30-69: Mid-priority
├─ 70-99: Late extensions
└─ Sorted alphabetically within same priority

Example execution order:
1. message_loop_prompts_after/_50_recall_memories.py
2. message_loop_prompts_after/_60_include_current_datetime.py
3. message_loop_prompts_after/_70_include_agent_info.py
4. message_loop_prompts_after/_75_include_project_extras.py
5. message_loop_prompts_after/_91_recall_wait.py


CREATING AN EXTENSION

Step 1: Create file
Location: python/extensions/[extension_point]/[priority]_name.py

Step 2: Implement Extension class
```python
from python.helpers.extension import Extension
from agent import LoopData

class MyExtension(Extension):
    async def execute(self, loop_data: LoopData, **kwargs):
        # Modify state/history/prompt
        loop_data.prompt += "\n\nAdditional instruction"
        # Can access:
        # - self.agent
        # - loop_data.prompt
        # - loop_data.history
        # - loop_data.response
        # - etc.
```

Step 3: Extension is auto-loaded and executed

Step 4: Override in agent profile
Location: agents/[profile]/extensions/[point]/[priority]_name.py
├─ Same implementation
└─ Will override framework extension


EXTENSION CAPABILITIES

Can modify:
├─ System prompt
├─ Message history
├─ Agent state
├─ Response content
├─ Tool execution
├─ Error handling
└─ Memory operations

Can access:
├─ self.agent - Agent instance
├─ self.agent.context - Agent context
├─ self.agent.context.log - Logging system
├─ self.agent.hist - Message history
├─ loop_data - Current state
└─ kwargs - Extension-specific parameters


EXTENSION INTEGRATION POINTS IN MESSAGE LOOP

Agent.monologue()
  │
  ├─→ call_extensions("agent_init")
  │
  ├─→ [MONOLOGUE LOOP]
  │   │
  │   ├─→ call_extensions("monologue_start")
  │   │
  │   ├─→ [MESSAGE ITERATION LOOP]
  │   │   │
  │   │   ├─→ call_extensions("message_loop_start")
  │   │   │
  │   │   ├─→ Build prompts
  │   │   │   ├─→ call_extensions("message_loop_prompts_before")
  │   │   │   ├─→ Assemble system + user messages
  │   │   │   └─→ call_extensions("message_loop_prompts_after")
  │   │   │
  │   │   ├─→ call_extensions("before_main_llm_call")
  │   │   │
  │   │   ├─→ Stream LLM response
  │   │   │   ├─→ call_extensions("reasoning_stream")
  │   │   │   └─→ call_extensions("response_stream")
  │   │   │
  │   │   ├─→ Extract & execute tools
  │   │   │   ├─→ call_extensions("hist_add_before")
  │   │   │   ├─→ Add tool result
  │   │   │   └─→ call_extensions("hist_add_tool_result")
  │   │   │
  │   │   └─→ call_extensions("message_loop_end")
  │   │
  │   └─→ call_extensions("monologue_end")
  │
  └─→ Return response
```

---

## Data Layer Architecture

```
┌──────────────────────────────────────────────────────────────┐
│           DATA PERSISTENCE & STORAGE LAYERS                 │
└──────────────────────────────────────────────────────────────┘

CHAT PERSISTENCE

Chat state saved in: /logs/ directory
┌─ [timestamp].json
│  ├─ messages[]
│  │  ├─ role: "user", "assistant", "system", "tool"
│  │  ├─ content: message text
│  │  ├─ timestamp
│  │  └─ metadata
│  ├─ context
│  ├─ settings
│  └─ metadata
│
└─ [timestamp].html
   └─ Human-readable chat log


MEMORY PERSISTENCE

Memory storage in: /memory/ directory
├─ /default/        (default agent profile)
│  ├─ main.faiss    (main facts FAISS index)
│  ├─ main.pkl      (metadata)
│  ├─ fragments.faiss
│  ├─ fragments.pkl
│  ├─ solutions.faiss
│  ├─ solutions.pkl
│  ├─ instruments.faiss
│  └─ instruments.pkl
│
├─ /developer/      (developer profile)
│  └─ ... (same structure)
│
├─ /researcher/
│  └─ ... (same structure)
│
└─ /[custom_profile]/
   └─ ... (same structure)

FAISS Index Contents:
├─ Vector embeddings (768-1024 dimensions)
├─ Document metadata
├─ Similarity index
└─ ID mappings


KNOWLEDGE BASE

Knowledge storage in: /knowledge/ directory
├─ /default/
│  └─ /main/
│     ├─ about/
│     │  ├─ github_readme.md
│     │  └─ installation.md
│     └─ ... (more docs)
│
├─ /custom/
│  └─ /main/
│     └─ (user-provided documents)
│
└─ /solutions/
   └─ (pattern/solution documents)

Processed via:
├─ Unstructured.io (document parsing)
├─ LangChain (chunking & embedding)
├─ FAISS (semantic search)
└─ Cached embeddings


SETTINGS PERSISTENCE

Settings storage: .env file
├─ API keys
├─ Model configuration
├─ Feature flags
└─ Server settings

Also persisted in memory:
├─ Per-profile settings
├─ Per-agent settings
├─ User preferences
└─ Feature overrides


INSTRUMENTS (Custom Tools)

Instruments storage: /instruments/ directory
├─ /default/
│  ├─ yt_download/
│  │  ├─ download_video.py
│  │  ├─ yt_download.sh
│  │  └─ yt_download.md
│  └─ ... (more)
│
└─ /custom/
   └─ (user-created instruments)

Used for:
├─ Custom automation scripts
├─ Tool implementations
├─ Reusable code
└─ Knowledge sharing


BACKUP & RESTORE

Backup format: ZIP archive or JSON
├─ Contains:
│  ├─ Chat history
│  ├─ Memory snapshots
│  ├─ Settings
│  ├─ Knowledge base
│  ├─ Instruments
│  └─ Metadata
│
└─ API endpoints:
   ├─ POST /backup_create
   ├─ POST /backup_restore
   └─ GET /backup_preview_grouped


PROJECT STORAGE (v0.9.7+)

Projects directory: /projects/ (configurable)
├─ /[project_name]/
│  ├─ /work/        (working directory)
│  ├─ /memory/      (project-specific memory)
│  ├─ /knowledge/   (project-specific knowledge)
│  ├─ /logs/        (project chat logs)
│  ├─ /instruments/ (project instruments)
│  ├─ settings.json (project settings)
│  └─ .gitignore    (from projects.default.gitignore)
│
└─ Projects isolated:
   ├─ Memory per project
   ├─ Knowledge per project
   ├─ Separate agent contexts
   └─ Independent configurations
```

---

## Security & Authentication Layer

```
┌──────────────────────────────────────────────────────────────┐
│          SECURITY & PROTECTION MECHANISMS                   │
└──────────────────────────────────────────────────────────────┘

REQUEST AUTHENTICATION

1. Login System (Optional)
   ├─ Endpoint: GET /login.html
   ├─ POST with username/password
   ├─ Session creation via Flask
   ├─ Cookie-based session management
   └─ Can be disabled in settings

2. Basic Auth (Optional)
   ├─ HTTP Basic Authentication
   ├─ Configured via env vars:
   │  ├─ BASIC_AUTH_USERNAME
   │  └─ BASIC_AUTH_PASSWORD
   └─ Applied to API endpoints

3. CSRF Protection
   ├─ All state-changing requests (POST, PUT, DELETE)
   ├─ Token in hidden form field or header
   ├─ Endpoint: GET /csrf_token
   ├─ Token validation on server side
   └─ Protects against cross-site attacks


API RATE LIMITING

Per-Model Rate Limiting:
├─ Configured in ModelConfig:
│  ├─ limit_requests: requests per minute
│  ├─ limit_input: input tokens per minute
│  └─ limit_output: output tokens per minute
│
├─ Implemented via RateLimiter class
├─ Per-provider limits
└─ Prevents API quota abuse

Request Queuing:
├─ Queue system for API calls
├─ Respects rate limits
├─ Fair distribution
└─ Backpressure handling


SANDBOXING & ISOLATION

Code Execution Sandbox:
├─ Subprocess execution for code
├─ Isolated process environment
├─ Timeout protection
├─ Input/output capture
├─ Error isolation
└─ Resource limits

Browser Sandbox:
├─ Playwright browser isolation
├─ Separate browser context per request
├─ Isolated cookies/storage
├─ Can disable Javascript
└─ Can block downloads


SECRETS MANAGEMENT

Environment Variables:
├─ .env file (not in git)
├─ Loaded via python-dotenv
├─ Available to all modules
├─ API keys stored here
└─ Not leaked to LLM prompts

Secret Masking:
├─ Extension: error_format/_10_mask_errors.py
├─ Masks sensitive data in errors
├─ Masks API keys in logs
├─ Masks personal info
└─ Before sending to user/logs

Configuration Secrets:
├─ Model provider API keys
├─ Database credentials
├─ Email/SMTP passwords
└─ Stored securely

Secure Storage:
├─ Settings encrypted (optional)
├─ Session tokens secure
├─ HTTPS support via SSL
├─ Secure cookies (HttpOnly, Secure)
└─ CORS configured


SESSION MANAGEMENT

Session State:
├─ Flask session for logged-in users
├─ Agent contexts per session
├─ Isolated message history
├─ Private memory per context
└─ Auto-cleanup on logout

Multi-User Support:
├─ Per-user storage
├─ Isolated chat history
├─ Separate settings
├─ Own memory contexts
└─ No cross-user data leakage


DATA PRIVACY

No Cloud Sync (Default):
├─ All data stored locally
├─ No telemetry sent
├─ No usage analytics
├─ User owns all data
└─ GDPR compliant

Optional Cloud:
├─ Can be deployed to cloud
├─ Full data control with user
├─ Encrypted backups
├─ Export all data
└─ Delete all data


AUDIT & LOGGING

Chat Logs:
├─ All conversations saved
├─ HTML and JSON formats
├─ Timestamped
├─ Can be exported
└─ Can be deleted

API Logs:
├─ API calls logged
├─ Endpoint, method, status
├─ Timestamp
├─ User (if authenticated)
└─ Accessible via API

Tool Execution Logs:
├─ Each tool call logged
├─ Arguments logged
├─ Results logged
├─ Errors logged
└─ Timing information

Memory Logs:
├─ Memory operations logged
├─ Save/load/delete tracked
├─ Timestamps recorded
└─ Source documented
```

---

## Frontend Architecture

```
┌──────────────────────────────────────────────────────────────┐
│          WEB UI ARCHITECTURE (Vanilla JS + Alpine)          │
└──────────────────────────────────────────────────────────────┘

HTML STRUCTURE

index.html (Main App)
├─ <html>
├─ <head>
│  ├─ <meta> tags (viewport, charset, etc.)
│  ├─ <link> stylesheets (CSS files)
│  ├─ <script> vendor libraries (Alpine, Marked, etc.)
│  └─ <script> app initialization (index.js)
│
└─ <body>
   ├─ <div id="app"> [main app container]
   │  ├─ Header/Toolbar
   │  ├─ Left Sidebar
   │  │  ├─ Chat list
   │  │  ├─ Quick actions
   │  │  └─ Tasks list
   │  │
   │  ├─ Center Chat Panel
   │  │  ├─ Messages container
   │  │  ├─ Message display components
   │  │  └─ Input area
   │  │
   │  └─ Modals (hidden, shown via Alpine)
   │     ├─ Settings modal
   │     ├─ Confirm dialogs
   │     ├─ File browser
   │     └─ Other dialogs
   │
   └─ <script> app code (index.js, components.js, etc.)


COMPONENT STRUCTURE

Components in: /webui/components/
├─ /sidebar/
│  ├─ left-sidebar.html
│  ├─ /top-section/
│  │  ├─ sidebar-top.html
│  │  ├─ header-icons.html
│  │  └─ quick-actions.html
│  ├─ /chats/
│  │  ├─ chats-list.html
│  │  └─ chats-store.js
│  ├─ /tasks/
│  │  ├─ tasks-list.html
│  │  └─ tasks-store.js
│  └─ sidebar-store.js
│
├─ /chat/
│  ├─ chat-display.html
│  ├─ message-item.html
│  ├─ message-content.html
│  └─ messages-store.js
│
├─ /toolbar/
│  ├─ top-toolbar.html
│  ├─ audio-controls.html
│  └─ toolbar-store.js
│
├─ /input/
│  ├─ message-input.html
│  ├─ input-store.js
│  └─ /attachments/
│     ├─ attachments-display.html
│     └─ attachments-store.js
│
├─ /settings/
│  ├─ settings-panel.html
│  ├─ settings-store.js
│  └─ [various setting components]
│
├─ /modals/
│  ├─ confirm-dialog.html
│  ├─ file-browser.html
│  ├─ modals.html
│  └─ modals-store.js
│
└─ /notifications/
   ├─ notifications-list.html
   └─ notifications-store.js


JAVASCRIPT MODULES

/webui/js/
├─ index.js              Main app initialization
├─ index.css             Main stylesheet
│
├─ api.js                API communication client
│                        ├─ fetch wrapper
│                        ├─ WebSocket handling
│                        ├─ Error handling
│                        └─ Token management
│
├─ components.js         Component utilities
│                        ├─ Component registration
│                        ├─ Component helpers
│                        └─ Lifecycle management
│
├─ messages.js           Message handling
│                        ├─ Message processing
│                        ├─ Markdown rendering
│                        ├─ Syntax highlighting
│                        └─ Message storage
│
├─ modals.js             Modal dialog system
│                        ├─ Show/hide logic
│                        ├─ Dialog management
│                        └─ Confirm dialogs
│
├─ settings.js           Settings management
│                        ├─ Load settings
│                        ├─ Save settings
│                        ├─ Settings UI
│                        └─ Persistence
│
├─ shortcuts.js          Keyboard shortcuts
│                        ├─ Register shortcuts
│                        ├─ Handle key events
│                        └─ Command execution
│
├─ speech_browser.js     Speech features
│                        ├─ Text-to-speech
│                        ├─ Speech-to-text
│                        ├─ Audio recording
│                        └─ Playback control
│
├─ scheduler.js          Scheduler UI
│                        ├─ Task creation
│                        ├─ Task management
│                        ├─ Date/time picker
│                        └─ Cron UI
│
├─ AlpineStore.js        Alpine.js store
│                        ├─ Global state
│                        ├─ Reactive data
│                        ├─ Store actions
│                        └─ Persistence
│
├─ device.js             Device detection
│                        ├─ Mobile detection
│                        ├─ Platform detection
│                        └─ Feature detection
│
├─ initializer.js        App initialization
│                        ├─ Load config
│                        ├─ Connect to backend
│                        ├─ Setup listeners
│                        └─ Initialize state
│
├─ initFw.js             Framework initialization
├─ sleep.js              Sleep utilities
├─ timeout.js            Timeout management
├─ time-utils.js         Time utilities
├─ css.js                CSS utilities
└─ components.js         Component registration


STATE MANAGEMENT

Alpine Store (Global State):
```javascript
AlpineStore = {
    // Chat state
    messages: [],          // Chat messages
    currentChat: null,     // Active chat
    chats: [],            // Chat history

    // Settings
    settings: {},         // User settings
    models: [],          // Available models

    // UI state
    sidebarOpen: true,    // Sidebar visibility
    settingsOpen: false,  // Settings modal
    selectedText: "",     // Text selection

    // Agent state
    isLoading: false,     // Agent processing
    isPaused: false,      // Agent paused

    // Memory
    memories: [],         // Memory entries

    // Notifications
    notifications: [],    // Notification list

    // Tasks
    tasks: [],           // Scheduled tasks

    // Methods
    addMessage(msg),
    loadChat(id),
    saveSetting(key, value),
    // ... more methods
}
```

WebSocket State:
├─ Connection status
├─ Reconnection logic
├─ Message queue
└─ Backpressure handling


RENDERING PIPELINE

Message Display:
1. Message object created
2. Markdown parsed (Marked.js)
3. KaTeX math rendered
4. Code syntax highlighted (Ace)
5. HTML sanitized
6. Injected into DOM
7. Listeners attached

Tool Call Display:
1. Tool execution logged
2. Progress updates streamed
3. Arguments displayed
4. Result rendered
5. History updated

Response Streaming:
1. WebSocket message received
2. Token appended to response
3. Markdown re-rendered
4. Displayed in UI
5. Scroll to bottom


REAL-TIME UPDATES

WebSocket Connection:
├─ Connect on page load
├─ Automatic reconnect on disconnect
├─ Heartbeat/ping-pong
└─ Message queue on disconnect

Message Streaming:
├─ Text chunks streamed
├─ Tokens as they arrive
├─ Real-time rendering
├─ No batching (instant updates)
└─ Smooth scrolling

Tool Updates:
├─ Tool execution start
├─ Progress updates
├─ Tool completion
└─ Result injection


USER INTERACTIONS

Chat Input:
├─ Text input field
├─ Multi-line support
├─ Submit on Enter/Cmd+Enter
├─ File attachment drag/drop
├─ Image paste support
└─ Auto-save drafts

Sidebar Interactions:
├─ Click chat to load
├─ Hover for options
├─ Delete chat
├─ Rename chat
├─ New chat
└─ Create folder

Settings:
├─ Model selection
├─ API key configuration
├─ Behavior adjustments
├─ UI preferences
├─ Feature toggles
└─ Auto-save

Notifications:
├─ Toast notifications
├─ Notification history
├─ Mark as read
├─ Clear notifications
└─ Sound alerts (optional)


KEYBOARD SHORTCUTS

Common:
├─ Cmd/Ctrl + Enter: Send message
├─ Cmd/Ctrl + K: Focus search
├─ Cmd/Ctrl + ,: Open settings
├─ Escape: Close modals
├─ ?: Help/shortcuts list
└─ (Customizable in settings)

Editor:
├─ Tab: Indent
├─ Shift+Tab: Dedent
├─ Cmd/Ctrl + B: Bold
├─ Cmd/Ctrl + I: Italic
└─ Cmd/Ctrl + /: Toggle comment
```

---

## Conclusion

This architecture visualization shows Agent Zero's sophisticated multi-layered system:

1. **Message Loop** - The beating heart, processing user messages through LLM reasoning and tool execution
2. **Extension System** - 24 customization points allowing non-invasive modifications
3. **Tool Subsystem** - Dynamic tool discovery and execution for capability extension
4. **Memory System** - FAISS-based semantic memory for persistent learning
5. **Prompt System** - 100+ modular prompts defining all behavior
6. **Multi-Provider LLM** - LiteLLM abstraction supporting 20+ providers
7. **Web UI** - Real-time streaming reactive interface
8. **Security Layer** - Authentication, rate limiting, sandboxing, secrets management

The architecture demonstrates enterprise-grade design with clear separation of concerns, non-invasive customization mechanisms, and comprehensive feature support.

