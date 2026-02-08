# Architecture Tradeoffs

This document analyzes the architectural decisions in the returns codebase, examining the tradeoffs between complexity, maintainability, and scalability.

---

## 1. Service Object Extraction

### Pattern Used
- `ReturnRequestCreator` → orchestrates return creation
- `EligibilityChecker` → validates eligibility
- `BatchReturnRequestCreator` → handles batch operations

### Tradeoffs

| Pros | Cons |
|------|------|
| Controllers stay thin and focused on HTTP | More files to navigate |
| Business logic is testable in isolation | Indirection adds cognitive load |
| Reusable across entry points (API, CLI, webhooks) | Overhead for simple CRUD operations |
| Clear separation of concerns | Junior devs may struggle to trace flow |

### Verdict
**Worth it** for `ReturnRequestCreator` (handles idempotency, job enqueuing, eligibility).  
**Marginal** for `EligibilityChecker` — could be a private method in Creator.

### Alternative
```ruby
# Simpler: Keep eligibility in Creator
class ReturnRequestCreator
  def call
    return_request = ReturnRequest.new(@params)
    decision = return_request.merchant&.return_rule&.eligible?(return_request.order)
    
    unless decision&.approve?
      return failure_result(...)
    end
    # ...
  end
end
```

---

## 2. Strategy Pattern + Registry (Return Rules)

### Pattern Used
```
Evaluator → Registry.find_for(config) → Strategy.decide → Decision
```

Strategies auto-register via `include Registry`.

### Tradeoffs

| Pros | Cons |
|------|------|
| Adding new strategies doesn't touch Evaluator (OCP) | Magic auto-registration can confuse devs |
| Each strategy is isolated and testable | Overkill for 2 strategies |
| Config-driven rule selection | Load order matters (strategies must load first) |
| Extensible for future rule types | More complex than a simple switch/case |

### Verdict
**Worth it if** you expect 5+ strategies or frequent additions.  
**Overkill if** only `DateThresholdStrategy` and `PriceThresholdStrategy` are ever needed.

### Alternative (Simpler)
```ruby
# Without Registry - explicit mapping
def select_strategy(config)
  case
  when config.key?('window_days') then DateThresholdStrategy
  when config.key?('price_threshold') then PriceThresholdStrategy
  end
end
```

---

## 3. Concerns vs. Modules

### Pattern Used
- `StatusAuditable` (model concern) — auto-logs status changes
- `AasmActions` (controller concern) — DRY transition handling

### Tradeoffs

| Pros | Cons |
|------|------|
| DRY — shared behavior in one place | "Concern hell" if overused |
| Easy to include in multiple models/controllers | Hides complexity behind `include` |
| Follows Rails conventions | Debugging requires jumping between files |
| Clear single responsibility | Can become a dumping ground |

### Verdict
**Good use** for `StatusAuditable` — genuinely reusable audit pattern.  
**Acceptable** for `AasmActions` — DRYs 5 identical action methods.

### Caution
Concerns should encapsulate **behavior**, not just extract code. If a concern is only included once, it's just indirection.

---

## 4. Background Job for Label Generation

### Pattern Used
```ruby
# In ReturnRequestCreator
GenerateShippingLabelJob.perform_later(return_request.id)
```

### Tradeoffs

| Pros | Cons |
|------|------|
| HTTP request returns immediately (good UX) | Added infrastructure (job queue, workers) |
| Handles carrier API timeouts gracefully | State management complexity |
| Built-in retry with exponential backoff | Harder to debug than synchronous code |
| Scalable under load | Job can fail after request succeeded |

### Verdict
**Essential** for production — carrier APIs are slow and unreliable.

### Considerations
- Job includes `discard_on ActiveRecord::RecordNotFound` — good defensive coding
- Records failures in `label_generation_error` column — good observability
- Uses `sleep(5)` simulation — **remove in production**

---

## 5. Duplicated Eligibility Logic

### Problem
`BatchReturnRequestCreator` has its own `check_eligibility` method (lines 111-135) that duplicates `EligibilityChecker`.

```ruby
# batch_return_request_creator.rb
def check_eligibility(return_request)
  # ... 25 lines of duplicated logic
end

# eligibility_checker.rb
def call
  # ... same logic
end
```

### Tradeoffs

| Current State | If Unified |
|---------------|------------|
| Batch can optimize (e.g., cache rule lookup) | Single source of truth |
| Each service is self-contained | Must import EligibilityChecker |
| Easier inline customization | Slightly more indirection |

### Recommendation
**Refactor to reuse** `EligibilityChecker` unless there's a performance reason for inline logic in batch operations.

---

## 6. AASM State Machine

### Pattern Used
```ruby
aasm column: :status, enum: true do
  state :requested, initial: true
  state :approved, :rejected, :shipped, :received, :resolved
  
  event :approve do
    transitions from: :requested, to: :approved
  end
  # ...
end
```

### Tradeoffs

| Pros | Cons |
|------|------|
| Clear state lifecycle visualization | AASM gem dependency |
| Invalid transitions raise errors | Adds magic methods (`approve!`, `may_approve?`) |
| Integrates with Rails enum | Can conflict with enum if not careful |
| Callbacks for side effects | Testing state machines can be tedious |

### Verdict
**Good choice** for this use case — returns have clear lifecycle.

---

## 7. Value Objects (Decision, Configuration)

### Pattern Used
```ruby
Decision.new(:approve, reason: 'within_window', metadata: {})
Configuration.new(window_days: 30, refund_allowed: true)
```

### Tradeoffs

| Pros | Cons |
|------|------|
| Immutable, predictable | Yet another class |
| Self-documenting with predicates (`decision.approve?`) | Could use plain Hash |
| Type-safe attributes | Overhead for simple data |
| Serializable (`to_h`) | Must remember to use them consistently |

### Verdict
**Worth it** — better than passing hashes around. Code reads cleaner.

---

## 8. JSON Schema Validation

### Pattern Used
```ruby
validates_with ReturnRules::ConfigurationSchemaValidator
```

Uses `json_schemer` gem for JSONB validation.

### Tradeoffs

| Pros | Cons |
|------|------|
| Schema is explicit and documented | Another gem dependency |
| Catches malformed configs early | Schema must be maintained |
| Follows industry standards | Overkill for 4 fields |

### Verdict
**Worth it if** configuration grows complex or is user-provided.  
**Overkill if** only developers set rules.

---

## Summary Table

| Decision | Complexity | Benefit | Recommendation |
|----------|------------|---------|----------------|
| Service Objects | Medium | High | ✅ Keep |
| EligibilityChecker Extraction | Low | Low | 🤔 Could merge into Creator |
| Strategy + Registry | High | Medium | ✅ Keep if expecting growth |
| Model Concerns | Medium | High | ✅ Keep |
| Controller Concerns | Low | Medium | ✅ Keep |
| Background Jobs | Medium | High | ✅ Essential |
| Duplicated Eligibility | — | — | ❌ Should refactor |
| AASM State Machine | Medium | High | ✅ Good fit |
| Value Objects | Low | Medium | ✅ Keep |
| JSON Schema Validation | Low | Medium | ✅ Good for safety |

---
*Last updated: February 2026*