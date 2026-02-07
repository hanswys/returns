import apiClient from './apiClient';

// Merchants API
export const merchantsAPI = {
  getAll: () => apiClient.get('/merchants'),
  getById: (id) => apiClient.get(`/merchants/${id}`),
  create: (data) => apiClient.post('/merchants', { merchant: data }),
  update: (id, data) => apiClient.put(`/merchants/${id}`, { merchant: data }),
  delete: (id) => apiClient.delete(`/merchants/${id}`),
};

// Products API
export const productsAPI = {
  getByMerchant: (merchantId) => apiClient.get(`/merchants/${merchantId}/products`),
  getById: (merchantId, id) => apiClient.get(`/merchants/${merchantId}/products/${id}`),
  create: (merchantId, data) => apiClient.post(`/merchants/${merchantId}/products`, { product: data }),
  update: (merchantId, id, data) => apiClient.put(`/merchants/${merchantId}/products/${id}`, { product: data }),
  delete: (merchantId, id) => apiClient.delete(`/merchants/${merchantId}/products/${id}`),
};

// Orders API
export const ordersAPI = {
  getAll: () => apiClient.get('/orders'),
  getById: (id) => apiClient.get(`/orders/${id}`),
  lookup: (email, orderNumber) => apiClient.get('/orders/lookup', { params: { email, order_number: orderNumber } }),
  create: (data) => apiClient.post('/orders', { order: data }),
  update: (id, data) => apiClient.put(`/orders/${id}`, { order: data }),
  delete: (id) => apiClient.delete(`/orders/${id}`),
};

// Return Requests API
export const returnRequestsAPI = {
  getAll: () => apiClient.get('/return_requests'),
  getById: (id) => apiClient.get(`/return_requests/${id}`),
  getByMerchant: (merchantId, status) => {
    const params = status ? { status } : {};
    return apiClient.get(`/merchants/${merchantId}/returns`, { params });
  },
  create: (data) => apiClient.post('/return_requests', { return_request: data }),
  createBatch: (data) => apiClient.post('/return_requests/batch', data),
  update: (id, data) => apiClient.put(`/return_requests/${id}`, { return_request: data }),
  delete: (id) => apiClient.delete(`/return_requests/${id}`),
  approve: (id) => apiClient.patch(`/return_requests/${id}/approve`),
  reject: (id) => apiClient.patch(`/return_requests/${id}/reject`),
  ship: (id) => apiClient.patch(`/return_requests/${id}/ship`),
  markReceived: (id) => apiClient.patch(`/return_requests/${id}/mark_received`),
  resolve: (id) => apiClient.patch(`/return_requests/${id}/resolve`),
  getAuditLogs: (id) => apiClient.get(`/return_requests/${id}/audit_logs`),
  getLabelUrl: (labelUrl) => `${import.meta.env.VITE_API_URL?.replace('/api/v1', '') || 'http://localhost:3000'}${labelUrl}`,
};

// Return Rules API
export const returnRulesAPI = {
  getByMerchant: (merchantId) => apiClient.get(`/merchants/${merchantId}/return_rules`),
  getById: (merchantId, id) => apiClient.get(`/merchants/${merchantId}/return_rules/${id}`),
  create: (merchantId, data) => apiClient.post(`/merchants/${merchantId}/return_rules`, { return_rule: data }),
  update: (merchantId, id, data) => apiClient.put(`/merchants/${merchantId}/return_rules/${id}`, { return_rule: data }),
  delete: (merchantId, id) => apiClient.delete(`/merchants/${merchantId}/return_rules/${id}`),
};
