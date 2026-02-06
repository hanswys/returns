import React, { useState } from 'react';
import { useCreateReturnRequest } from '../../hooks/useApi';

const RETURN_REASONS = [
  { value: 'defective', label: 'Defective or damaged' },
  { value: 'not_as_described', label: 'Not as described' },
  { value: 'wrong_item', label: 'Received wrong item' },
  { value: 'changed_mind', label: 'Changed my mind' },
  { value: 'better_price', label: 'Found better price elsewhere' },
  { value: 'no_longer_needed', label: 'No longer needed' },
  { value: 'other', label: 'Other reason' },
];

export default function ReasonStep({ order, selectedProducts, onSubmit, onBack }) {
  const [reason, setReason] = useState('');
  const [additionalNotes, setAdditionalNotes] = useState('');
  const createReturnRequest = useCreateReturnRequest();

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Create a return request for each selected product
    const requests = selectedProducts.map((product) => ({
      order_id: order.id,
      product_id: product.id,
      merchant_id: order.merchant_id,
      reason: additionalNotes ? `${reason}: ${additionalNotes}` : reason,
      requested_date: new Date().toISOString().split('T')[0],
    }));

    try {
      // Submit first request (for simplicity, could batch in production)
      const response = await createReturnRequest.mutateAsync(requests[0]);
      onSubmit(response.data);
    } catch (error) {
      // Error handled by mutation state
    }
  };

  return (
    <div>
      <h2 className="text-xl font-semibold text-gray-900 mb-2">
        Step 3: Reason for Return
      </h2>
      <p className="text-gray-600 mb-6">
        {selectedProducts.length} {selectedProducts.length === 1 ? 'item' : 'items'} selected
      </p>

      {/* Selected items summary */}
      <div className="bg-gray-50 rounded-lg p-4 mb-6">
        <h3 className="text-sm font-medium text-gray-700 mb-3">Items to return:</h3>
        <ul className="space-y-2">
          {selectedProducts.map((product) => (
            <li key={product.id} className="flex justify-between text-sm">
              <span className="text-gray-900">{product.name}</span>
              <span className="text-gray-600">${parseFloat(product.price).toFixed(2)}</span>
            </li>
          ))}
        </ul>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-3">
            Why are you returning these items?
          </label>
          <div className="space-y-2">
            {RETURN_REASONS.map((option) => (
              <label
                key={option.value}
                className={`flex items-center p-3 border rounded-lg cursor-pointer transition ${
                  reason === option.value
                    ? 'border-blue-500 bg-blue-50'
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <input
                  type="radio"
                  name="reason"
                  value={option.value}
                  checked={reason === option.value}
                  onChange={(e) => setReason(e.target.value)}
                  className="h-4 w-4 text-blue-600 border-gray-300 focus:ring-blue-500"
                />
                <span className="ml-3 text-gray-900">{option.label}</span>
              </label>
            ))}
          </div>
        </div>

        <div>
          <label htmlFor="notes" className="block text-sm font-medium text-gray-700 mb-2">
            Additional details (optional)
          </label>
          <textarea
            id="notes"
            value={additionalNotes}
            onChange={(e) => setAdditionalNotes(e.target.value)}
            rows={3}
            placeholder="Provide any additional information about your return..."
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition resize-none"
          />
        </div>

        {createReturnRequest.isError && (
          <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
            <p className="text-sm text-red-600">
              Failed to submit return request. Please try again.
            </p>
          </div>
        )}

        <div className="flex justify-between">
          <button
            type="button"
            onClick={onBack}
            className="px-6 py-3 text-gray-700 font-medium rounded-lg hover:bg-gray-100 transition"
          >
            Back
          </button>
          <button
            type="submit"
            disabled={!reason || createReturnRequest.isPending}
            className="px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition"
          >
            {createReturnRequest.isPending ? 'Submitting...' : 'Submit Return Request'}
          </button>
        </div>
      </form>
    </div>
  );
}
