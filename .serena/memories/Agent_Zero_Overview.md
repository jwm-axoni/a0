# Agent Zero - Project Overview

## What is Agent Zero?
Agent Zero is a dynamic, open-source agentic AI framework designed as a personal assistant that grows and learns through use. It's not a pre-programmed solution but a general-purpose framework that uses the computer as a tool to accomplish goals through hierarchical multi-agent cooperation, persistent memory, and extensible tool systems.

## Key Facts
- **Version:** v0.9.7 (Projects feature with isolated workspaces)
- **Language:** Python (backend) + JavaScript (frontend)
- **Repository:** 1,066 files, ~5M tokens, 14.66M characters
- **Core:** 922-line agent.py with message loop at line 356
- **Tools:** 20+ built-in tools
- **Extensions:** 24 customization points
- **Prompts:** 100+ system prompt files
- **API:** 61+ REST endpoints
- **Fully Dockerized** with web UI and CLI interfaces

## Core Philosophy
Everything is prompt-driven with zero hard-coded logic. The framework is completely customizable and extensible through:
- 24+ extension points
- Dynamic tool discovery
- Hierarchical prompt system
- Persistent memory with semantic search
- Multi-agent cooperation

## Six Core Subsystems
1. **Tool System** - 20+ dynamic tools for code execution, web browsing, memory, search
2. **Memory System** - FAISS vector database with 4 memory areas (MAIN, FRAGMENTS, SOLUTIONS, INSTRUMENTS)
3. **Extension System** - 24 hook points for non-invasive customization
4. **Prompt System** - 100+ prompt files organized hierarchically
5. **API System** - 61+ REST endpoints for chat, settings, memory, projects
6. **Web UI** - Vanilla JavaScript + Alpine.js with real-time WebSocket streaming

## The Message Loop (agent.py:356)
The heart of Agent Zero is the async `monologue()` method:
1. Builds system prompt from prompts and extensions
2. Loads message history
3. Calls LLM with streaming
4. Extracts tools from response
5. Executes tools
6. Adds results to history
7. Loops until response_tool is used

This loop is the "heartbeat" of the framework - everything else supports it.

## Key Architectural Patterns
1. **Async-First Design** - Entire system uses async/await, non-blocking operations
2. **Extension Hooks** - 24+ customization points, numbered files execute in order
3. **Hierarchical Context** - Nested agent contexts with shared access to memory
4. **Tool-Based Abstraction** - No hard-coded capabilities; everything is a tool
5. **Prompt-Driven Behavior** - System prompts define all agent behavior (100+ files)
6. **Dynamic Composition** - Tools, prompts, extensions loaded at runtime
7. **Streaming Communication** - Real-time output via WebSocket to UI
8. **Vector Memory** - FAISS for semantic search of persistent knowledge

## Technology Stack
- **Backend:** Python with Flask, async/await
- **Frontend:** Vanilla JavaScript + Alpine.js
- **LLM Integration:** LiteLLM (supports 20+ providers)
- **Memory:** FAISS vector database
- **Language Analysis:** Solid-LSP (language servers)
- **Containerization:** Docker with multi-stage builds
- **Testing:** pytest framework
