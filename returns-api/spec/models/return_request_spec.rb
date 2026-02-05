# frozen_string_literal: true

require 'rails_helper'

describe ReturnRequest do
  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:product) }
    it { should belong_to(:merchant) }
  end

  describe 'AASM state machine' do
    let(:return_request) { create(:return_request) }

    it 'starts in requested state' do
      expect(return_request.status).to eq('requested')
    end

    it 'can transition to approved' do
      return_request.approve!
      expect(return_request.status).to eq('approved')
    end

    it 'can transition to rejected' do
      return_request.reject!
      expect(return_request.status).to eq('rejected')
    end
  end

  describe 'validations' do
    subject { build(:return_request) }
    it { should validate_presence_of(:reason) }
    it { should validate_presence_of(:requested_date) }
  end

  describe 'factory' do
    it 'creates a valid return_request' do
      return_request = create(:return_request)
      expect(return_request).to be_persisted
      expect(return_request.reason).to be_present
      expect(return_request.status).to eq('requested')
    end
  end
end
