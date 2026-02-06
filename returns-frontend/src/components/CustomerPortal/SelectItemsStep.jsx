import React, { useState } from 'react';
import { useProducts } from '../../hooks/useApi';

export default function SelectItemsStep({ order, onItemsSelected, onBack }) {
  const [selectedIds, setSelectedIds] = useState([]);
  const { data: productsResponse, isLoading, isError } = useProducts(order.merchant_id);

  const products = productsResponse?.data || [];

  const toggleProduct = (productId) => {
    setSelectedIds((prev) =>
      prev.includes(productId)
        ? prev.filter((id) => id !== productId)
        : [...prev, productId]
    );
  };

  const handleContinue = () => {
    const selectedProducts = products.filter((p) => selectedIds.includes(p.id));
    onItemsSelected(selectedProducts);
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <svg className="animate-spin h-8 w-8 text-blue-600" fill="none" viewBox="0 0 24 24">
          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
        </svg>
      </div>
    );
  }

  if (isError) {
    return (
      <div className="text-center py-12">
        <p className="text-red-600">Failed to load products. Please try again.</p>
        <button onClick={onBack} className="mt-4 text-blue-600 hover:underline">
          Go Back
        </button>
      </div>
    );
  }

  return (
    <div>
      <h2 className="text-xl font-semibold text-gray-900 mb-2">
        Step 2: Select Items to Return
      </h2>
      <p className="text-gray-600 mb-6">
        Order #{order.order_number} • {order.customer_name}
      </p>

      <div className="space-y-3 mb-8">
        {products.length === 0 ? (
          <p className="text-gray-500 text-center py-8">No products available for this order.</p>
        ) : (
          products.map((product) => (
            <label
              key={product.id}
              className={`flex items-center p-4 border rounded-lg cursor-pointer transition ${
                selectedIds.includes(product.id)
                  ? 'border-blue-500 bg-blue-50'
                  : 'border-gray-200 hover:border-gray-300'
              }`}
            >
              <input
                type="checkbox"
                checked={selectedIds.includes(product.id)}
                onChange={() => toggleProduct(product.id)}
                className="h-5 w-5 text-blue-600 rounded border-gray-300 focus:ring-blue-500"
              />
              <div className="ml-4 flex-1">
                <p className="font-medium text-gray-900">{product.name}</p>
                <p className="text-sm text-gray-500">SKU: {product.sku}</p>
              </div>
              <span className="text-gray-900 font-medium">
                ${parseFloat(product.price).toFixed(2)}
              </span>
            </label>
          ))
        )}
      </div>

      <div className="flex justify-between">
        <button
          onClick={onBack}
          className="px-6 py-3 text-gray-700 font-medium rounded-lg hover:bg-gray-100 transition"
        >
          Back
        </button>
        <button
          onClick={handleContinue}
          disabled={selectedIds.length === 0}
          className="px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition"
        >
          Continue ({selectedIds.length} {selectedIds.length === 1 ? 'item' : 'items'})
        </button>
      </div>
    </div>
  );
}
