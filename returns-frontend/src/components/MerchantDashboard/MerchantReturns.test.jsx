import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import MerchantReturns from './MerchantReturns';

// Mock hooks directly
vi.mock('../../hooks/useApi', () => ({
  useMerchants: vi.fn(),
  useMerchantReturns: vi.fn(),
}));

import { useMerchants, useMerchantReturns } from '../../hooks/useApi';

// Also mock endpoints for the action handlers
vi.mock('../../api/endpoints', () => ({
  returnRequestsAPI: {
    approve: vi.fn(),
    reject: vi.fn(),
    getLabelUrl: vi.fn((url) => url),
  },
}));

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  });
  return ({ children }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
};

describe('MerchantReturns', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    useMerchants.mockReturnValue({
      data: { data: [{ id: 1, name: 'Acme Store' }] },
      isLoading: false,
    });
    useMerchantReturns.mockReturnValue({
      data: undefined,
      isLoading: false,
      refetch: vi.fn(),
    });
  });

  it('renders the dashboard title', () => {
    render(<MerchantReturns />, { wrapper: createWrapper() });
    expect(screen.getByText(/returns dashboard/i)).toBeInTheDocument();
  });

  it('shows merchant names in dropdown', () => {
    render(<MerchantReturns />, { wrapper: createWrapper() });
    expect(screen.getByText('Acme Store')).toBeInTheDocument();
  });

  it('shows prompt when no merchant selected', () => {
    render(<MerchantReturns />, { wrapper: createWrapper() });
    expect(screen.getByText(/select a merchant to view/i)).toBeInTheDocument();
  });

  it('displays the refresh button', () => {
    render(<MerchantReturns />, { wrapper: createWrapper() });
    expect(screen.getByRole('button', { name: /refresh/i })).toBeInTheDocument();
  });

  it('displays status filter dropdown', () => {
    render(<MerchantReturns />, { wrapper: createWrapper() });
    expect(screen.getByText(/all status/i)).toBeInTheDocument();
  });
});
