# Self-Evolving Meta-Layer Documentation Index

This file provides a complete map to all documentation for Agent Zero's Self-Evolving Meta-Layer.

---

## 🎯 **Start Here**

### Primary Documentation
1. **[Main User Guide](docs/meta_learning.md)** - Comprehensive guide covering everything
   - What is meta-learning?
   - Architecture and components
   - Configuration guide
   - Usage patterns (manual and auto)
   - Safety features
   - Best practices
   - Troubleshooting

2. **[Quick Start](tests/meta_learning/QUICKSTART.md)** - Get running in 5 minutes
   - TL;DR commands
   - Essential configuration
   - Quick testing

---

## 📚 **Core Documentation**

### Implementation Guides
- **[Meta-Learning API Implementation](META_LEARNING_API_IMPLEMENTATION.md)** - API architecture and integration
- **[Tool Suggestions Implementation](TOOL_SUGGESTIONS_IMPLEMENTATION.md)** - Gap analysis system details

### Configuration
- **[example.env](example.env)** - Environment variable template with all meta-learning settings
- **[Meta-Analysis System Prompt](prompts/meta_learning.analyze.sys.md)** - Utility LLM prompt for analysis

### Architecture Reference
- **[CLAUDE.md](CLAUDE.md)** - Updated with meta-learning system integration (see "Meta-Learning System" section)

---

## 🔧 **Component Documentation**

### Tool Suggestions System
- **[Tool Suggestions README](python/helpers/TOOL_SUGGESTIONS_README.md)** - Complete API reference (450 lines)
  - Architecture overview
  - Pattern detection details
  - Usage examples
  - Integration guides
  - Best practices

- **[Tool Suggestions Quick Reference](python/helpers/TOOL_SUGGESTIONS_QUICK_REF.md)** - Cheat sheet (350 lines)
  - Common workflows
  - Code snippets
  - One-liner examples

### API Dashboard
- **[Meta-Learning API Documentation](docs/api/meta_learning_api.md)** - Complete API reference (681 lines)
  - 7 endpoint descriptions
  - Request/response examples (curl, JavaScript, Python)
  - Security considerations
  - Error handling
  - Troubleshooting

- **[API Quick Reference](docs/api/meta_learning_quick_reference.md)** - API cheat sheet (334 lines)
  - Quick code snippets
  - Common patterns
  - Client library examples

---

## 🧪 **Testing Documentation**

### Test Guides
- **[Tests README](tests/meta_learning/README_TESTS.md)** - Comprehensive testing guide
  - How to run tests
  - Test structure
  - Adding new tests
  - CI/CD integration

- **[Test Summary](tests/meta_learning/TEST_SUMMARY.md)** - Detailed coverage breakdown
  - 19 test scenarios documented
  - Coverage analysis
  - Mock data structure

- **[Test Architecture](tests/meta_learning/TEST_ARCHITECTURE.md)** - Visual diagrams
  - Component interaction diagrams
  - Data flow charts
  - Test patterns

- **[Test Index](tests/meta_learning/INDEX.md)** - File index and quick reference

- **[Deliverables](tests/meta_learning/DELIVERABLES.md)** - Complete project summary

---

## 📁 **File Locations**

### Core Implementation Files
```
python/
├── tools/
│   └── prompt_evolution.py              # Meta-analysis engine (500 lines)
├── helpers/
│   ├── prompt_versioning.py             # Version control system (430 lines)
│   └── tool_suggestions.py              # Gap analysis (750 lines)
├── extensions/
│   └── monologue_end/
│       └── _85_prompt_evolution.py      # Auto-trigger extension
└── api/
    └── meta_learning.py                 # REST API with 7 endpoints (663 lines)
```

### Test Files
```
tests/
├── meta_learning/
│   ├── test_prompt_versioning.py        # Pytest suite (500+ lines)
│   ├── manual_test_versioning.py        # Manual tests (150 lines)
│   ├── manual_test_prompt_evolution.py  # Evolution tests (532 lines)
│   └── verify_test_structure.py         # Structure validator (151 lines)
└── test_meta_learning_api.py            # API tests (520 lines)
```

### Configuration Files
```
example.env                               # Environment variable template
prompts/meta_learning.analyze.sys.md     # System prompt for meta-analysis
prompts/versioned/                        # Version control directory (created automatically)
```

### Documentation Files
```
docs/
├── meta_learning.md                     # Main user guide (1000+ lines)
└── api/
    ├── meta_learning_api.md             # API documentation (681 lines)
    └── meta_learning_quick_reference.md # API quick ref (334 lines)

python/helpers/
├── TOOL_SUGGESTIONS_README.md           # Tool suggestions guide (450 lines)
└── TOOL_SUGGESTIONS_QUICK_REF.md        # Tool suggestions quick ref (350 lines)

tests/meta_learning/
├── QUICKSTART.md                        # Quick start guide
├── README_TESTS.md                      # Testing guide
├── TEST_SUMMARY.md                      # Coverage details
├── TEST_ARCHITECTURE.md                 # Visual diagrams
├── INDEX.md                             # File index
└── DELIVERABLES.md                      # Project summary

META_LEARNING_API_IMPLEMENTATION.md      # API implementation guide (498 lines)
TOOL_SUGGESTIONS_IMPLEMENTATION.md       # Tool suggestions guide (600 lines)
CLAUDE.md                                # Updated with meta-learning (see sections)
META_LEARNING_INDEX.md                   # This file (documentation map)
```

---

## 🎓 **Documentation by Role**

### For End Users
1. Start: [docs/meta_learning.md](docs/meta_learning.md)
2. Quick setup: [tests/meta_learning/QUICKSTART.md](tests/meta_learning/QUICKSTART.md)
3. Configuration: [example.env](example.env)
4. Troubleshooting: See "Troubleshooting" section in main guide

### For Developers
1. Architecture: [CLAUDE.md](CLAUDE.md) - "Meta-Learning System" section
2. API reference: [docs/api/meta_learning_api.md](docs/api/meta_learning_api.md)
3. Component docs:
   - [python/helpers/TOOL_SUGGESTIONS_README.md](python/helpers/TOOL_SUGGESTIONS_README.md)
   - [META_LEARNING_API_IMPLEMENTATION.md](META_LEARNING_API_IMPLEMENTATION.md)
4. Testing: [tests/meta_learning/README_TESTS.md](tests/meta_learning/README_TESTS.md)

### For System Integrators
1. API quick ref: [docs/api/meta_learning_quick_reference.md](docs/api/meta_learning_quick_reference.md)
2. Tool suggestions quick ref: [python/helpers/TOOL_SUGGESTIONS_QUICK_REF.md](python/helpers/TOOL_SUGGESTIONS_QUICK_REF.md)
3. Implementation guides:
   - [META_LEARNING_API_IMPLEMENTATION.md](META_LEARNING_API_IMPLEMENTATION.md)
   - [TOOL_SUGGESTIONS_IMPLEMENTATION.md](TOOL_SUGGESTIONS_IMPLEMENTATION.md)

---

## 📊 **Documentation Statistics**

| Category | Files | Lines | Description |
|----------|-------|-------|-------------|
| User Guides | 2 | ~1,500 | Main guide + quickstart |
| API Documentation | 3 | ~1,500 | API reference + implementation + quick ref |
| Component Docs | 3 | ~1,500 | Tool suggestions + implementation guides |
| Test Documentation | 6 | ~2,000 | Test guides, summaries, architecture |
| Configuration | 2 | ~500 | Environment template + system prompt |
| Architecture | 1 | Updated | CLAUDE.md with meta-learning integration |
| **TOTAL** | **17** | **~7,000+** | **Complete documentation suite** |

---

## 🚀 **Recommended Reading Order**

### First-Time Users
1. [tests/meta_learning/QUICKSTART.md](tests/meta_learning/QUICKSTART.md) - Get started fast
2. [docs/meta_learning.md](docs/meta_learning.md) - Deep dive
3. [example.env](example.env) - Configure your system

### Developers Extending the System
1. [CLAUDE.md](CLAUDE.md) - Understand the architecture
2. [python/helpers/TOOL_SUGGESTIONS_README.md](python/helpers/TOOL_SUGGESTIONS_README.md) - Component API
3. [META_LEARNING_API_IMPLEMENTATION.md](META_LEARNING_API_IMPLEMENTATION.md) - Integration patterns
4. [tests/meta_learning/README_TESTS.md](tests/meta_learning/README_TESTS.md) - Testing approach

### API Consumers
1. [docs/api/meta_learning_quick_reference.md](docs/api/meta_learning_quick_reference.md) - Quick API examples
2. [docs/api/meta_learning_api.md](docs/api/meta_learning_api.md) - Complete API reference

---

## 🔍 **Quick Find**

Need to find something specific? Use this quick reference:

- **How to enable**: See [example.env](example.env) - `ENABLE_PROMPT_EVOLUTION`
- **API endpoints**: [docs/api/meta_learning_api.md](docs/api/meta_learning_api.md)
- **Test examples**: [tests/meta_learning/manual_test_prompt_evolution.py](tests/meta_learning/manual_test_prompt_evolution.py)
- **Configuration options**: [docs/meta_learning.md](docs/meta_learning.md) - "Configuration" section
- **Troubleshooting**: [docs/meta_learning.md](docs/meta_learning.md) - "Troubleshooting" section
- **Pattern detection**: [python/helpers/TOOL_SUGGESTIONS_README.md](python/helpers/TOOL_SUGGESTIONS_README.md)
- **Version management**: [docs/meta_learning.md](docs/meta_learning.md) - "Version Management" section
- **Safety features**: [docs/meta_learning.md](docs/meta_learning.md) - "Safety Features" section

---

## 📝 **Documentation Updates**

This documentation suite was created as part of the Self-Evolving Meta-Layer implementation (January 2026).

**Last Updated**: January 5, 2026

**Status**: ✅ Complete and production-ready

For questions or updates, refer to the main user guide: [docs/meta_learning.md](docs/meta_learning.md)
