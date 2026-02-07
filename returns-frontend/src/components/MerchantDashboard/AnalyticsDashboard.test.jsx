import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import AnalyticsDashboard from './AnalyticsDashboard';

// Mock hooks directly
vi.mock('../../hooks/useApi', () => ({
  useMerchants: vi.fn(),
  useMerchantAnalytics: vi.fn(),
}));

import { useMerchants, useMerchantAnalytics } from '../../hooks/useApi';

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

describe('AnalyticsDashboard', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    useMerchants.mockReturnValue({
      data: { data: [{ id: 1, name: 'Test Store' }] },
      isLoading: false,
    });
    useMerchantAnalytics.mockReturnValue({
      data: undefined,
      isLoading: false,
    });
  });

  it('renders the analytics title', () => {
    render(<AnalyticsDashboard />, { wrapper: createWrapper() });
    expect(screen.getByText(/return analytics/i)).toBeInTheDocument();
  });

  it('shows merchant in dropdown', () => {
    render(<AnalyticsDashboard />, { wrapper: createWrapper() });
    expect(screen.getByText('Test Store')).toBeInTheDocument();
  });

  it('shows prompt when no merchant selected', () => {
    render(<AnalyticsDashboard />, { wrapper: createWrapper() });
    expect(screen.getByText(/select a merchant to view analytics/i)).toBeInTheDocument();
  });

  it('renders the merchant selector', () => {
    render(<AnalyticsDashboard />, { wrapper: createWrapper() });
    expect(screen.getByRole('combobox')).toBeInTheDocument();
  });
});
