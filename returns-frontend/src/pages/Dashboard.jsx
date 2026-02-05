import React, { useState } from 'react';
import MerchantList from '../components/Merchants/MerchantList.jsx';
import MerchantForm from '../components/Merchants/MerchantForm.jsx';

export default function Dashboard() {
  const [showForm, setShowForm] = useState(false);

  return (
    <div className="min-h-screen bg-gray-100">
      <nav className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-gray-900">
                Smart Reverse Logistics Portal
              </h1>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Merchants</h2>
          <button
            onClick={() => setShowForm(!showForm)}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
          >
            {showForm ? 'Cancel' : 'Add Merchant'}
          </button>
        </div>

        {showForm && (
          <div className="mb-6">
            {/* Renders merchant form when showForm is true */}
            <MerchantForm onSuccess={() => setShowForm(false)} />
          </div>
        )}

        <MerchantList />
      </main>
    </div>
  );
}
