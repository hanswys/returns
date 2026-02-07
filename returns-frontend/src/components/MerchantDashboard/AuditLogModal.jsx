import React from 'react';
import { useAuditLogs } from '../../hooks/useApi';

export default function AuditLogModal({ returnRequestId, onClose }) {
  const { data, isLoading, error } = useAuditLogs(returnRequestId);
  const logs = data?.data || [];

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl shadow-2xl w-full max-w-lg mx-4 max-h-[80vh] overflow-hidden">
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
          <h2 className="text-xl font-semibold text-gray-900">Status History</h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition"
          >
            <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Content */}
        <div className="px-6 py-4 overflow-y-auto max-h-96">
          {isLoading && (
            <div className="text-center py-8 text-gray-500">Loading...</div>
          )}

          {error && (
            <div className="text-center py-8 text-red-500">Error loading history</div>
          )}

          {!isLoading && logs.length === 0 && (
            <div className="text-center py-8 text-gray-500">No status changes yet</div>
          )}

          {logs.length > 0 && (
            <div className="space-y-4">
              {logs.map((log, index) => (
                <div key={log.id} className="relative pl-6">
                  {/* Timeline line */}
                  {index < logs.length - 1 && (
                    <div className="absolute left-2 top-6 bottom-0 w-0.5 bg-gray-200"></div>
                  )}
                  
                  {/* Timeline dot */}
                  <div className="absolute left-0 top-1.5 w-4 h-4 rounded-full bg-blue-500 border-2 border-white shadow"></div>
                  
                  {/* Content */}
                  <div className="bg-gray-50 rounded-lg p-3">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-sm font-medium text-gray-700">
                        {log.from_status ? (
                          <>
                            <span className="capitalize">{log.from_status}</span>
                            <span className="mx-1">→</span>
                            <span className="capitalize text-blue-600">{log.to_status}</span>
                          </>
                        ) : (
                          <span className="capitalize text-blue-600">{log.to_status}</span>
                        )}
                      </span>
                    </div>
                    <div className="text-xs text-gray-500 flex items-center gap-2">
                      <span>{new Date(log.created_at).toLocaleString()}</span>
                      <span>•</span>
                      <span>{log.triggered_by}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-gray-200">
          <button
            onClick={onClose}
            className="w-full px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition font-medium"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
}
