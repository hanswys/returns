import React from 'react';

export default function MerchantCard({ merchant }) {
  const statusColors = {
    active: 'bg-green-100 text-green-800',
    inactive: 'bg-gray-100 text-gray-800',
    suspended: 'bg-red-100 text-red-800',
  };

  const statusColor = statusColors[merchant.status] || 'bg-gray-100 text-gray-800';

  return (
    <div className="bg-white rounded-lg shadow hover:shadow-lg transition">
      <div className="p-6">
        <div className="flex justify-between items-start mb-4">
          <h3 className="text-lg font-semibold text-gray-900">{merchant.name}</h3>
          <span className={`px-3 py-1 rounded-full text-xs font-medium ${statusColor}`}>
            {merchant.status}
          </span>
        </div>
        <p className="text-sm text-gray-600 mb-2">{merchant.email}</p>
        {merchant.contact_person && (
          <p className="text-sm text-gray-600 mb-2">Contact: {merchant.contact_person}</p>
        )}
        {merchant.address && (
          <p className="text-sm text-gray-600 mb-4">{merchant.address}</p>
        )}

      </div>
    </div>
  );
}
