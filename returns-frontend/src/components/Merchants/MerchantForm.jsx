import React, { useState } from 'react';
import { useCreateMerchant } from '../../hooks/useApi';

export default function MerchantForm({ onSuccess }) {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    contact_person: '',
    address: '',
  });

  const { mutate: createMerchant, isPending } = useCreateMerchant();

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    createMerchant(formData, {
      onSuccess: () => {
        setFormData({ name: '', email: '', contact_person: '', address: '' });
        onSuccess();
      },
    });
  };

  return (
    <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow p-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <input
          type="text"
          name="name"
          placeholder="Merchant Name"
          value={formData.name}
          onChange={handleChange}
          required
          className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <input
          type="email"
          name="email"
          placeholder="Email"
          value={formData.email}
          onChange={handleChange}
          required
          className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <input
          type="text"
          name="contact_person"
          placeholder="Contact Person"
          value={formData.contact_person}
          onChange={handleChange}
          className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <textarea
          name="address"
          placeholder="Address"
          value={formData.address}
          onChange={handleChange}
          className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 md:col-span-2"
        />
      </div>
      <button
        type="submit"
        disabled={isPending}
        className="mt-4 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-400 transition"
      >
        {isPending ? 'Creating...' : 'Create Merchant'}
      </button>
    </form>
  );
}
