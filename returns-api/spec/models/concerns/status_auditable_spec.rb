# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusAuditable, type: :model do
  let(:merchant) { create(:merchant) }
  let(:product) { create(:product, merchant: merchant) }
  let(:order) { create(:order, merchant: merchant) }
  let(:return_request) { create(:return_request, order: order, product: product, merchant: merchant) }

  describe 'associations' do
    it 'has many status_audit_logs' do
      expect(return_request).to respond_to(:status_audit_logs)
    end
  end

  describe 'audit logging on state transitions' do
    it 'creates audit log when status changes' do
      expect {
        return_request.approve!
      }.to change(StatusAuditLog, :count).by(1)
    end

    it 'logs correct from_status and to_status' do
      return_request.approve!
      log = return_request.status_audit_logs.last

      expect(log.from_status).to eq('requested')
      expect(log.to_status).to eq('approved')
    end

    it 'logs the event name' do
      return_request.approve!
      log = return_request.status_audit_logs.last

      expect(log.event).to eq('approve')
    end

    it 'logs the actor from Current.actor' do
      Current.actor = 'test:user123'
      return_request.approve!
      log = return_request.status_audit_logs.last

      expect(log.triggered_by).to eq('test:user123')
    end

    it 'defaults to system when no actor set' do
      Current.actor = nil
      return_request.approve!
      log = return_request.status_audit_logs.last

      expect(log.triggered_by).to eq('system')
    end

    it 'includes metadata with transitioned_at' do
      return_request.approve!
      log = return_request.status_audit_logs.last

      expect(log.metadata).to include('transitioned_at')
      expect(log.metadata).to include('request_id')
    end
  end
end
