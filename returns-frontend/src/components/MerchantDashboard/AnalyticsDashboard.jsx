import React, { useState } from 'react';
import { useMerchantAnalytics, useMerchants } from '../../hooks/useApi';

// Simple pie chart using SVG
function PieChart({ data, colorScale }) {
  if (!data?.length) return null;
  
  const total = data.reduce((sum, d) => sum + d.count, 0);
  let currentAngle = 0;

  const slices = data.slice(0, 6).map((item, i) => {
    const angle = (item.count / total) * 360;
    const startAngle = currentAngle;
    currentAngle += angle;
    
    const x1 = 50 + 40 * Math.cos((Math.PI * startAngle) / 180);
    const y1 = 50 + 40 * Math.sin((Math.PI * startAngle) / 180);
    const x2 = 50 + 40 * Math.cos((Math.PI * (startAngle + angle)) / 180);
    const y2 = 50 + 40 * Math.sin((Math.PI * (startAngle + angle)) / 180);
    const largeArc = angle > 180 ? 1 : 0;

    return (
      <path
        key={i}
        d={`M 50 50 L ${x1} ${y1} A 40 40 0 ${largeArc} 1 ${x2} ${y2} Z`}
        fill={colorScale[i % colorScale.length]}
        className="hover:opacity-80 transition-opacity"
      />
    );
  });

  return (
    <svg viewBox="0 0 100 100" className="w-full h-48">
      {slices}
    </svg>
  );
}

// Bar chart using divs
function BarChart({ data, maxBars = 5 }) {
  if (!data?.length) return null;
  
  const maxCount = Math.max(...data.map(d => d.count));
  
  return (
    <div className="space-y-2">
      {data.slice(0, maxBars).map((item, i) => (
        <div key={i}>
          <div className="flex justify-between text-sm mb-1">
            <span className="truncate max-w-[200px]" title={item.product_name}>{item.product_name}</span>
            <span className="font-medium">{item.count}</span>
          </div>
          <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
            <div
              className="h-full bg-blue-500 rounded-full transition-all"
              style={{ width: `${(item.count / maxCount) * 100}%` }}
            />
          </div>
        </div>
      ))}
    </div>
  );
}

const COLORS = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899'];

export default function AnalyticsDashboard() {
  const [selectedMerchant, setSelectedMerchant] = useState('');
  
  const { data: merchantsResponse } = useMerchants();
  const { data: analyticsResponse, isLoading, error } = useMerchantAnalytics(selectedMerchant);
  
  const merchants = merchantsResponse?.data || [];
  const analytics = analyticsResponse?.data || null;

  return (
    <div className="bg-white rounded-xl shadow-lg p-6">
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Return Analytics</h2>
        
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
      </div>

      {!selectedMerchant ? (
        <div className="text-center py-12 text-gray-500">
          Select a merchant to view analytics
        </div>
      ) : isLoading ? (
        <div className="text-center py-12 text-gray-500">Loading analytics...</div>
      ) : error ? (
        <div className="text-center py-12 text-red-500">Error loading analytics</div>
      ) : !analytics ? (
        <div className="text-center py-12 text-gray-500">No data available</div>
      ) : (
        <div className="space-y-8">
          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl p-4 text-white">
              <p className="text-sm opacity-80">Total Returns</p>
              <p className="text-3xl font-bold">{analytics.summary.total_returns}</p>
            </div>
            <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-xl p-4 text-white">
              <p className="text-sm opacity-80">Resolved</p>
              <p className="text-3xl font-bold">{analytics.summary.by_status?.resolved || 0}</p>
            </div>
            <div className="bg-gradient-to-br from-yellow-500 to-yellow-600 rounded-xl p-4 text-white">
              <p className="text-sm opacity-80">Pending</p>
              <p className="text-3xl font-bold">{analytics.summary.by_status?.requested || 0}</p>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Reasons Breakdown */}
            <div className="bg-gray-50 rounded-xl p-4">
              <h3 className="font-semibold text-gray-900 mb-4">Returns by Reason</h3>
              <div className="flex gap-4">
                <div className="w-1/2">
                  <PieChart data={analytics.by_reason} colorScale={COLORS} />
                </div>
                <div className="w-1/2 space-y-2">
                  {analytics.by_reason?.slice(0, 5).map((item, i) => (
                    <div key={i} className="flex items-center gap-2 text-sm">
                      <div 
                        className="w-3 h-3 rounded-full" 
                        style={{ backgroundColor: COLORS[i % COLORS.length] }}
                      />
                      <span className="truncate flex-1">{item.reason}</span>
                      <span className="font-medium">{item.percentage}%</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Products Breakdown */}
            <div className="bg-gray-50 rounded-xl p-4">
              <h3 className="font-semibold text-gray-900 mb-4">Returns by Product</h3>
              <BarChart data={analytics.by_product} />
            </div>
          </div>

          {/* Product × Reason Matrix */}
          <div className="bg-gray-50 rounded-xl p-4">
            <h3 className="font-semibold text-gray-900 mb-4">Product Insights</h3>
            <p className="text-sm text-gray-600 mb-4">
              Showing top return reasons for each product
            </p>
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="text-left py-2 px-3 font-semibold">Product</th>
                    <th className="text-left py-2 px-3 font-semibold">Reason</th>
                    <th className="text-right py-2 px-3 font-semibold">Count</th>
                    <th className="text-right py-2 px-3 font-semibold">% of Product</th>
                  </tr>
                </thead>
                <tbody>
                  {analytics.by_product_reason?.slice(0, 10).map((item, i) => (
                    <tr key={i} className="border-b border-gray-100 hover:bg-white">
                      <td className="py-2 px-3">{item.product_name}</td>
                      <td className="py-2 px-3">{item.reason}</td>
                      <td className="py-2 px-3 text-right font-mono">{item.count}</td>
                      <td className="py-2 px-3 text-right">
                        <span className={`px-2 py-0.5 rounded-full text-xs ${
                          item.percentage >= 50 ? 'bg-red-100 text-red-700' : 
                          item.percentage >= 30 ? 'bg-yellow-100 text-yellow-700' : 
                          'bg-green-100 text-green-700'
                        }`}>
                          {item.percentage}%
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
