# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateShippingLabelJob, type: :job do
  include ActiveJob::TestHelper

  let(:merchant) { create(:merchant) }
  let(:product) { create(:product, merchant: merchant) }
  let(:order) { create(:order, merchant: merchant) }
  let(:return_request) { create(:return_request, merchant: merchant, order: order, product: product, status: :requested) }

  before do
    # Speed up tests by removing the sleep
    allow_any_instance_of(described_class).to receive(:simulate_carrier_delay)
  end

  after do
    # Clean up generated PDFs
    FileUtils.rm_rf(Rails.root.join('public', 'labels'))
  end

  describe '#perform' do
    context 'with valid return request' do
      it 'generates a shipping label' do
        described_class.perform_now(return_request.id)

        return_request.reload
        expect(return_request.tracking_number).to be_present
        expect(return_request.carrier).to be_present
        expect(return_request.label_url).to be_present
      end

      it 'transitions the return request to approved' do
        described_class.perform_now(return_request.id)

        return_request.reload
        expect(return_request.status).to eq('approved')
      end

      it 'clears any previous failure data' do
        return_request.update_columns(
          label_generation_failed_at: 1.hour.ago,
          label_generation_error: 'Previous error'
        )

        described_class.perform_now(return_request.id)

        return_request.reload
        expect(return_request.label_generation_failed_at).to be_nil
        expect(return_request.label_generation_error).to be_nil
      end
    end

    context 'when return request is not in requested state' do
      before { return_request.update!(status: :approved) }

      it 'skips processing' do
        expect(ShippingLabelGenerator).not_to receive(:new)

        described_class.perform_now(return_request.id)
      end
    end

    context 'when return request does not exist' do
      it 'discards the job without raising' do
        expect { described_class.perform_now(999999) }.not_to raise_error
      end
    end

    context 'when label generation fails' do
      before do
        allow_any_instance_of(ShippingLabelGenerator).to receive(:generate).and_raise(StandardError, 'Carrier API error')
      end

      it 'records the failure on the return request' do
        # With retry_on, the error is caught and may be retried
        # We expect the failure to be recorded before re-raising
        begin
          described_class.perform_now(return_request.id)
        rescue StandardError
          # Expected to raise after recording failure
        end

        return_request.reload
        expect(return_request.label_generation_failed_at).to be_present
        expect(return_request.label_generation_error).to include('Carrier API error')
      end

      it 'keeps the return request in requested state' do
        begin
          described_class.perform_now(return_request.id)
        rescue StandardError
          # Expected
        end

        return_request.reload
        expect(return_request.status).to eq('requested')
      end
    end
  end

  describe 'job configuration' do
    it 'uses the default queue' do
      expect(described_class.new.queue_name).to eq('default')
    end

    it 'is configured with retry_on' do
      # Check that the job class has retry handlers configured
      expect(described_class.rescue_handlers).not_to be_empty
    end

    it 'discards job when record not found' do
      # Verify the discard_on behavior by testing it directly
      expect { described_class.perform_now(999999) }.not_to raise_error
    end
  end
end
