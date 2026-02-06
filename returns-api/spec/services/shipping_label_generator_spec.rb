# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShippingLabelGenerator do
  let(:merchant) { create(:merchant, name: 'Test Store', address: '123 Main St') }
  let(:order) { create(:order, merchant: merchant, customer_name: 'John Doe', customer_email: 'john@example.com') }
  let(:product) { create(:product, merchant: merchant) }
  let(:return_request) { create(:return_request, merchant: merchant, order: order, product: product) }

  subject { described_class.new(return_request) }

  describe '#generate' do
    it 'returns a hash with tracking number, carrier, and label info' do
      result = subject.generate

      expect(result).to include(:tracking_number, :carrier, :label_path, :label_url)
    end

    it 'generates a tracking number with merchant prefix' do
      result = subject.generate

      expect(result[:tracking_number]).to start_with('TES-')
    end

    it 'selects a carrier from the available options' do
      result = subject.generate

      expect(ShippingLabelGenerator::CARRIERS).to include(result[:carrier])
    end

    it 'creates a PDF file' do
      result = subject.generate

      expect(File.exist?(result[:label_path])).to be true
    end

    it 'generates a valid label_url' do
      result = subject.generate

      expect(result[:label_url]).to start_with('/labels/')
      expect(result[:label_url]).to end_with('.pdf')
    end
  end

  after do
    # Clean up generated PDFs
    FileUtils.rm_rf(Rails.root.join('public', 'labels'))
  end
end
