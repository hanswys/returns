import React from 'react';

const STATUS_DISPLAY = {
  requested: { label: 'Submitted', color: 'bg-yellow-100 text-yellow-800' },
  approved: { label: 'Approved', color: 'bg-green-100 text-green-800' },
  rejected: { label: 'Rejected', color: 'bg-red-100 text-red-800' },
  shipped: { label: 'Shipped', color: 'bg-blue-100 text-blue-800' },
  received: { label: 'Received', color: 'bg-purple-100 text-purple-800' },
  resolved: { label: 'Resolved', color: 'bg-gray-100 text-gray-800' },
};

export default function ReturnStatus({ returnRequest, onStartOver }) {
  const statusInfo = STATUS_DISPLAY[returnRequest.status] || STATUS_DISPLAY.requested;

  return (
    <div className="text-center">
      <div className="mb-6">
        <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Return Request Submitted!
        </h2>
        <p className="text-gray-600">
          We've received your return request and will process it shortly.
        </p>
      </div>

      <div className="bg-gray-50 rounded-lg p-6 mb-8 text-left">
        <h3 className="text-sm font-medium text-gray-500 uppercase tracking-wide mb-4">
          Request Details
        </h3>
        
        <div className="space-y-3">
          <div className="flex justify-between">
            <span className="text-gray-600">Request ID</span>
            <span className="font-medium text-gray-900">#{returnRequest.id}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-600">Status</span>
            <span className={`px-3 py-1 rounded-full text-sm font-medium ${statusInfo.color}`}>
              {statusInfo.label}
            </span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-600">Reason</span>
            <span className="font-medium text-gray-900 text-right max-w-xs truncate">
              {returnRequest.reason}
            </span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-600">Submitted</span>
            <span className="font-medium text-gray-900">
              {new Date(returnRequest.requested_date).toLocaleDateString()}
            </span>
          </div>
        </div>
      </div>

      <div className="space-y-3">
        <p className="text-sm text-gray-500">
          You will receive an email confirmation with further instructions.
        </p>
        <button
          onClick={onStartOver}
          className="px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition"
        >
          Submit Another Return
        </button>
      </div>
    </div>
  );
}
