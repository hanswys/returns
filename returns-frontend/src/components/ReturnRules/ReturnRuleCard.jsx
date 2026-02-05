import React from 'react';

export default function ReturnRuleCard({ rule, merchantId, onEdit, onDelete, isLoading = false }) {
  const config = rule.configuration || {};

  const handleDelete = () => {
    if (window.confirm('Are you sure you want to delete this return rule?')) {
      onDelete(rule.id);
    }
  };

  return (
    <div className="bg-white rounded-lg shadow hover:shadow-lg transition-shadow p-6">
      {/* Header */}
      <div className="flex justify-between items-start mb-4">
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-gray-900">
            {config.reason || 'Return Rule'}
          </h3>
          <p className="text-sm text-gray-500 mt-1">
            Rule ID: {rule.id}
          </p>
        </div>

        {/* Actions */}
        <div className="flex gap-2">
          <button
            onClick={() => onEdit(rule)}
            disabled={isLoading}
            className="text-blue-600 hover:text-blue-900 disabled:opacity-50 font-medium text-sm"
          >
            Edit
          </button>
          <button
            onClick={handleDelete}
            disabled={isLoading}
            className="text-red-600 hover:text-red-900 disabled:opacity-50 font-medium text-sm"
          >
            Delete
          </button>
        </div>
      </div>

      {/* Config Details */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 py-4 border-y border-gray-200">
        
        {/* Return Window */}
        <div>
          <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">Return Window</p>
          <p className="text-lg font-semibold text-gray-900 mt-1">
            {config.window_days} <span className="text-sm font-normal text-gray-600">days</span>
          </p>
        </div>

        {/* Return Options */}
        <div>
          <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">Available Options</p>
          <div className="flex gap-4 mt-2">
            <div className="flex items-center gap-2">
              <span className={config.replacement_allowed ? 'text-green-600 text-lg' : 'text-gray-300 text-lg'}>
                {config.replacement_allowed ? '✅' : '❌'}
              </span>
              <span className="text-sm text-gray-700">Replacement</span>
            </div>
            <div className="flex items-center gap-2">
              <span className={config.refund_allowed ? 'text-green-600 text-lg' : 'text-gray-300 text-lg'}>
                {config.refund_allowed ? '✅' : '❌'}
              </span>
              <span className="text-sm text-gray-700">Refund</span>
            </div>
          </div>
        </div>
      </div>

      {/* Description */}
      {config.reason && (
        <div className="mt-4 pt-4 border-t border-gray-200">
          <p className="text-xs font-medium text-gray-500 uppercase tracking-wide mb-2">Description</p>
          <p className="text-sm text-gray-700 leading-relaxed">{config.reason}</p>
        </div>
      )}

      {/* Footer */}
      <div className="mt-4 flex items-center justify-between pt-4 border-t border-gray-200">
        <p className="text-xs text-gray-500">
          Created {new Date(rule.created_at).toLocaleDateString()}
        </p>
        {rule.product_id && (
          <span className="inline-block bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded">
            Product-specific
          </span>
        )}
      </div>
    </div>
  );
}
