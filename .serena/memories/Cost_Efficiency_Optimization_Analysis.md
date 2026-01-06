# Cost/Efficiency Optimization - Intelligent Model Routing Analysis

## Current State Assessment

### ✅ Already Implemented Features

#### 1. **Dual Model Architecture**
- **Chat Model**: Primary model for main agent conversations (default: GPT-4.1)
- **Utility Model**: Lighter model for background tasks (default: GPT-4.1-mini)
- **Browser Model**: Specialized model for browser automation
- **Embedding Model**: For vector search and semantic similarity

#### 2. **Rate Limiting System**
- **Per-model rate limits** configured via `ModelConfig`:
  - `limit_requests`: Max requests per minute
  - `limit_input`: Max input tokens per minute
  - `limit_output`: Max output tokens per minute
- **RateLimiter class** (`models.py:197-226`) with 60-second windows
- **Round-robin API key support** for load distribution
- **Automatic retry logic** with exponential backoff for transient errors

#### 3. **Context Window Management**
- **Automatic history compression** when context limits exceeded
- **Token counting** via tiktoken (cl100k_base encoding)
- **Configurable context allocation**:
  - `chat_model_ctx_history`: Portion for chat history (default: 0.7)
  - `util_model_ctx_input`: Portion for utility model input (default: 0.7)
- **Smart compression ratios**:
  - Current topic: 40% of context
  - History topics: 30% of context
  - Bulk summaries: 30% of context

#### 4. **Current Utility Model Usage**
Utility model is used for **background/lightweight tasks**:
- **Memory operations**:
  - Extracting memories from conversation (`_50_memorize_fragments.py`)
  - Extracting solutions (`_51_memorize_solutions.py`)
  - Generating memory search queries (`_50_recall_memories.py`)
  - Keyword extraction for memory search (`memory_consolidation.py`)
  - Memory consolidation analysis
- **All utility calls use `background=True`** to skip rate limiter callbacks

#### 5. **Token Optimization**
- **Approximate token counting** with 1.1x buffer
- **Token trimming** with 0.8x buffer for safety
- **Streaming responses** to avoid buffering entire responses
- **Lazy loading** of prompts and extensions

### 🔴 Missing/Opportunity Areas

#### 1. **No Intelligent Task Complexity Detection**
- Currently **manual/hardcoded** decision: developer chooses chat vs utility model
- No automatic routing based on:
  - Task complexity analysis
  - Required reasoning depth
  - Tool usage patterns
  - Response length requirements

#### 2. **No Cost Tracking**
- No tracking of:
  - Token usage per model
  - API costs per conversation
  - Cost per tool execution
  - Cost trends over time
- No cost budgets or alerts

#### 3. **No Dynamic Model Selection**
- Models are **fixed at conversation start**
- No ability to:
  - Switch models mid-conversation based on task
  - Use different models for different tools
  - Fallback to cheaper models when appropriate
  - Upgrade to more powerful models when needed

#### 4. **No Model Performance Metrics**
- No tracking of:
  - Success rates per model
  - Average response quality
  - Task completion rates
  - Model-specific error rates

#### 5. **No Cost-Aware Prompt Optimization**
- No automatic:
  - Prompt compression for expensive models
  - Context pruning based on cost
  - Summary generation to reduce tokens

#### 6. **Limited Provider Optimization**
- 20+ providers supported but no:
  - Automatic provider selection based on cost
  - Provider failover for cost optimization
  - Provider-specific optimizations

## Intelligent Model Routing Opportunities

### 🎯 High-Impact Enhancements

#### 1. **Task Complexity Analyzer**
Create an extension that analyzes incoming tasks and routes to appropriate model:

```python
# Extension: message_loop_start/10_intelligent_routing.py
async def extend(agent, loop_data, **kwargs):
    # Analyze task complexity
    complexity = await analyze_task_complexity(
        user_message=loop_data.user_message,
        history=agent.history,
        available_tools=extract_available_tools()
    )
    
    # Route to appropriate model
    if complexity.score < 0.3:  # Simple task
        loop_data.params_temporary['use_utility_model'] = True
    elif complexity.score > 0.8:  # Complex task
        loop_data.params_temporary['use_premium_model'] = True
```

**Complexity Factors**:
- Reasoning depth required (simple lookup vs multi-step analysis)
- Tool chaining complexity
- Code generation requirements
- Creative vs factual tasks
- Response length expectations

#### 2. **Cost-Aware Model Router**
Implement intelligent routing based on cost/performance tradeoffs:

```python
class ModelRouter:
    def select_model(self, task, budget, quality_threshold):
        # Get available models sorted by cost
        models = self.get_models_by_cost()
        
        # Find cheapest model meeting quality threshold
        for model in models:
            if self.predict_quality(model, task) >= quality_threshold:
                if self.estimate_cost(model, task) <= budget:
                    return model
        
        # Fallback to default
        return self.default_model
```

#### 3. **Token Usage Tracker**
Add comprehensive cost tracking:

```python
# Extension: util_model_call_before/10_track_costs.py
async def extend(agent, call_data, **kwargs):
    # Track token usage
    input_tokens = approximate_tokens(call_data['message'])
    
    # Log to database/memory
    await log_model_usage(
        model=call_data['model'],
        input_tokens=input_tokens,
        timestamp=datetime.now(),
        task_type='utility',
        context_id=agent.context.id
    )
```

#### 4. **Dynamic Model Switching**
Allow mid-conversation model changes:

```python
# Tool: switch_model.py
class SwitchModel(Tool):
    async def execute(self, model_type='auto', reason=''):
        if model_type == 'auto':
            # Analyze recent performance
            model = await self.select_optimal_model()
        else:
            model = self.get_model_by_name(model_type)
        
        # Update agent config
        self.agent.config.chat_model = model
        
        return Response(
            message=f"Switched to {model.name} ({reason})",
            break_loop=False
        )
```

#### 5. **Prompt Compression for Cost Optimization**
Automatically compress prompts for expensive models:

```python
# Extension: message_loop_prompts_after/15_compress_for_cost.py
async def extend(agent, loop_data, **kwargs):
    model_cost = get_model_cost(agent.config.chat_model)
    
    if model_cost > COST_THRESHOLD:
        # Compress system prompts
        loop_data.system = await compress_prompts(
            loop_data.system,
            target_reduction=0.3
        )
        
        # Summarize older history
        loop_data.history_output = await compress_history(
            loop_data.history_output,
            keep_recent=5
        )
```

### 📊 Metrics to Track

#### Cost Metrics
- Total tokens used (input/output) per model
- Estimated cost per conversation
- Cost per tool execution
- Cost trends over time
- Cost by task type

#### Performance Metrics
- Task success rate by model
- Average response time by model
- Quality scores (user feedback)
- Error rates by model
- Retry rates by model

#### Efficiency Metrics
- Tokens per task completion
- Cost per successful task
- Model utilization rates
- Cache hit rates (if caching implemented)

## Implementation Roadmap

### Phase 1: Foundation (Week 1-2)
1. ✅ **Cost Tracking Infrastructure**
   - Add token usage logging
   - Create cost calculation utilities
   - Build metrics dashboard API

2. ✅ **Task Complexity Analyzer**
   - Implement complexity scoring
   - Create routing decision logic
   - Add configuration options

### Phase 2: Intelligent Routing (Week 3-4)
3. ✅ **Model Router Implementation**
   - Build model selection algorithm
   - Add cost/quality tradeoff logic
   - Implement fallback mechanisms

4. ✅ **Dynamic Model Switching**
   - Create model switching tool
   - Add mid-conversation routing
   - Implement performance monitoring

### Phase 3: Optimization (Week 5-6)
5. ✅ **Prompt Compression**
   - Implement automatic compression
   - Add cost-aware history management
   - Create compression quality metrics

6. ✅ **Provider Optimization**
   - Add provider cost comparison
   - Implement automatic failover
   - Create provider performance tracking

### Phase 4: Advanced Features (Week 7-8)
7. ✅ **Predictive Routing**
   - ML-based task complexity prediction
   - Historical performance analysis
   - Adaptive routing based on patterns

8. ✅ **Cost Budgets & Alerts**
   - Per-conversation budgets
   - Cost alerts and warnings
   - Automatic downgrade on budget limits

## Configuration Examples

### Current Settings (settings.py)
```python
chat_model_provider: "openrouter"
chat_model_name: "openai/gpt-4.1"
util_model_provider: "openrouter"
util_model_name: "openai/gpt-4.1-mini"
```

### Proposed Enhanced Settings
```python
# Model routing configuration
model_routing_enabled: true
model_routing_strategy: "cost_optimized"  # or "quality_first", "balanced"
model_routing_budget_per_conversation: 0.50  # USD
model_routing_quality_threshold: 0.7  # 0-1 scale

# Model tiers
model_tiers:
  simple:
    provider: "openrouter"
    name: "openai/gpt-4.1-mini"
    max_cost_per_1k_tokens: 0.0001
  standard:
    provider: "openrouter"
    name: "openai/gpt-4.1"
    max_cost_per_1k_tokens: 0.001
  premium:
    provider: "anthropic"
    name: "claude-3-opus"
    max_cost_per_1k_tokens: 0.015

# Complexity thresholds
complexity_thresholds:
  simple: 0.3    # Use simple model
  standard: 0.7  # Use standard model
  premium: 0.9   # Use premium model
```

## Key Files to Modify/Create

### Existing Files to Enhance
1. **models.py** - Add cost tracking, model tier management
2. **agent.py** - Add dynamic model selection logic
3. **python/helpers/settings.py** - Add routing configuration
4. **python/helpers/tokens.py** - Add cost calculation utilities

### New Files to Create
1. **python/helpers/model_router.py** - Core routing logic
2. **python/helpers/cost_tracker.py** - Cost tracking and metrics
3. **python/helpers/task_analyzer.py** - Task complexity analysis
4. **python/extensions/message_loop_start/10_intelligent_routing.py** - Routing extension
5. **python/extensions/util_model_call_before/10_track_costs.py** - Cost tracking extension
6. **python/tools/switch_model.py** - Manual model switching tool
7. **python/api/costs.py** - Cost metrics API endpoints

## Benefits

### Cost Savings
- **30-50% reduction** in API costs through intelligent routing
- **Automatic downgrade** to cheaper models for simple tasks
- **Budget enforcement** prevents cost overruns

### Performance
- **Faster responses** for simple tasks using lighter models
- **Better quality** for complex tasks using appropriate models
- **Reduced latency** through optimal model selection

### User Experience
- **Transparent cost tracking** in UI
- **Budget controls** for cost-conscious users
- **Quality guarantees** through minimum thresholds

## Next Steps

1. **Review and prioritize** features based on impact/effort
2. **Design detailed architecture** for selected features
3. **Implement Phase 1** (Foundation) features
4. **Test and validate** with real workloads
5. **Iterate based on metrics** and user feedback
