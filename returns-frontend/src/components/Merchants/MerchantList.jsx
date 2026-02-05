import React from 'react';
import { useMerchants } from '../../hooks/useApi';
import MerchantCard from './MerchantCard.jsx';

export default function MerchantList() {
  const { data: response, isLoading, error } = useMerchants();

  if (isLoading) {
    return (
      <div className="flex justify-center items-center py-12">
        <div className="text-gray-500">Loading merchants...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-4 text-red-800">
        Error loading merchants: {error.message}
      </div>
    );
  }

  const merchants = response?.data || [];

  if (merchants.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500">No merchants found. Create one to get started.</p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {merchants.map((merchant) => (
        <MerchantCard key={merchant.id} merchant={merchant} />
      ))}
    </div>
  );
}
