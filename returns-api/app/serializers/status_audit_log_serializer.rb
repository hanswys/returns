# frozen_string_literal: true

class StatusAuditLogSerializer < ActiveModel::Serializer
  attributes :id, :from_status, :to_status, :event, :triggered_by, :metadata, :created_at

  # Human-readable event name (remove !)
  def event
    object.event.to_s.delete('!')
  end

  # Friendly actor label
  def triggered_by
    case object.triggered_by
    when 'system:label_generator'
      'System (Label Generated)'
    when 'admin:api'
      'Admin'
    when 'webhook:carrier'
      'Carrier Webhook'
    else
      object.triggered_by.humanize
    end
  end
end
