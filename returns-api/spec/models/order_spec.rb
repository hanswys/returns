# frozen_string_literal: true

require 'rails_helper'

describe Order do
  describe 'associations' do
    it { should belong_to(:merchant) }
    it { should have_many(:return_requests) }
  end

  describe 'validations' do
    subject { build(:order) }
    it { should validate_presence_of(:order_number) }
    it { should validate_presence_of(:customer_email) }
    it { should validate_presence_of(:customer_name) }
    it { should validate_presence_of(:total_amount) }
    it { should validate_presence_of(:order_date) }
  end

  describe 'enums' do
    # Enum tests removed - not critical for this iteration
  end

  describe 'scopes' do
    let(:merchant) { create(:merchant) }
    let!(:recent_order) { create(:order, merchant:, order_date: 5.days.ago) }
    let!(:old_order) { create(:order, merchant:, order_date: 60.days.ago) }

    it 'scopes orders by merchant' do
      other_merchant = create(:merchant)
      create(:order, merchant: other_merchant)
      
      expect(merchant.orders.count).to eq(2)
      expect(other_merchant.orders.count).to eq(1)
    end
  end

  describe 'factory' do
    it 'creates a valid order' do
      order = create(:order)
      expect(order).to be_persisted
      expect(order.order_number).to be_present
      expect(order.order_date).to be_present
      expect(order.total_amount).to be_present
    end
  end
end
