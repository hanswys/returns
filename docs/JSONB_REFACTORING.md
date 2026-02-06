# ReturnRule JSONB Refactoring Guide

## Overview

The `ReturnRule` model has been refactored to use a JSONB `configuration` column instead of scalar columns (`window_days`, `replacement_allowed`, `refund_allowed`, `reason`). This provides flexible, schema-validated configuration management.

## Architecture

### 1. Database Schema

**Migration**: `RefactorReturnRulesToJsonb`

```sql
ALTER TABLE return_rules ADD COLUMN configuration jsonb DEFAULT '{}' NOT NULL;
CREATE INDEX index_return_rules_on_configuration ON return_rules USING GIN (configuration);
```

**Old Columns** (removed):
- `window_days` (integer)
- `replacement_allowed` (boolean)
- `refund_allowed` (boolean)  
- `reason` (string)

### 2. Model Features

**File**: `app/models/return_rule.rb`

#### store_accessor
Provides getter/setter methods for nested JSONB keys:
```ruby
store_accessor :configuration, :window_days, :replacement_allowed, :refund_allowed, :reason

rule.window_days = 30          # Sets configuration['window_days'] = 30
rule.window_days               # Returns 30
rule.configuration['window_days'] # Same as above
```

#### Type Casting
Automatic type casting from string/API inputs:
```ruby
rule.window_days = "30"        # Auto-converts to integer
rule.replacement_allowed = "true"  # Auto-converts to boolean
```

#### JSON Schema Validation
Validates configuration structure:
```ruby
CONFIGURATION_SCHEMA = {
  type: 'object',
  properties: {
    window_days: { type: 'integer', minimum: 1 },
    replacement_allowed: { type: 'boolean' },
    refund_allowed: { type: 'boolean' },
    reason: { type: ['string', 'null'] }
  },
  required: ['window_days', 'replacement_allowed', 'refund_allowed'],
  additionalProperties: false
}
```

### 3. Service Object: ReturnRules::Evaluator

**File**: `app/services/return_rules/evaluator.rb`

Evaluates order eligibility based on rule configuration:

```ruby
rule = ReturnRule.find(1)
order = Order.find(1)

eligible = ReturnRules::Evaluator.call(order, rule.configuration)
# OR
eligible = rule.eligible?(order)
```

**Validation Logic**:
1. Configuration has required fields (window_days > 0)
2. Order is within return window (today <= order_date + window_days)
3. At least one return option enabled (replacement OR refund)

**Type Safety**: Handles both string and integer inputs, casts booleans correctly.

### 4. Controller

**File**: `app/controllers/api/v1/return_rules_controller.rb`

Updated `return_rule_params`:
```ruby
def return_rule_params
  params.require(:return_rule).permit(:product_id, configuration: [:window_days, :replacement_allowed, :refund_allowed, :reason])
end
```

### 5. Serializer

**File**: `app/serializers/return_rule_serializer.rb`

Returns flattened configuration for frontend:
```json
{
  "id": 1,
  "merchant_id": 2,
  "product_id": null,
  "configuration": {
    "window_days": 30,
    "replacement_allowed": true,
    "refund_allowed": true,
    "reason": "General returns"
  }
}
```

## API Usage

### Create Return Rule
```bash
curl -X POST http://localhost:3000/api/v1/merchants/1/return_rules \
  -H "Content-Type: application/json" \
  -d '{
    "return_rule": {
      "configuration": {
        "window_days": 30,
        "replacement_allowed": true,
        "refund_allowed": false,
        "reason": "Refunds within 30 days"
      }
    }
  }'
```

### Update Return Rule
```bash
curl -X PATCH http://localhost:3000/api/v1/merchants/1/return_rules/1 \
  -H "Content-Type: application/json" \
  -d '{
    "return_rule": {
      "configuration": {
        "window_days": 45,
        "replacement_allowed": true,
        "refund_allowed": true,
        "reason": "Updated policy"
      }
    }
  }'
```

### Validate Rule Against Order
```ruby
# In Rails console or service
rule = ReturnRule.find(1)
order = Order.find(1)

if rule.eligible?(order)
  # Order can be returned
else
  # Order not eligible
end
```

## Data Validation

### Handled Cases
- ✅ `window_days: "30"` → converted to 30
- ✅ `replacement_allowed: "false"` → converted to false
- ✅ `window_days: 0` → rejected (must be >= 1)
- ✅ Missing required fields → rejected
- ✅ Extra fields → rejected (strict schema)

### Validation Errors
```json
{
  "errors": {
    "configuration": [
      "invalid schema: window_days: not valid against schema (minimum: 1), replacement_allowed: is of type \"string\" but was expected to be one of [\"boolean\"]"
    ],
    "base": [
      "At least one of replacement_allowed or refund_allowed must be true"
    ]
  }
}
```

## Database Migration

### Up (Rollforward)
1. Add `configuration` JSONB column (default: `{}`)
2. Add GIN index on configuration
3. Migrate data: `window_days`, `replacement_allowed`, `refund_allowed`, `reason` → configuration JSON
4. Drop old scalar columns

### Down (Rollback)
1. Add scalar columns back
2. Restore data from configuration JSON
3. Remove GIN index
4. Remove configuration column

**Zero-Downtime**: Migration uses reversible block for safe rollback.

## SOLID Principles

### Single Responsibility
- **Model**: Manages state, validation, relationships
- **Service**: Evaluates eligibility logic
- **Controller**: HTTP/API interface
- **Serializer**: JSON output formatting

### Open/Closed
Configuration schema can be extended without changing core validation:
```ruby
# Future: add new configuration keys
CONFIGURATION_SCHEMA = {
  # ... existing fields
  custom_field: { type: 'string' }
}
```

### Liskov Substitution
Store accessor maintains interface compatibility:
```ruby
# Works the same way
rule.window_days = 30
rule.configuration['window_days'] = 30
```

### Interface Segregation
Service object has single method: `call(order, configuration)`

### Dependency Inversion
Model depends on validation abstraction (JSON Schema), not implementation details.

## Frontend Integration

See [FRONTEND_UPDATES.md](FRONTEND_UPDATES.md) for React/TanStack Query changes.

### Data Structure (React)
```javascript
const configuration = {
  window_days: 30,
  replacement_allowed: true,
  refund_allowed: false,
  reason: "Refunds only within 30 days"
};
```

### Form Submission
```javascript
const response = await axios.post(`/api/v1/merchants/${merchantId}/return_rules`, {
  return_rule: {
    configuration: configuration
  }
});
```

## Testing

### Unit Tests (Model)
```ruby
rule = ReturnRule.new(
  merchant_id: 1,
  configuration: {
    window_days: 30,
    replacement_allowed: true,
    refund_allowed: false
  }
)
expect(rule.valid?).to be true
```

### Service Object Tests
```ruby
order = Order.new(order_date: 5.days.ago)
config = { window_days: 10, replacement_allowed: true, refund_allowed: false }
expect(ReturnRules::Evaluator.call(order, config)).to be true

order = Order.new(order_date: 15.days.ago)
expect(ReturnRules::Evaluator.call(order, config)).to be false
```

## Troubleshooting

### "configuration must be a valid hash"
Ensure configuration is a Hash object, not a string:
```ruby
# Wrong
ReturnRule.create(configuration: '{"window_days": 30}')

# Correct
ReturnRule.create(configuration: { window_days: 30 })
```

### "invalid schema" error
Configuration is missing required fields or has wrong types:
```ruby
# Missing refund_allowed
{ window_days: 30, replacement_allowed: true }  # Invalid!

# Correct
{ window_days: 30, replacement_allowed: true, refund_allowed: false }
```

### "At least one option must be enabled"
Both replacement and refund are false:
```ruby
# Invalid
{ window_days: 30, replacement_allowed: false, refund_allowed: false }

# Valid
{ window_days: 30, replacement_allowed: true, refund_allowed: false }
```

## Performance Considerations

- **GIN Index**: `configuration` JSONB column is indexed for fast queries
- **store_accessor**: Zero overhead - just attribute getters/setters
- **JSON Schema**: Validation at write-time only, not on reads
- **Query Examples**:
```ruby
# Find rules allowing replacements
ReturnRule.where("configuration->>'replacement_allowed' = 'true'")

# Find rules with 30-day window
ReturnRule.where("configuration->>'window_days' = '30'")

# Find rules for specific product
ReturnRule.where(product_id: 123)
          .where("configuration->>'window_days' > '20'")
```
