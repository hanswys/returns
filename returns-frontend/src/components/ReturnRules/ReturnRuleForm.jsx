import React, { useState } from 'react';
import { useCreateReturnRule, useUpdateReturnRule } from '../../hooks/useApi';

export default function ReturnRuleForm({ merchantId, onSuccess, initialRule = null }) {
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
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleConfigChange = (field, value) => {
    let processedValue = value;

    // Type casting for specific fields
    if (field === 'window_days') {
      processedValue = value ? parseInt(value, 10) : null;
    } else if (field === 'replacement_allowed' || field === 'refund_allowed') {
      processedValue = typeof value === 'string' ? value === 'true' : value;
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

    // Validate window_days
    if (!config.window_days || parseInt(config.window_days, 10) < 1) {
      newErrors.window_days = 'Return window must be at least 1 day';
    }

    // Validate at least one option is enabled
    if (!config.replacement_allowed && !config.refund_allowed) {
      newErrors.options = 'At least one return option (Replacement or Refund) must be enabled';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!validateForm()) return;

    setIsSubmitting(true);

    try {
      if (initialRule) {
        // Update existing rule
        await updateRule.mutateAsync({
          merchantId,
          id: initialRule.id,
          data: formData
        });
      } else {
        // Create new rule
        await createRule.mutateAsync({
          merchantId,
          data: formData
        });
      }

      // Reset form on success
      setFormData({
        product_id: null,
        configuration: {
          window_days: 30,
          replacement_allowed: true,
          refund_allowed: true,
          reason: ''
        }
      });
      setErrors({});
      onSuccess?.();
    } catch (error) {
      const errorMessage = error.response?.data?.errors 
        ? Object.entries(error.response.data.errors)
            .map(([key, val]) => `${key}: ${Array.isArray(val) ? val.join(', ') : val}`)
            .join('; ')
        : 'Failed to save return rule';
      setErrors({ submit: errorMessage });
    } finally {
      setIsSubmitting(false);
    }
  };

  const isLoading = createRule.isPending || updateRule.isPending || isSubmitting;

  return (
    <form 
      onSubmit={handleSubmit} 
      className="bg-white rounded-lg shadow p-6 space-y-6"
    >
      <div>
        <h2 className="text-2xl font-bold text-gray-900 mb-6">
          {initialRule ? 'Edit Return Rule' : 'Create Return Rule'}
        </h2>
      </div>

      {/* Window Days */}
      <div>
        <label htmlFor="window_days" className="block text-sm font-medium text-gray-700 mb-2">
          Return Window <span className="text-red-500">*</span>
        </label>
        <div className="relative">
          <input
            id="window_days"
            type="number"
            min="1"
            max="365"
            value={formData.configuration.window_days || ''}
            onChange={(e) => handleConfigChange('window_days', e.target.value)}
            className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.window_days ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="30"
            disabled={isLoading}
          />
          <span className="absolute right-4 top-2.5 text-gray-600">days</span>
        </div>
        {errors.window_days && (
          <p className="text-red-600 text-sm mt-1">{errors.window_days}</p>
        )}
        <p className="text-gray-500 text-xs mt-1">How many days customers have to return items</p>
      </div>

      {/* Return Options */}
      <div className="border-t border-gray-200 pt-6">
        <p className="text-sm font-medium text-gray-700 mb-4">
          Return Options <span className="text-red-500">*</span>
        </p>
        
        <div className="space-y-3">
          {/* Replacement Allowed */}
          <div className="flex items-center">
            <input
              id="replacement"
              type="checkbox"
              checked={formData.configuration.replacement_allowed || false}
              onChange={(e) => handleConfigChange('replacement_allowed', e.target.checked)}
              className="h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500 cursor-pointer"
              disabled={isLoading}
            />
            <label htmlFor="replacement" className="ml-3 text-sm text-gray-700 cursor-pointer">
              Allow Replacements
            </label>
          </div>

          {/* Refund Allowed */}
          <div className="flex items-center">
            <input
              id="refund"
              type="checkbox"
              checked={formData.configuration.refund_allowed || false}
              onChange={(e) => handleConfigChange('refund_allowed', e.target.checked)}
              className="h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500 cursor-pointer"
              disabled={isLoading}
            />
            <label htmlFor="refund" className="ml-3 text-sm text-gray-700 cursor-pointer">
              Allow Refunds
            </label>
          </div>
        </div>

        {errors.options && (
          <p className="text-red-600 text-sm mt-3">{errors.options}</p>
        )}
      </div>

      {/* Reason */}
      <div>
        <label htmlFor="reason" className="block text-sm font-medium text-gray-700 mb-2">
          Reason <span className="text-gray-400">(optional)</span>
        </label>
        <textarea
          id="reason"
          value={formData.configuration.reason || ''}
          onChange={(e) => handleConfigChange('reason', e.target.value)}
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          rows="3"
          placeholder="e.g., Standard return policy - 30 day window with full refund or replacement available"
          disabled={isLoading}
        />
        <p className="text-gray-500 text-xs mt-1">Description of this return rule for customers</p>
      </div>

      {/* Submit Error */}
      {errors.submit && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-3">
          <p className="text-red-700 text-sm">{errors.submit}</p>
        </div>
      )}

      {/* Form Actions */}
      <div className="flex gap-3 pt-4">
        <button
          type="submit"
          disabled={isLoading}
          className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed font-medium transition-colors"
        >
          {isLoading ? (
            <span className="flex items-center justify-center">
              <span className="inline-block animate-spin mr-2">⚙️</span>
              Saving...
            </span>
          ) : (
            initialRule ? 'Update Rule' : 'Create Rule'
          )}
        </button>
        
        {initialRule && (
          <button
            type="button"
            onClick={onSuccess}
            disabled={isLoading}
            className="px-4 py-2 text-gray-700 border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 font-medium transition-colors"
          >
            Cancel
          </button>
        )}
      </div>

      {/* Form Info */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 mt-6">
        <p className="text-blue-900 text-sm">
          <strong>📋 Note:</strong> This return rule will be applied to evaluate customer return eligibility.
        </p>
      </div>
    </form>
  );
}
