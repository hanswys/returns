# frozen_string_literal: true

module ReturnRules
  class Decision
    attr_reader :status, :reason, :metadata

    # status: :approve, :deny
    def initialize(status, reason: nil, metadata: {})
      @status = status.to_sym
      @reason = reason
      @metadata = metadata
    end

    def approve?
      status == :approve
    end

    def deny?
      status == :deny
    end



    def to_h
      { status: status, reason: reason, metadata: metadata }
    end
  end
end
