import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { merchantsAPI, productsAPI, ordersAPI, returnRequestsAPI, returnRulesAPI } from '../api/endpoints';

// Merchants hooks
export const useMerchants = () => useQuery({
  queryKey: ['merchants'],
  queryFn: () => merchantsAPI.getAll(),
});

export const useMerchant = (id) => useQuery({
  queryKey: ['merchant', id],
  queryFn: () => merchantsAPI.getById(id),
  enabled: !!id,
});

export const useCreateMerchant = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data) => merchantsAPI.create(data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['merchants'] }),
  });
};

export const useUpdateMerchant = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }) => merchantsAPI.update(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['merchants'] });
      queryClient.invalidateQueries({ queryKey: ['merchant', id] });
    },
  });
};

export const useDeleteMerchant = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id) => merchantsAPI.delete(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['merchants'] }),
  });
};

// Products hooks
export const useProducts = (merchantId) => useQuery({
  queryKey: ['products', merchantId],
  queryFn: () => productsAPI.getByMerchant(merchantId),
  enabled: !!merchantId,
});

export const useProduct = (merchantId, id) => useQuery({
  queryKey: ['product', merchantId, id],
  queryFn: () => productsAPI.getById(merchantId, id),
  enabled: !!merchantId && !!id,
});

export const useCreateProduct = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ merchantId, data }) => productsAPI.create(merchantId, data),
    onSuccess: (_, { merchantId }) => {
      queryClient.invalidateQueries({ queryKey: ['products', merchantId] });
    },
  });
};

export const useUpdateProduct = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ merchantId, id, data }) => productsAPI.update(merchantId, id, data),
    onSuccess: (_, { merchantId, id }) => {
      queryClient.invalidateQueries({ queryKey: ['products', merchantId] });
      queryClient.invalidateQueries({ queryKey: ['product', merchantId, id] });
    },
  });
};

export const useDeleteProduct = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ merchantId, id }) => productsAPI.delete(merchantId, id),
    onSuccess: (_, { merchantId }) => {
      queryClient.invalidateQueries({ queryKey: ['products', merchantId] });
    },
  });
};

// Orders hooks
export const useOrders = () => useQuery({
  queryKey: ['orders'],
  queryFn: () => ordersAPI.getAll(),
});

export const useOrder = (id) => useQuery({
  queryKey: ['order', id],
  queryFn: () => ordersAPI.getById(id),
  enabled: !!id,
});

export const useCreateOrder = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data) => ordersAPI.create(data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['orders'] }),
  });
};

// Customer portal order lookup
export const useOrderLookup = () => {
  return useMutation({
    mutationFn: ({ email, orderNumber }) => ordersAPI.lookup(email, orderNumber),
  });
};

// Return Requests hooks
export const useReturnRequests = () => useQuery({
  queryKey: ['returnRequests'],
  queryFn: () => returnRequestsAPI.getAll(),
});

export const useReturnRequest = (id) => useQuery({
  queryKey: ['returnRequest', id],
  queryFn: () => returnRequestsAPI.getById(id),
  enabled: !!id,
});

export const useCreateReturnRequest = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data) => returnRequestsAPI.create(data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['returnRequests'] }),
  });
};

export const useApproveReturnRequest = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id) => returnRequestsAPI.approve(id),
    onSuccess: (_, id) => {
      queryClient.invalidateQueries({ queryKey: ['returnRequests'] });
      queryClient.invalidateQueries({ queryKey: ['returnRequest', id] });
    },
  });
};

export const useRejectReturnRequest = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id) => returnRequestsAPI.reject(id),
    onSuccess: (_, id) => {
      queryClient.invalidateQueries({ queryKey: ['returnRequests'] });
      queryClient.invalidateQueries({ queryKey: ['returnRequest', id] });
    },
  });
};

// Return Rules hooks
export const useReturnRules = (merchantId) => useQuery({
  queryKey: ['returnRules', merchantId],
  queryFn: () => returnRulesAPI.getByMerchant(merchantId),
  enabled: !!merchantId,
});

export const useReturnRule = (merchantId, id) => useQuery({
  queryKey: ['returnRule', merchantId, id],
  queryFn: () => returnRulesAPI.getById(merchantId, id),
  enabled: !!merchantId && !!id,
});

export const useCreateReturnRule = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ merchantId, data }) => returnRulesAPI.create(merchantId, data),
    onSuccess: (_, { merchantId }) => {
      queryClient.invalidateQueries({ queryKey: ['returnRules', merchantId] });
    },
  });
};
