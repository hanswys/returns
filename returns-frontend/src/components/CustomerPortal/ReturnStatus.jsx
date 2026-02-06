import React, { useState, useEffect } from 'react';
import { useReturnRequest } from '../../hooks/useApi';
import { returnRequestsAPI } from '../../api/endpoints';

const STATUS_DISPLAY = {
  requested: { label: 'Processing', color: 'bg-yellow-100 text-yellow-800', processing: true },
  approved: { label: 'Approved', color: 'bg-green-100 text-green-800', processing: false },
  rejected: { label: 'Rejected', color: 'bg-red-100 text-red-800', processing: false },
  shipped: { label: 'Shipped', color: 'bg-blue-100 text-blue-800', processing: false },
  received: { label: 'Received', color: 'bg-purple-100 text-purple-800', processing: false },
  resolved: { label: 'Resolved', color: 'bg-gray-100 text-gray-800', processing: false },
};

export default function ReturnStatus({ returnRequest: initialRequest, onStartOver }) {
  const [returnRequest, setReturnRequest] = useState(initialRequest);
  const [isPolling, setIsPolling] = useState(true);
  
  // Poll for updates while status is 'requested'
  const { data: polledData, refetch } = useReturnRequest(returnRequest.id);

  useEffect(() => {
    if (!isPolling) return;

    const interval = setInterval(() => {
      refetch();
    }, 2000); // Poll every 2 seconds

    return () => clearInterval(interval);
  }, [isPolling, refetch]);

  useEffect(() => {
    if (polledData?.data) {
      setReturnRequest(polledData.data);
      
      // Stop polling once we have a label or status changed from 'requested'
      if (polledData.data.status !== 'requested' || polledData.data.label_url) {
        setIsPolling(false);
      }
    }
  }, [polledData]);

  const statusInfo = STATUS_DISPLAY[returnRequest.status] || STATUS_DISPLAY.requested;
  const hasLabel = returnRequest.label_url && returnRequest.tracking_number;

  const handleDownloadLabel = () => {
    const labelUrl = returnRequestsAPI.getLabelUrl(returnRequest.label_url);
    window.open(labelUrl, '_blank');
  };

  return (
    <div className="text-center">
      <div className="mb-6">
        {statusInfo.processing ? (
          // Processing animation
          <div className="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg className="animate-spin h-8 w-8 text-yellow-600" fill="none" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
            </svg>
          </div>
        ) : (
          // Success checkmark
          <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
            </svg>
          </div>
        )}
        
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          {statusInfo.processing ? 'Generating Shipping Label...' : 'Return Request Approved!'}
        </h2>
        <p className="text-gray-600">
          {statusInfo.processing 
            ? 'Please wait while we prepare your shipping label.'
            : 'Your return has been approved. Download your shipping label below.'}
        </p>
      </div>

      <div className="bg-gray-50 rounded-lg p-6 mb-6 text-left">
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
          
          {hasLabel && (
            <>
              <div className="flex justify-between">
                <span className="text-gray-600">Tracking Number</span>
                <span className="font-mono font-medium text-gray-900">{returnRequest.tracking_number}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Carrier</span>
                <span className="font-medium text-gray-900">{returnRequest.carrier}</span>
              </div>
            </>
          )}
          
          <div className="flex justify-between">
            <span className="text-gray-600">Reason</span>
            <span className="font-medium text-gray-900 text-right max-w-xs truncate">
              {returnRequest.reason}
            </span>
          </div>
        </div>
      </div>

      {/* Download Label Button */}
      {hasLabel && (
        <div className="mb-6">
          <button
            onClick={handleDownloadLabel}
            className="w-full py-4 px-6 bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-medium rounded-xl hover:from-blue-700 hover:to-indigo-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition flex items-center justify-center space-x-3"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <span>Download Shipping Label (PDF)</span>
          </button>
          <p className="text-sm text-gray-500 mt-2">
            Print this label and attach it to your package
          </p>
        </div>
      )}

      {/* Processing indicator */}
      {statusInfo.processing && (
        <div className="mb-6">
          <div className="relative pt-1">
            <div className="overflow-hidden h-2 text-xs flex rounded bg-gray-200">
              <div className="animate-pulse bg-blue-500 rounded w-full"></div>
            </div>
          </div>
          <p className="text-sm text-gray-500 mt-2">
            This usually takes about 5-10 seconds...
          </p>
        </div>
      )}

      <div className="space-y-3">
        {!statusInfo.processing && (
          <p className="text-sm text-gray-500">
            You will receive an email confirmation with tracking updates.
          </p>
        )}
        <button
          onClick={onStartOver}
          className="px-6 py-3 text-blue-600 font-medium rounded-lg hover:bg-blue-50 transition"
        >
          Submit Another Return
        </button>
      </div>
    </div>
  );
}
