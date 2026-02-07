# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusAuditLog, type: :model do
  let(:merchant) { create(:merchant) }
  let(:product) { create(:product, merchant: merchant) }
  let(:order) { create(:order, merchant: merchant, order_date: 5.days.ago) }
  let!(:return_rule) { create(:return_rule, merchant: merchant, configuration: { 'window_days' => 30, 'replacement_allowed' => true, 'refund_allowed' => true }) }
  let(:return_request) { create(:return_request, merchant: merchant, order: order, product: product) }

  describe 'validations' do
    it 'requires to_status' do
      log = StatusAuditLog.new(return_request: return_request, event: 'approve', triggered_by: 'system')
      expect(log).not_to be_valid
      expect(log.errors[:to_status]).to be_present
    end

    it 'requires event' do
      log = StatusAuditLog.new(return_request: return_request, to_status: 'approved', triggered_by: 'system')
      expect(log).not_to be_valid
      expect(log.errors[:event]).to be_present
    end

    it 'requires triggered_by' do
      log = StatusAuditLog.new(return_request: return_request, to_status: 'approved', event: 'approve')
      expect(log).not_to be_valid
      expect(log.errors[:triggered_by]).to be_present
    end
  end

  describe 'AASM callback integration' do
    it 'creates audit log on state transition' do
      expect { return_request.approve! }.to change(StatusAuditLog, :count).by(1)
    end

    it 'logs correct transition details' do
      return_request.approve!
      log = return_request.status_audit_logs.last

      expect(log.from_status).to eq('requested')
      expect(log.to_status).to eq('approved')
      expect(log.event).to eq('approve!')
      expect(log.triggered_by).to eq('system')
    end

    it 'uses Current.actor when set' do
      Current.actor = 'admin:123'
      return_request.approve!
      log = return_request.status_audit_logs.last

      expect(log.triggered_by).to eq('admin:123')
    end

    it 'tracks full lifecycle' do
      return_request.approve!
      return_request.ship!
      return_request.mark_received!
      return_request.resolve!

      expect(return_request.status_audit_logs.count).to eq(4)

      events = return_request.status_audit_logs.order(:created_at).pluck(:event)
      expect(events).to eq(%w[approve! ship! mark_received! resolve!])
    end
  end

  describe 'scopes' do
    before do
      return_request.approve!
      return_request.ship!
    end

    it '.recent orders by created_at desc' do
      logs = return_request.status_audit_logs.recent
      expect(logs.first.event).to eq('ship!')
    end

    it '.for_event filters by event name' do
      logs = StatusAuditLog.for_event('approve!')
      expect(logs.count).to eq(1)
    end
  end
end
