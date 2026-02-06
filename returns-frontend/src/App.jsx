import { useState } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import './index.css';
import Dashboard from './pages/Dashboard.jsx';
import { CustomerPortal } from './components/CustomerPortal';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
      staleTime: 1000 * 60 * 5, // 5 minutes
    },
  },
});

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
                <button
                  onClick={() => setActiveTab('portal')}
                  className={`px-4 py-2 rounded-lg font-medium transition ${
                    activeTab === 'portal'
                      ? 'bg-blue-100 text-blue-700'
                      : 'text-gray-600 hover:bg-gray-100'
                  }`}
                >
                  Customer Portal
                </button>
                <button
                  onClick={() => setActiveTab('admin')}
                  className={`px-4 py-2 rounded-lg font-medium transition ${
                    activeTab === 'admin'
                      ? 'bg-blue-100 text-blue-700'
                      : 'text-gray-600 hover:bg-gray-100'
                  }`}
                >
                  Admin Dashboard
                </button>
              </div>
            </div>
          </div>
        </nav>

        {/* Content */}
        {activeTab === 'portal' ? <CustomerPortal /> : <Dashboard />}
      </div>
    </QueryClientProvider>
  );
}

export default App;
