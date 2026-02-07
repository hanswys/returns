# frozen_string_literal: true

# Aggregates return data for merchant analytics
# Provides insights on return reasons by product
#
class ReturnAnalyticsService
  def initialize(merchant_id, date_range: nil)
    @merchant_id = merchant_id
    @date_range = date_range
  end

  def call
    {
      summary: summary,
      by_reason: by_reason,
      by_product: by_product,
      by_product_reason: by_product_reason
    }
  end

  private

  def base_scope
    scope = ReturnRequest.where(merchant_id: @merchant_id)
    scope = scope.where(created_at: @date_range) if @date_range
    scope
  end

  def summary
    total = base_scope.count
    {
      total_returns: total,
      period: @date_range ? 'custom' : 'all_time',
      by_status: base_scope.group(:status).count
    }
  end

  # Returns breakdown by reason
  # [{ reason: "Size Too Small", count: 45, percentage: 35.4 }, ...]
  def by_reason
    total = base_scope.count
    return [] if total.zero?

    reasons = base_scope
      .group(:reason)
      .order('count_id DESC')
      .count(:id)

    reasons.map do |reason, count|
      {
        reason: extract_reason(reason),
        full_reason: reason,
        count: count,
        percentage: (count.to_f / total * 100).round(1)
      }
    end
  end

  # Returns breakdown by product
  # [{ product_id: 1, product_name: "Summer Tee", count: 20, top_reason: "Size" }, ...]
  def by_product
    products = base_scope
      .joins(:product)
      .group('products.id', 'products.name')
      .order('count_id DESC')
      .count(:id)

    products.map do |(product_id, product_name), count|
      top_reason = top_reason_for_product(product_id)
      {
        product_id: product_id,
        product_name: product_name,
        count: count,
        top_reason: top_reason
      }
    end
  end

  # Returns product × reason matrix
  # [{ product_name: "Summer Tee", reason: "Size", count: 14, percentage: 70.0 }, ...]
  def by_product_reason
    results = base_scope
      .joins(:product)
      .group('products.id', 'products.name', :reason)
      .order('products.name', 'count_id DESC')
      .count(:id)

    # Calculate percentages per product
    product_totals = base_scope
      .joins(:product)
      .group('products.id')
      .count(:id)

    results.map do |(product_id, product_name, reason), count|
      product_total = product_totals[product_id] || 1
      {
        product_id: product_id,
        product_name: product_name,
        reason: extract_reason(reason),
        full_reason: reason,
        count: count,
        percentage: (count.to_f / product_total * 100).round(1)
      }
    end
  end

  def top_reason_for_product(product_id)
    reason = base_scope
      .where(product_id: product_id)
      .group(:reason)
      .order('count_id DESC')
      .limit(1)
      .count(:id)
      .keys
      .first

    extract_reason(reason)
  end

  # Extract main reason category from "Category: details" format
  def extract_reason(reason)
    return 'Unknown' if reason.blank?
    reason.to_s.split(':').first.strip
  end
end
