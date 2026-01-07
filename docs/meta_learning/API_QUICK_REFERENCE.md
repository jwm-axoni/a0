# Meta-Learning API Quick Reference

## Endpoint: `/meta_learning`

**Methods:** GET, POST
**Auth:** Required
**CSRF:** Required for POST

---

## Quick Actions

### List Recent Analyses
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: $TOKEN" \
  -d '{"action": "list_analyses", "limit": 10}'
```

### Get Pending Suggestions
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: $TOKEN" \
  -d '{"action": "list_suggestions", "status": "pending"}'
```

### Apply a Suggestion
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: $TOKEN" \
  -d '{
    "action": "apply_suggestion",
    "suggestion_id": "SUGGESTION_ID",
    "analysis_id": "ANALYSIS_ID",
    "approved": true
  }'
```

### Trigger Meta-Analysis
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: $TOKEN" \
  -d '{"action": "trigger_analysis", "background": true}'
```

### List Versions
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: $TOKEN" \
  -d '{"action": "list_versions", "limit": 20}'
```

### Rollback Version
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: $TOKEN" \
  -d '{
    "action": "rollback_version",
    "version_id": "20260105_120000",
    "create_backup": true
  }'
```

---

## JavaScript Snippets

### Fetch Suggestions
```javascript
async function getSuggestions() {
  const res = await fetch('/meta_learning', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': getCsrfToken()
    },
    body: JSON.stringify({
      action: 'list_suggestions',
      status: 'pending',
      limit: 50
    })
  });
  const data = await res.json();
  return data.suggestions;
}
```

### Apply Suggestion with Confirmation
```javascript
async function applySuggestionWithConfirm(suggestionId, analysisId) {
  if (!confirm('Apply this suggestion? This will modify prompt files.')) {
    return;
  }

  const res = await fetch('/meta_learning', {
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

  const result = await res.json();
  if (result.success) {
    alert(`Applied: ${result.message}\nBackup: ${result.version_id}`);
  } else {
    alert(`Error: ${result.error}`);
  }
}
```

---

## Python Client

```python
import requests

class MetaLearningClient:
    def __init__(self, base_url="http://localhost:50001", csrf_token=None):
        self.base_url = base_url
        self.csrf_token = csrf_token

    def _post(self, action, **params):
        headers = {'Content-Type': 'application/json'}
        if self.csrf_token:
            headers['X-CSRF-Token'] = self.csrf_token

        response = requests.post(
            f"{self.base_url}/meta_learning",
            json={"action": action, **params},
            headers=headers
        )
        return response.json()

    def list_analyses(self, limit=20):
        return self._post("list_analyses", limit=limit)

    def get_analysis(self, analysis_id):
        return self._post("get_analysis", analysis_id=analysis_id)

    def list_suggestions(self, status="pending", limit=50):
        return self._post("list_suggestions", status=status, limit=limit)

    def apply_suggestion(self, suggestion_id, analysis_id):
        return self._post(
            "apply_suggestion",
            suggestion_id=suggestion_id,
            analysis_id=analysis_id,
            approved=True
        )

    def trigger_analysis(self, background=True):
        return self._post("trigger_analysis", background=background)

    def list_versions(self, limit=20):
        return self._post("list_versions", limit=limit)

    def rollback_version(self, version_id, create_backup=True):
        return self._post(
            "rollback_version",
            version_id=version_id,
            create_backup=create_backup
        )

# Usage
client = MetaLearningClient(csrf_token="YOUR_TOKEN")

# Get pending suggestions
suggestions = client.list_suggestions(status="pending")
for s in suggestions['suggestions']:
    print(f"{s['type']}: {s['description']} (confidence: {s['confidence']})")

# Apply a suggestion
result = client.apply_suggestion("suggestion_123", "analysis_456")
print(f"Applied: {result['message']}")
```

---

## Common Workflows

### Review and Apply Suggestions
```python
# 1. List pending suggestions
suggestions_response = client.list_suggestions(status="pending")
suggestions = suggestions_response['suggestions']

# 2. Filter high-confidence suggestions
high_confidence = [s for s in suggestions if s['confidence'] > 0.8]

# 3. Review and apply each
for suggestion in high_confidence:
    print(f"\nSuggestion: {suggestion['description']}")
    print(f"Target: {suggestion['target_file']}")
    print(f"Confidence: {suggestion['confidence']}")
    print(f"Rationale: {suggestion['rationale']}")

    if input("Apply? (y/n): ").lower() == 'y':
        result = client.apply_suggestion(
            suggestion['id'],
            suggestion['analysis_id']
        )
        print(f"Result: {result['message']}")
```

### Monitor Meta-Learning Performance
```python
# Get recent analyses
analyses = client.list_analyses(limit=20)['analyses']

# Get all suggestions
suggestions = client.list_suggestions(limit=100)['suggestions']

# Calculate statistics
total_suggestions = len(suggestions)
pending = len([s for s in suggestions if s['status'] == 'pending'])
applied = len([s for s in suggestions if s['status'] == 'applied'])
avg_confidence = sum(s['confidence'] for s in suggestions) / total_suggestions

print(f"Total Analyses: {len(analyses)}")
print(f"Total Suggestions: {total_suggestions}")
print(f"Pending: {pending}")
print(f"Applied: {applied}")
print(f"Average Confidence: {avg_confidence:.2f}")
```

### Safe Prompt Update Workflow
```python
# 1. Create manual backup before experimenting
versions = client.list_versions(limit=5)
print("Current versions:")
for v in versions['versions']:
    print(f"  {v['version_id']}: {v['timestamp']}")

# 2. Trigger meta-analysis
analysis_result = client.trigger_analysis(background=False)
print(f"Analysis: {analysis_result['message']}")

# 3. Review suggestions
suggestions = client.list_suggestions(status="pending")

# 4. Apply selected suggestions
for suggestion in suggestions['suggestions']:
    if suggestion['confidence'] > 0.85:
        result = client.apply_suggestion(
            suggestion['id'],
            suggestion['analysis_id']
        )
        print(f"Applied: {result['message']}")

# 5. If something goes wrong, rollback
versions = client.list_versions(limit=5)
latest_version = versions['versions'][0]['version_id']
rollback_result = client.rollback_version(latest_version)
print(f"Rollback: {rollback_result['message']}")
```

---

## Response Format

All endpoints return:
```json
{
  "success": true,      // or false
  "...": "data",        // endpoint-specific data
  "error": "message"    // only if success is false
}
```

---

## Action Parameters

| Action | Required | Optional |
|--------|----------|----------|
| `list_analyses` | - | `memory_subdir`, `limit`, `search` |
| `get_analysis` | `analysis_id` | `memory_subdir` |
| `list_suggestions` | - | `memory_subdir`, `status`, `limit` |
| `apply_suggestion` | `suggestion_id`, `analysis_id`, `approved` | `memory_subdir` |
| `trigger_analysis` | - | `context_id`, `background` |
| `list_versions` | - | `limit` |
| `rollback_version` | `version_id` | `create_backup` |

---

## Configuration

### Environment Variables
```bash
ENABLE_PROMPT_EVOLUTION=true
PROMPT_EVOLUTION_MIN_INTERACTIONS=20
PROMPT_EVOLUTION_MAX_HISTORY=100
PROMPT_EVOLUTION_CONFIDENCE_THRESHOLD=0.7
AUTO_APPLY_PROMPT_EVOLUTION=false
```

---

## Troubleshooting

**No suggestions found:**
```bash
# Trigger manual analysis
curl -X POST http://localhost:50001/meta_learning \
  -H "X-CSRF-Token: $TOKEN" \
  -d '{"action": "trigger_analysis"}'
```

**Check version history:**
```bash
curl -X POST http://localhost:50001/meta_learning \
  -H "X-CSRF-Token: $TOKEN" \
  -d '{"action": "list_versions", "limit": 50}'
```

**Emergency rollback:**
```bash
# Get latest version
LATEST=$(curl -s http://localhost:50001/meta_learning \
  -H "X-CSRF-Token: $TOKEN" \
  -d '{"action": "list_versions", "limit": 1}' | jq -r '.versions[0].version_id')

# Rollback
curl -X POST http://localhost:50001/meta_learning \
  -H "X-CSRF-Token: $TOKEN" \
  -d "{\"action\": \"rollback_version\", \"version_id\": \"$LATEST\"}"
```

---

## Full Documentation

See `/docs/api/meta_learning_api.md` for complete details.
