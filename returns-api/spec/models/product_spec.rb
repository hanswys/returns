# frozen_string_literal: true

require 'rails_helper'

describe Product do
  describe 'associations' do
    it { should belong_to(:merchant) }
    it { should have_many(:return_rules) }
    it { should have_many(:return_requests) }
  end

  describe 'validations' do
    subject { build(:product) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:sku) }
    it { should validate_presence_of(:price) }
  end

  describe 'factory' do
    it 'creates a valid product' do
      product = create(:product)
      expect(product).to be_persisted
      expect(product.name).to be_present
      expect(product.sku).to be_present
    end
  end
end
