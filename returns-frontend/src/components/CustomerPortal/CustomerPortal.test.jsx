import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { CustomerPortal } from './index';

// Mock API endpoints
vi.mock('../../api/endpoints', () => ({
  ordersAPI: {
    lookup: vi.fn(),
  },
  returnRequestsAPI: {
    createBatch: vi.fn(),
    getLabelUrl: vi.fn((url) => url),
  },
}));

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });
  return ({ children }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
};

describe('CustomerPortal', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders the return portal title', () => {
    render(<CustomerPortal />, { wrapper: createWrapper() });
    expect(screen.getByText(/return portal/i)).toBeInTheDocument();
  });

  it('renders the stepper with 3 steps', () => {
    render(<CustomerPortal />, { wrapper: createWrapper() });
    expect(screen.getByText(/find order/i)).toBeInTheDocument();
    expect(screen.getByText(/select items/i)).toBeInTheDocument();
    expect(screen.getByText(/reason/i)).toBeInTheDocument();
  });

  it('renders email input field', () => {
    render(<CustomerPortal />, { wrapper: createWrapper() });
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
  });

  it('renders order number input field', () => {
    render(<CustomerPortal />, { wrapper: createWrapper() });
    expect(screen.getByLabelText(/order number/i)).toBeInTheDocument();
  });

  it('renders find order button', () => {
    render(<CustomerPortal />, { wrapper: createWrapper() });
    expect(screen.getByRole('button', { name: /find my order/i })).toBeInTheDocument();
  });
});
