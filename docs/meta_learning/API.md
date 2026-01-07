# Meta-Learning Dashboard API Documentation

## Overview

The Meta-Learning Dashboard API provides endpoints for monitoring and managing Agent Zero's self-evolving capabilities. This includes accessing meta-analyses, reviewing prompt refinement suggestions, managing prompt versions, and applying approved changes.

**Base Endpoint:** `/meta_learning`

**Authentication:** Requires authentication (inherits from ApiHandler)

**CSRF Protection:** Enabled for state-changing operations

**Methods:** GET, POST

---

## Endpoints

All endpoints are accessed via the `/meta_learning` route with different `action` parameters.

### 1. List Meta-Analyses

Get recent meta-analyses from the SOLUTIONS memory area.

**Action:** `list_analyses`

**Method:** GET or POST

**Request Parameters:**
```json
{
  "action": "list_analyses",
  "memory_subdir": "default",  // Optional, default: "default"
  "limit": 20,                 // Optional, default: 20
  "search": ""                 // Optional, semantic search query
}
```

**Response:**
```json
{
  "success": true,
  "analyses": [
    {
      "id": "unique_analysis_id",
      "timestamp": "2026-01-05T12:00:00",
      "content": "Full analysis content...",
      "preview": "First 200 chars...",
      "metadata": {
        "area": "solutions",
        "meta_learning": true
      },
      "structured": {
        "prompt_refinements": [...],
        "tool_suggestions": [...],
        "performance_patterns": [...]
      }
    }
  ],
  "total_count": 15,
  "memory_subdir": "default"
}
```

**Example:**
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: YOUR_TOKEN" \
  -d '{
    "action": "list_analyses",
    "limit": 10
  }'
```

---

### 2. Get Specific Analysis

Retrieve detailed information about a specific meta-analysis.

**Action:** `get_analysis`

**Method:** GET or POST

**Request Parameters:**
```json
{
  "action": "get_analysis",
  "analysis_id": "analysis_id_here",  // Required
  "memory_subdir": "default"          // Optional, default: "default"
}
```

**Response:**
```json
{
  "success": true,
  "analysis": {
    "id": "analysis_id",
    "timestamp": "2026-01-05T12:00:00",
    "content": "Full analysis content",
    "metadata": {...},
    "structured": {
      "prompt_refinements": [
        {
          "target_file": "agent.system.main.md",
          "description": "Improve error handling instructions",
          "rationale": "Agent frequently fails to catch exceptions",
          "suggested_change": "Updated prompt content...",
          "confidence": 0.85,
          "priority": "high"
        }
      ],
      "tool_suggestions": [...],
      "performance_patterns": [...]
    }
  }
}
```

**Example:**
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: YOUR_TOKEN" \
  -d '{
    "action": "get_analysis",
    "analysis_id": "abc123"
  }'
```

---

### 3. List Prompt Suggestions

Get pending prompt refinement suggestions extracted from recent analyses.

**Action:** `list_suggestions`

**Method:** GET or POST

**Request Parameters:**
```json
{
  "action": "list_suggestions",
  "memory_subdir": "default",  // Optional, default: "default"
  "status": "pending",         // Optional: "pending", "applied", "rejected", or "" (all)
  "limit": 50                  // Optional, default: 50
}
```

**Response:**
```json
{
  "success": true,
  "suggestions": [
    {
      "id": "analysis_id_ref_0",
      "analysis_id": "analysis_id",
      "timestamp": "2026-01-05T12:00:00",
      "type": "prompt_refinement",
      "target_file": "agent.system.main.md",
      "description": "Add error handling guidance",
      "rationale": "Detected pattern of missed exceptions",
      "suggested_change": "Updated prompt content...",
      "confidence": 0.85,
      "status": "pending",
      "priority": "high"
    },
    {
      "id": "analysis_id_tool_0",
      "analysis_id": "analysis_id",
      "timestamp": "2026-01-05T12:00:00",
      "type": "new_tool",
      "tool_name": "file_diff_tool",
      "description": "Compare file versions",
      "rationale": "Agent frequently needs to compare files",
      "confidence": 0.75,
      "status": "pending",
      "priority": "medium"
    }
  ],
  "total_count": 12,
  "memory_subdir": "default"
}
```

**Suggestion Types:**
- `prompt_refinement`: Suggested changes to existing prompts
- `new_tool`: Suggestions for new tools to build

**Status Values:**
- `pending`: Not yet reviewed/applied
- `applied`: Successfully applied to system
- `rejected`: Reviewed and rejected by user

**Priority Levels:**
- `high`: Critical improvements
- `medium`: Beneficial enhancements
- `low`: Nice-to-have improvements

**Example:**
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: YOUR_TOKEN" \
  -d '{
    "action": "list_suggestions",
    "status": "pending",
    "limit": 20
  }'
```

---

### 4. Apply Suggestion

Apply a specific prompt refinement suggestion with explicit approval.

**Action:** `apply_suggestion`

**Method:** POST

**Request Parameters:**
```json
{
  "action": "apply_suggestion",
  "suggestion_id": "analysis_id_ref_0",  // Required
  "analysis_id": "analysis_id",          // Required
  "memory_subdir": "default",            // Optional, default: "default"
  "approved": true                       // Required: Must be true to apply
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Applied refinement to agent.system.main.md",
  "version_id": "20260105_120000",
  "target_file": "agent.system.main.md",
  "description": "Improve error handling instructions"
}
```

**Response (Not Approved):**
```json
{
  "success": false,
  "error": "Explicit approval required to apply suggestion (approved=True)"
}
```

**Important Notes:**
- Automatically creates a backup version before applying changes
- Only supports `prompt_refinement` type suggestions currently
- Requires `approved: true` to prevent accidental application
- Changes are immediately written to prompt files

**Example:**
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: YOUR_TOKEN" \
  -d '{
    "action": "apply_suggestion",
    "suggestion_id": "abc123_ref_0",
    "analysis_id": "abc123",
    "approved": true
  }'
```

---

### 5. Trigger Meta-Analysis

Manually trigger a meta-analysis on recent agent history.

**Action:** `trigger_analysis`

**Method:** POST

**Request Parameters:**
```json
{
  "action": "trigger_analysis",
  "context_id": "",      // Optional, creates new context if empty
  "background": false    // Optional, run in background (default: false)
}
```

**Response (Foreground):**
```json
{
  "success": true,
  "message": "Meta-analysis completed. Found 5 prompt refinements and 2 tool suggestions.",
  "context_id": "context_123",
  "analysis_complete": true
}
```

**Response (Background):**
```json
{
  "success": true,
  "message": "Meta-analysis started in background",
  "context_id": "context_123"
}
```

**Configuration:**
Meta-analysis behavior is controlled by environment variables:
- `ENABLE_PROMPT_EVOLUTION=true` - Enable meta-learning (required)
- `PROMPT_EVOLUTION_MIN_INTERACTIONS=20` - Minimum history size
- `PROMPT_EVOLUTION_MAX_HISTORY=100` - Maximum messages to analyze
- `PROMPT_EVOLUTION_CONFIDENCE_THRESHOLD=0.7` - Minimum confidence for suggestions
- `AUTO_APPLY_PROMPT_EVOLUTION=false` - Auto-apply high-confidence suggestions

**Example:**
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: YOUR_TOKEN" \
  -d '{
    "action": "trigger_analysis",
    "background": true
  }'
```

---

### 6. List Prompt Versions

List prompt version history with metadata.

**Action:** `list_versions`

**Method:** GET or POST

**Request Parameters:**
```json
{
  "action": "list_versions",
  "limit": 20  // Optional, default: 20
}
```

**Response:**
```json
{
  "success": true,
  "versions": [
    {
      "version_id": "20260105_120000",
      "timestamp": "2026-01-05T12:00:00",
      "label": null,
      "file_count": 95,
      "changes": [
        {
          "file": "agent.system.main.md",
          "description": "Improve error handling",
          "timestamp": "2026-01-05T12:00:00"
        }
      ],
      "created_by": "meta_learning"
    },
    {
      "version_id": "20260104_150000",
      "timestamp": "2026-01-04T15:00:00",
      "label": "pre_rollback_20260105_120000",
      "file_count": 95,
      "changes": [],
      "created_by": "manual"
    }
  ],
  "total_count": 15
}
```

**Version Metadata:**
- `version_id`: Unique identifier (timestamp-based or custom label)
- `timestamp`: When the version was created
- `label`: Optional human-readable label
- `file_count`: Number of prompt files in snapshot
- `changes`: List of changes that triggered this version
- `created_by`: "meta_learning" (automatic) or "manual" (user-created)

**Example:**
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: YOUR_TOKEN" \
  -d '{
    "action": "list_versions",
    "limit": 30
  }'
```

---

### 7. Rollback to Previous Version

Restore prompts to a previous version.

**Action:** `rollback_version`

**Method:** POST

**Request Parameters:**
```json
{
  "action": "rollback_version",
  "version_id": "20260104_150000",  // Required
  "create_backup": true             // Optional, default: true
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Successfully rolled back to version 20260104_150000",
  "version_id": "20260104_150000",
  "backup_created": true
}
```

**Response (Version Not Found):**
```json
{
  "success": false,
  "error": "Version 20260104_150000 not found"
}
```

**Important Notes:**
- Automatically creates a backup of current state before rollback (unless `create_backup: false`)
- Restores all prompt files from the specified version
- Cannot be undone (except by rolling back to another version)
- Backup version is labeled as `pre_rollback_{version_id}`

**Example:**
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: YOUR_TOKEN" \
  -d '{
    "action": "rollback_version",
    "version_id": "20260104_150000",
    "create_backup": true
  }'
```

---

## Error Handling

All endpoints return a consistent error format:

```json
{
  "success": false,
  "error": "Detailed error message"
}
```

**Common Error Codes:**
- `400 Bad Request`: Missing required parameters or invalid action
- `403 Forbidden`: CSRF token missing/invalid or unauthorized
- `404 Not Found`: Analysis/version ID not found
- `500 Internal Server Error`: Server-side processing error

---

## Integration Examples

### JavaScript (Frontend)

```javascript
// List recent analyses
async function listAnalyses() {
  const response = await fetch('/meta_learning', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': getCsrfToken()
    },
    body: JSON.stringify({
      action: 'list_analyses',
      limit: 10
    })
  });

  const data = await response.json();
  return data.analyses;
}

// Apply a suggestion
async function applySuggestion(suggestionId, analysisId) {
  const response = await fetch('/meta_learning', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': getCsrfToken()
    },
    body: JSON.stringify({
      action: 'apply_suggestion',
      suggestion_id: suggestionId,
      analysis_id: analysisId,
      approved: true
    })
  });

  return await response.json();
}
```

### Python (Client)

```python
import requests

class MetaLearningClient:
    def __init__(self, base_url="http://localhost:50001", csrf_token=None):
        self.base_url = base_url
        self.session = requests.Session()
        if csrf_token:
            self.session.headers.update({'X-CSRF-Token': csrf_token})

    def list_suggestions(self, status="pending", limit=50):
        """Get pending suggestions"""
        response = self.session.post(
            f"{self.base_url}/meta_learning",
            json={
                "action": "list_suggestions",
                "status": status,
                "limit": limit
            }
        )
        return response.json()

    def apply_suggestion(self, suggestion_id, analysis_id):
        """Apply a suggestion with approval"""
        response = self.session.post(
            f"{self.base_url}/meta_learning",
            json={
                "action": "apply_suggestion",
                "suggestion_id": suggestion_id,
                "analysis_id": analysis_id,
                "approved": True
            }
        )
        return response.json()

    def trigger_analysis(self, background=True):
        """Trigger meta-analysis"""
        response = self.session.post(
            f"{self.base_url}/meta_learning",
            json={
                "action": "trigger_analysis",
                "background": background
            }
        )
        return response.json()
```

---

## Security Considerations

1. **CSRF Protection:** All state-changing operations (POST) require valid CSRF token
2. **Authentication:** Inherits authentication from ApiHandler (session-based)
3. **Explicit Approval:** Suggestion application requires `approved: true` parameter
4. **Automatic Backups:** Version rollbacks automatically create backups
5. **Version Control:** All prompt changes are versioned and reversible

---

## Data Flow

### Meta-Analysis Lifecycle

```
1. Agent Interaction
   ↓
2. Solutions Memorized (Extension: _51_memorize_solutions.py)
   ↓
3. Meta-Analysis Triggered (Manual or Automatic)
   ├─ Tool: prompt_evolution.py
   ├─ Analyzes recent history
   ├─ Generates suggestions
   └─ Stores in SOLUTIONS memory
   ↓
4. Dashboard Access
   ├─ API: list_analyses
   ├─ API: list_suggestions
   └─ User reviews
   ↓
5. Suggestion Application (Optional)
   ├─ API: apply_suggestion
   ├─ Versioning: Creates backup
   ├─ File Update: Modifies prompt
   └─ System Evolution
   ↓
6. Rollback (If Needed)
   └─ API: rollback_version
```

---

## Related Components

- **Tool:** `/python/tools/prompt_evolution.py` - Meta-analysis engine
- **Helper:** `/python/helpers/prompt_versioning.py` - Version management
- **Helper:** `/python/helpers/memory.py` - Memory storage (SOLUTIONS area)
- **Extension:** `/python/extensions/monologue_end/_51_memorize_solutions.py` - Auto-memorization
- **API:** `/python/api/memory_dashboard.py` - Memory management dashboard

---

## Environment Configuration

```bash
# Enable meta-learning
ENABLE_PROMPT_EVOLUTION=true

# Meta-analysis thresholds
PROMPT_EVOLUTION_MIN_INTERACTIONS=20
PROMPT_EVOLUTION_MAX_HISTORY=100
PROMPT_EVOLUTION_CONFIDENCE_THRESHOLD=0.7

# Auto-apply high-confidence suggestions (use with caution)
AUTO_APPLY_PROMPT_EVOLUTION=false
```

---

## Maintenance

### Version Cleanup

The version system can accumulate many snapshots over time. Use the `PromptVersionManager` directly to clean up old versions:

```python
from python.helpers.prompt_versioning import PromptVersionManager

manager = PromptVersionManager()
deleted_count = manager.delete_old_versions(keep_count=50)
print(f"Deleted {deleted_count} old versions")
```

### Memory Management

Meta-analyses are stored in the SOLUTIONS memory area. Use the memory dashboard API to manage:

```bash
curl -X POST http://localhost:50001/memory_dashboard \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: YOUR_TOKEN" \
  -d '{
    "action": "search",
    "memory_subdir": "default",
    "area": "solutions",
    "limit": 100
  }'
```

---

## Future Enhancements

Planned improvements for the meta-learning API:

1. **Tool Application**: Support applying `new_tool` suggestions (auto-generate tool files)
2. **A/B Testing**: Compare performance before/after prompt changes
3. **Suggestion Voting**: Community voting on suggestions (multi-user setups)
4. **Impact Metrics**: Track effectiveness of applied suggestions
5. **Export/Import**: Share successful prompt evolutions between instances
6. **Scheduled Analysis**: Periodic automatic meta-analysis
7. **Diff Visualization**: Visual comparison of prompt versions

---

## Troubleshooting

### No Analyses Found
- Ensure `ENABLE_PROMPT_EVOLUTION=true` in environment
- Trigger meta-analysis manually via `trigger_analysis` action
- Check that agent has sufficient history (min 20 interactions)

### Suggestion Application Fails
- Verify CSRF token is valid
- Ensure `approved: true` is included
- Check file permissions on `prompts/` directory
- Review logs for specific error messages

### Rollback Not Working
- Verify version_id exists via `list_versions`
- Check file permissions on `prompts/` and `prompts/versioned/`
- Ensure enough disk space for backups

---

## Support

For issues or questions:
- GitHub Issues: https://github.com/frdel/agent-zero
- Documentation: `/docs/`
- Knowledge Base: Stored in Agent Zero's memory system
