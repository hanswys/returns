import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import AuditLogModal from './AuditLogModal';

// Mock hooks directly
vi.mock('../../hooks/useApi', () => ({
  useAuditLogs: vi.fn(),
}));

import { useAuditLogs } from '../../hooks/useApi';

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

describe('AuditLogModal', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders status history header', () => {
    useAuditLogs.mockReturnValue({
      data: { data: [] },
      isLoading: false,
      error: null,
    });

    render(<AuditLogModal returnRequestId={1} onClose={() => {}} />, {
      wrapper: createWrapper(),
    });

    expect(screen.getByText(/status history/i)).toBeInTheDocument();
  });

  it('shows loading state', () => {
    useAuditLogs.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    });

    render(<AuditLogModal returnRequestId={1} onClose={() => {}} />, {
      wrapper: createWrapper(),
    });

    expect(screen.getByText(/loading/i)).toBeInTheDocument();
  });

  it('shows empty state when no logs', () => {
    useAuditLogs.mockReturnValue({
      data: { data: [] },
      isLoading: false,
      error: null,
    });

    render(<AuditLogModal returnRequestId={1} onClose={() => {}} />, {
      wrapper: createWrapper(),
    });

    expect(screen.getByText(/no status changes/i)).toBeInTheDocument();
  });

  it('displays audit logs timeline', () => {
    useAuditLogs.mockReturnValue({
      data: {
        data: [
          {
            id: 1,
            from_status: 'requested',
            to_status: 'approved',
            triggered_by: 'Admin',
            created_at: '2026-02-07T12:00:00Z',
          },
        ],
      },
      isLoading: false,
      error: null,
    });

    render(<AuditLogModal returnRequestId={1} onClose={() => {}} />, {
      wrapper: createWrapper(),
    });

    expect(screen.getByText(/requested/i)).toBeInTheDocument();
    expect(screen.getByText(/approved/i)).toBeInTheDocument();
  });

  it('calls onClose when close button clicked', async () => {
    const user = userEvent.setup();
    const onClose = vi.fn();
    useAuditLogs.mockReturnValue({
      data: { data: [] },
      isLoading: false,
      error: null,
    });

    render(<AuditLogModal returnRequestId={1} onClose={onClose} />, {
      wrapper: createWrapper(),
    });

    await user.click(screen.getByRole('button', { name: /close/i }));
    expect(onClose).toHaveBeenCalledTimes(1);
  });
});
