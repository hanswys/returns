# Frontend Update Guide: JSONB Configuration

## Overview

The React frontend has been updated to work with the new JSONB `configuration` structure for Return Rules. The data now flows through nested objects rather than flat properties.

## Data Structure Changes

### Old Structure
```javascript
{
  id: 1,
  merchant_id: 2,
  window_days: 30,
  replacement_allowed: true,
  refund_allowed: false,
  reason: "General returns"
}
```

### New Structure
```javascript
{
  id: 1,
  merchant_id: 2,
  product_id: null,
  configuration: {
    window_days: 30,
    replacement_allowed: true,
    refund_allowed: false,
    reason: "General returns"
  }
}
```

## API Request Format

### Creating a Return Rule
```javascript
const payload = {
  return_rule: {
    product_id: 123,  // optional
    configuration: {
      window_days: 30,
      replacement_allowed: true,
      refund_allowed: false,
      reason: "30-day return policy"
    }
  }
};

await apiClient.post(`/api/v1/merchants/${merchantId}/return_rules`, payload);
```

### Updating a Return Rule
```javascript
const payload = {
  return_rule: {
    configuration: {
      window_days: 45,
      replacement_allowed: true,
      refund_allowed: true,
      reason: "Extended policy"
    }
  }
};

await apiClient.patch(`/api/v1/merchants/${merchantId}/return_rules/${ruleId}`, payload);
```

## React Component Updates

### ReturnRuleForm Component

```jsx
import React, { useState } from 'react';
import { useCreateReturnRule, useUpdateReturnRule } from '../../hooks/useApi';

export default function ReturnRuleForm({ merchantId, onSuccess, initialRule }) {
  const createRule = useCreateReturnRule();
  const updateRule = useUpdateReturnRule();

  const [formData, setFormData] = useState({
    product_id: initialRule?.product_id || null,
    configuration: initialRule?.configuration || {
      window_days: 30,
      replacement_allowed: true,
      refund_allowed: true,
      reason: ''
    }
  });

  const [errors, setErrors] = useState({});

  const handleConfigChange = (field, value) => {
    // Type casting
    let processedValue = value;
    if (field === 'window_days') {
      processedValue = value ? parseInt(value, 10) : null;
    } else if (field === 'replacement_allowed' || field === 'refund_allowed') {
      processedValue = value === true || value === 'true';
    }

    setFormData(prev => ({
      ...prev,
      configuration: {
        ...prev.configuration,
        [field]: processedValue
      }
    }));

    // Clear error for this field
    setErrors(prev => {
      const newErrors = { ...prev };
      delete newErrors[field];
      return newErrors;
    });
  };

  const validateForm = () => {
    const newErrors = {};
    const config = formData.configuration;

    if (!config.window_days || config.window_days < 1) {
      newErrors.window_days = 'Window days must be at least 1';
    }

    if (!config.replacement_allowed && !config.refund_allowed) {
      newErrors.options = 'At least one return option must be enabled';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!validateForm()) return;

    try {
      const mutation = initialRule ? updateRule : createRule;
      
      if (initialRule) {
        await mutation.mutateAsync({
          merchantId,
          id: initialRule.id,
          data: formData
        });
      } else {
        await mutation.mutateAsync({
          merchantId,
          data: formData
        });
      }

      onSuccess?.();
    } catch (error) {
      setErrors({ submit: error.response?.data?.errors || 'Failed to save rule' });
    }
  };

  return (
    <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow p-6 space-y-4">
      <h2 className="text-2xl font-bold">
        {initialRule ? 'Edit Return Rule' : 'Create Return Rule'}
      </h2>

      {/* Window Days */}
      <div>
        <label className="block text-sm font-medium text-gray-700">
          Return Window (Days)
        </label>
        <input
          type="number"
          min="1"
          value={formData.configuration.window_days}
          onChange={(e) => handleConfigChange('window_days', e.target.value)}
          className={`w-full px-4 py-2 border rounded-lg focus:outline-none ${
            errors.window_days ? 'border-red-500' : 'border-gray-300'
          }`}
        />
        {errors.window_days && (
          <p className="text-red-600 text-sm mt-1">{errors.window_days}</p>
        )}
      </div>

      {/* Replacement Allowed */}
      <div className="flex items-center space-x-2">
        <input
          type="checkbox"
          id="replacement"
          checked={formData.configuration.replacement_allowed}
          onChange={(e) => handleConfigChange('replacement_allowed', e.target.checked)}
          className="h-4 w-4 text-blue-600 border-gray-300 rounded"
        />
        <label htmlFor="replacement" className="text-sm font-medium text-gray-700">
          Replacement Allowed
        </label>
      </div>

      {/* Refund Allowed */}
      <div className="flex items-center space-x-2">
        <input
          type="checkbox"
          id="refund"
          checked={formData.configuration.refund_allowed}
          onChange={(e) => handleConfigChange('refund_allowed', e.target.checked)}
          className="h-4 w-4 text-blue-600 border-gray-300 rounded"
        />
        <label htmlFor="refund" className="text-sm font-medium text-gray-700">
          Refund Allowed
        </label>
      </div>

      {errors.options && (
        <p className="text-red-600 text-sm">{errors.options}</p>
      )}

      {/* Reason */}
      <div>
        <label className="block text-sm font-medium text-gray-700">
          Reason (Optional)
        </label>
        <textarea
          value={formData.configuration.reason || ''}
          onChange={(e) => handleConfigChange('reason', e.target.value)}
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none"
          rows="3"
          placeholder="e.g., General returns within window period"
        />
      </div>

      {errors.submit && (
        <p className="text-red-600 text-sm">{errors.submit}</p>
      )}

      <button
        type="submit"
        disabled={createRule.isPending || updateRule.isPending}
        className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
      >
        {createRule.isPending || updateRule.isPending ? 'Saving...' : 'Save Rule'}
      </button>
    </form>
  );
}
```

### ReturnRuleCard Component

```jsx
export default function ReturnRuleCard({ rule, onEdit, onDelete }) {
  const config = rule.configuration || {};

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="flex justify-between items-start mb-4">
        <h3 className="text-lg font-semibold">Return Rule</h3>
        <div className="space-x-2">
          <button
            onClick={() => onEdit(rule)}
            className="text-blue-600 hover:text-blue-900"
          >
            Edit
          </button>
          <button
            onClick={() => onDelete(rule.id)}
            className="text-red-600 hover:text-red-900"
          >
            Delete
          </button>
        </div>
      </div>

      <div className="space-y-2 text-sm">
        <p>
          <strong>Return Window:</strong> {config.window_days} days
        </p>
        <p>
          <strong>Replacement:</strong>{' '}
          {config.replacement_allowed ? '✅ Allowed' : '❌ Not Allowed'}
        </p>
        <p>
          <strong>Refund:</strong>{' '}
          {config.refund_allowed ? '✅ Allowed' : '❌ Not Allowed'}
        </p>
        {config.reason && (
          <p>
            <strong>Reason:</strong> {config.reason}
          </p>
        )}
      </div>
    </div>
  );
}
```

## Hook Usage

### Updated useApi.js hooks

The hooks remain largely the same, but now handle the nested structure:

```javascript
// Create with new structure
const { mutateAsync } = useCreateReturnRule();

await mutateAsync({
  merchantId: 1,
  data: {
    product_id: null,
    configuration: {
      window_days: 30,
      replacement_allowed: true,
      refund_allowed: false,
      reason: "30-day window"
    }
  }
});

// Update
const { mutateAsync: updateAsync } = useUpdateReturnRule();

await updateAsync({
  merchantId: 1,
  id: 1,
  data: {
    configuration: {
      window_days: 45,
      replacement_allowed: true,
      refund_allowed: true
    }
  }
});
```

## TanStack Query Cache Management

### Cache Structure
```javascript
// Cache keys follow this pattern
['returnRules', merchantId]
['returnRule', merchantId, ruleId]
```

### Invalidation on Mutations
```javascript
// When rule is created/updated/deleted, caches are invalidated:
queryClient.invalidateQueries({ queryKey: ['returnRules', merchantId] })
queryClient.invalidateQueries({ queryKey: ['returnRule', merchantId, ruleId] })
```

### Optimistic Updates (Optional)
```javascript
const queryClient = useQueryClient();

return useMutation({
  mutationFn: ({ merchantId, id, data }) => 
    returnRulesAPI.update(merchantId, id, data),
  onMutate: async ({ merchantId, id, data }) => {
    // Cancel in-flight queries
    await queryClient.cancelQueries({ queryKey: ['returnRule', merchantId, id] });

    // Snapshot previous data
    const previousRule = queryClient.getQueryData(['returnRule', merchantId, id]);

    // Update cache optimistically
    queryClient.setQueryData(['returnRule', merchantId, id], data);

    return { previousRule };
  },
  onError: (err, variables, context) => {
    // Revert on error
    queryClient.setQueryData(
      ['returnRule', variables.merchantId, variables.id],
      context.previousRule
    );
  },
  onSuccess: (_, { merchantId }) => {
    // Invalidate list
    queryClient.invalidateQueries({ queryKey: ['returnRules', merchantId] });
  }
});
```

## Backward Compatibility

The API serializer maintains backward compatibility by flattening the configuration:

```json
{
  "id": 1,
  "merchant_id": 2,
  "configuration": {
    "window_days": 30,
    "replacement_allowed": true,
    "refund_allowed": false,
    "reason": "Default policy"
  }
}
```

## Data Validation in Frontend

### Type Coercion
```javascript
// Automatically handles type conversion
handleConfigChange('window_days', '30')    // -> 30 (int)
handleConfigChange('replacement_allowed', 'true')  // -> true (bool)
```

### Client-Side Validation
```javascript
const validateForm = () => {
  const newErrors = {};
  const config = formData.configuration;

  // window_days must be >= 1
  if (!config.window_days || config.window_days < 1) {
    newErrors.window_days = 'Window days must be at least 1';
  }

  // At least one option required
  if (!config.replacement_allowed && !config.refund_allowed) {
    newErrors.options = 'At least one return option must be enabled';
  }

  return newErrors;
};
```

## Troubleshooting

### "Configuration is undefined"
The API returns `configuration` at the top level. Access it directly:
```javascript
// Wrong
rule.window_days

// Correct
rule.configuration.window_days
```

### Type mismatch errors
Ensure type casting in form handlers:
```javascript
// Wrong
configuration: { window_days: "30" }

// Correct
configuration: { window_days: 30 }
```

### Cache not updating
Ensure mutation hooks call `queryClient.invalidateQueries()`:
```javascript
onSuccess: (_, { merchantId }) => {
  queryClient.invalidateQueries({ queryKey: ['returnRules', merchantId] });
}
```

## Testing

### Unit Test Example
```javascript
const { render, screen, fireEvent } = require('@testing-library/react');
import ReturnRuleForm from './ReturnRuleForm';

test('submits form with configuration structure', async () => {
  const { getByText, getByDisplayValue } = render(
    <ReturnRuleForm merchantId={1} onSuccess={jest.fn()} />
  );

  fireEvent.change(getByDisplayValue('30'), { target: { value: '45' } });
  fireEvent.click(getByText('Save Rule'));

  // Verify API was called with correct structure
  expect(mockApi.post).toHaveBeenCalledWith(
    '/api/v1/merchants/1/return_rules',
    {
      return_rule: {
        product_id: null,
        configuration: {
          window_days: 45,
          replacement_allowed: true,
          refund_allowed: true,
          reason: ''
        }
      }
    }
  );
});
```

## Migration Checklist

- [ ] Update ReturnRuleForm to use nested `configuration` object
- [ ] Update ReturnRuleCard to access `rule.configuration.*`
- [ ] Update useApi hooks (if custom handling needed)
- [ ] Update TanStack Query cache invalidation
- [ ] Update form validation logic
- [ ] Update TypeScript types (if using TS)
- [ ] Test create/update/delete flows
- [ ] Test API error handling
- [ ] Test cache invalidation
