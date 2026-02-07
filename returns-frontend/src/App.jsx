import { useState } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import './index.css';
import Dashboard from './pages/Dashboard.jsx';
import { CustomerPortal } from './components/CustomerPortal';
import MerchantReturns from './components/MerchantDashboard/MerchantReturns';
import AnalyticsDashboard from './components/MerchantDashboard/AnalyticsDashboard';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
      staleTime: 1000 * 60 * 5, // 5 minutes
    },
  },
});

const TABS = [
  { id: 'portal', label: 'Customer Portal' },
  { id: 'merchant', label: 'Merchant Dashboard' },
  { id: 'analytics', label: 'Analytics' },
  { id: 'admin', label: 'Admin' },
];

function App() {
  const [activeTab, setActiveTab] = useState('portal');

  return (
    <QueryClientProvider client={queryClient}>
      <div className="min-h-screen bg-gray-100">
        {/* Navigation */}
        <nav className="bg-white shadow-sm border-b">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between h-16">
              <div className="flex items-center">
                <h1 className="text-xl font-bold text-gray-900">
                  Smart Reverse Logistics
                </h1>
              </div>
              <div className="flex items-center space-x-1">
                {TABS.map((tab) => (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`px-4 py-2 rounded-lg font-medium transition ${
                      activeTab === tab.id
                        ? 'bg-blue-100 text-blue-700'
                        : 'text-gray-600 hover:bg-gray-100'
                    }`}
                  >
                    {tab.label}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </nav>

        {/* Content */}
        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {activeTab === 'portal' && <CustomerPortal />}
          {activeTab === 'merchant' && <MerchantReturns />}
          {activeTab === 'analytics' && <AnalyticsDashboard />}
          {activeTab === 'admin' && <Dashboard />}
        </main>
      </div>
    </QueryClientProvider>
  );
}

export default App;
