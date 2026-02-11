import React, { useState } from 'react';
import { useMerchantReturns, useMerchants, useMerchantAnalytics } from '../../hooks/useApi';
import { returnRequestsAPI } from '../../api/endpoints';
import { useQueryClient } from '@tanstack/react-query';
import AuditLogModal from './AuditLogModal';

const STATUS_BADGES = {
  requested: { label: 'Pending', color: 'bg-yellow-100 text-yellow-800' },
  approved: { label: 'Approved', color: 'bg-green-100 text-green-800' },
  rejected: { label: 'Rejected', color: 'bg-red-100 text-red-800' },
  shipped: { label: 'Shipped', color: 'bg-blue-100 text-blue-800' },
  received: { label: 'Received', color: 'bg-purple-100 text-purple-800' },
  resolved: { label: 'Resolved', color: 'bg-gray-100 text-gray-800' },
};

const STATUS_FILTERS = [
  { value: '', label: 'All Status' },
  { value: 'requested', label: 'Pending' },
  { value: 'approved', label: 'Approved' },
  { value: 'shipped', label: 'Shipped' },
  { value: 'received', label: 'Received' },
  { value: 'resolved', label: 'Resolved' },
];

export default function MerchantReturns() {
  const [selectedMerchant, setSelectedMerchant] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [auditLogId, setAuditLogId] = useState(null);
  const queryClient = useQueryClient();

  const { data: merchantsResponse, isLoading: loadingMerchants } = useMerchants();
  const { data: returnsResponse, isLoading: loadingReturns, refetch } = useMerchantReturns(
    selectedMerchant,
    statusFilter || undefined
  );
  const { data: analyticsResponse } = useMerchantAnalytics(selectedMerchant);

  const merchants = merchantsResponse?.data || [];
  const returns = returnsResponse?.data || [];
  const analytics = analyticsResponse?.data || null;

  const handleAction = async (returnId, action) => {
    try {
      await returnRequestsAPI[action](returnId);
      refetch();
      queryClient.invalidateQueries({ queryKey: ['merchantReturns'] });
    } catch (error) {
      console.error(`Failed to ${action}:`, error);
    }
  };

  return (
    <div className="bg-white rounded-xl shadow-lg p-6">
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Returns Dashboard</h2>
        
        {/* Filters */}
        <div className="flex gap-4 flex-wrap mb-6">
          <select
            value={selectedMerchant}
            onChange={(e) => setSelectedMerchant(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Select a Merchant</option>
            {merchants.map((m) => (
              <option key={m.id} value={m.id}>{m.name}</option>
            ))}
          </select>

          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            disabled={!selectedMerchant}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:opacity-50"
          >
            {STATUS_FILTERS.map((f) => (
              <option key={f.value} value={f.value}>{f.label}</option>
            ))}
          </select>

          <button
            onClick={() => refetch()}
            disabled={!selectedMerchant}
            className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 disabled:opacity-50"
          >
            Refresh
          </button>
        </div>

        {/* Analytics Summary */}
        {selectedMerchant && analytics && (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
            <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl p-4 text-white shadow">
              <p className="text-sm opacity-80">Total Returns</p>
              <p className="text-3xl font-bold">{analytics.summary.total_returns}</p>
            </div>
            <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-xl p-4 text-white shadow">
              <p className="text-sm opacity-80">Resolved</p>
              <p className="text-3xl font-bold">{analytics.summary.by_status?.resolved || 0}</p>
            </div>
            <div className="bg-gradient-to-br from-yellow-500 to-yellow-600 rounded-xl p-4 text-white shadow">
              <p className="text-sm opacity-80">Pending</p>
              <p className="text-3xl font-bold">{analytics.summary.by_status?.requested || 0}</p>
            </div>
          </div>
        )}
      </div>

      {!selectedMerchant ? (
        <div className="text-center py-12 text-gray-500">
          Select a merchant to view their return requests
        </div>
      ) : loadingReturns ? (
        <div className="text-center py-12 text-gray-500">Loading returns...</div>
      ) : returns.length === 0 ? (
        <div className="text-center py-12 text-gray-500">No return requests found</div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-200">
                <th className="text-left py-3 px-4 font-semibold text-gray-700">ID</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Order</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Reason</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Status</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Tracking</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Date</th>
                <th className="text-left py-3 px-4 font-semibold text-gray-700">Actions</th>
              </tr>
            </thead>
            <tbody>
              {returns.map((ret) => {
                const statusInfo = STATUS_BADGES[ret.status] || STATUS_BADGES.requested;
                return (
                  <tr key={ret.id} className="border-b border-gray-100 hover:bg-gray-50">
                    <td className="py-3 px-4 font-mono text-sm">#{ret.id}</td>
                    <td className="py-3 px-4">#{ret.order_id}</td>
                    <td className="py-3 px-4 max-w-xs truncate" title={ret.reason}>
                      {ret.reason}
                    </td>
                    <td className="py-3 px-4">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${statusInfo.color}`}>
                        {statusInfo.label}
                      </span>
                    </td>
                    <td className="py-3 px-4 font-mono text-xs">
                      {ret.tracking_number || '—'}
                    </td>
                    <td className="py-3 px-4 text-sm text-gray-600">
                      {new Date(ret.created_at).toLocaleDateString()}
                    </td>
                    <td className="py-3 px-4">
                      <div className="flex gap-2">
                        {ret.status === 'requested' && (
                          <>
                            <button
                              onClick={() => handleAction(ret.id, 'approve')}
                              className="px-2 py-1 text-xs bg-green-100 text-green-700 rounded hover:bg-green-200"
                            >
                              Approve
                            </button>
                            <button
                              onClick={() => handleAction(ret.id, 'reject')}
                              className="px-2 py-1 text-xs bg-red-100 text-red-700 rounded hover:bg-red-200"
                            >
                              Reject
                            </button>
                          </>
                        )}
                        {ret.status === 'approved' && (
                          <button
                            onClick={() => handleAction(ret.id, 'ship')}
                            className="px-2 py-1 text-xs bg-blue-100 text-blue-700 rounded hover:bg-blue-200"
                          >
                            Mark Shipped
                          </button>
                        )}
                        {ret.status === 'received' && (
                          <button
                            onClick={() => handleAction(ret.id, 'resolve')}
                            className="px-2 py-1 text-xs bg-purple-100 text-purple-700 rounded hover:bg-purple-200"
                          >
                            Resolve
                          </button>
                        )}
                        {ret.label_url && (
                          <a
                            href={returnRequestsAPI.getLabelUrl(ret.label_url)}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded hover:bg-gray-200"
                          >
                            Label
                          </a>
                        )}
                        <button
                          onClick={() => setAuditLogId(ret.id)}
                          className="px-2 py-1 text-xs bg-indigo-100 text-indigo-700 rounded hover:bg-indigo-200"
                        >
                          History
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}

      {/* Audit Log Modal */}
      {auditLogId && (
        <AuditLogModal
          returnRequestId={auditLogId}
          onClose={() => setAuditLogId(null)}
        />
      )}
    </div>
  );
}
