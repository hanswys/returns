import React, { useState } from 'react';
import { useProducts } from '../../hooks/useApi';

export default function SelectItemsStep({ order, onItemsSelected, onBack }) {
  const [selectedIds, setSelectedIds] = useState([]);
  
  // Use items directly from the order details (now included in API response)
  const orderItems = order.order_items || [];

  const toggleItem = (itemId) => {
    setSelectedIds((prev) =>
      prev.includes(itemId)
        ? prev.filter((id) => id !== itemId)
        : [...prev, itemId]
    );
  };

  const handleContinue = () => {
    // Map selected order_items back to product structure expected by next steps 
    // or just pass the order_item. Next steps might need product_id.
    const selectedItems = orderItems.filter((item) => selectedIds.includes(item.id));
    
    // Transform to format expected by ReasonStep (needs id, name, price)
    // We'll pass the product_id as the main identifier for the return creation
    const itemsForReturn = selectedItems.map(item => ({
      id: item.product_id, // The backend expects product_id for return creation currently
      order_item_id: item.id,
      name: item.product_name,
      sku: item.product_sku,
      price: item.price_at_purchase
    }));

    onItemsSelected(itemsForReturn);
  };

  return (
    <div>
      <h2 className="text-xl font-semibold text-gray-900 mb-2">
        Step 2: Select Items to Return
      </h2>
      <p className="text-gray-600 mb-6">
        Order #{order.order_number} • {order.customer_name}
      </p>

      <div className="space-y-3 mb-8">
        {orderItems.length === 0 ? (
          <p className="text-gray-500 text-center py-8">No items found for this order.</p>
        ) : (
          orderItems.map((item) => {
            const isReturnProcessed = !!item.return_status;
            
            return (
              <label
                key={item.id}
                className={`flex items-center p-4 border rounded-lg transition ${
                  isReturnProcessed 
                    ? 'bg-gray-50 border-gray-200 cursor-not-allowed opacity-75' 
                    : selectedIds.includes(item.id)
                      ? 'border-blue-500 bg-blue-50 cursor-pointer'
                      : 'border-gray-200 hover:border-gray-300 cursor-pointer'
                }`}
              >
                <div className="flex items-center h-5">
                  <input
                    type="checkbox"
                    checked={selectedIds.includes(item.id)}
                    onChange={() => !isReturnProcessed && toggleItem(item.id)}
                    disabled={isReturnProcessed}
                    className="h-5 w-5 text-blue-600 rounded border-gray-300 focus:ring-blue-500 disabled:text-gray-400"
                  />
                </div>
                <div className="ml-4 flex-1">
                  <div className="flex justify-between items-start">
                    <div>
                      <p className="font-medium text-gray-900">{item.product_name}</p>
                      <div className="flex gap-4 text-sm text-gray-500">
                        <span>SKU: {item.product_sku}</span>
                        <span>Qty: {item.quantity}</span>
                      </div>
                    </div>
                    {isReturnProcessed && (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800 capitalize">
                        {item.return_status === 'requested' ? 'Return Requested' : item.return_status.replace('_', ' ')}
                      </span>
                    )}
                  </div>
                </div>
                {!isReturnProcessed && (
                  <span className="text-gray-900 font-medium ml-4">
                    ${parseFloat(item.price_at_purchase).toFixed(2)}
                  </span>
                )}
              </label>
            );
          })
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
