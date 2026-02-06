# frozen_string_literal: true

require 'prawn'
require 'rqrcode'

# Generates mock shipping labels for return requests
# Creates a PDF with tracking info, QR code, and addresses
class ShippingLabelGenerator
  CARRIERS = ['MockCarrier Express', 'ReturnShip Pro', 'QuickReturn Logistics'].freeze

  def initialize(return_request)
    @return_request = return_request
    @order = return_request.order
    @merchant = return_request.merchant
  end

  def generate
    tracking_number = generate_tracking_number
    carrier = CARRIERS.sample
    pdf_path = generate_pdf(tracking_number, carrier)

    {
      tracking_number: tracking_number,
      carrier: carrier,
      label_path: pdf_path,
      label_url: "/labels/#{File.basename(pdf_path)}"
    }
  end

  private

  def generate_tracking_number
    prefix = @merchant.name.gsub(/\s+/, '').upcase[0..2]
    timestamp = Time.current.strftime('%Y%m%d%H%M')
    random = SecureRandom.hex(4).upcase
    "#{prefix}-#{timestamp}-#{random}"
  end

  def generate_pdf(tracking_number, carrier)
    labels_dir = Rails.root.join('public', 'labels')
    FileUtils.mkdir_p(labels_dir)
    
    filename = "label_#{@return_request.id}_#{Time.current.to_i}.pdf"
    filepath = labels_dir.join(filename)

    Prawn::Document.generate(filepath, page_size: [288, 432]) do |pdf|
      draw_header(pdf, carrier)
      draw_barcode_section(pdf, tracking_number)
      draw_addresses(pdf)
      draw_return_info(pdf)
      draw_footer(pdf, tracking_number)
    end

    filepath.to_s
  end

  def draw_header(pdf, carrier)
    pdf.font_size(16) do
      pdf.text carrier, style: :bold, align: :center
    end
    pdf.move_down 5
    pdf.font_size(10) do
      pdf.text 'RETURN SHIPPING LABEL', align: :center
    end
    pdf.stroke_horizontal_rule
    pdf.move_down 10
  end

  def draw_barcode_section(pdf, tracking_number)
    # Generate QR code
    qr = RQRCode::QRCode.new(tracking_number)
    qr_png = qr.as_png(size: 100, border_modules: 0)
    
    # Save QR temporarily and embed
    qr_path = Rails.root.join('tmp', "qr_#{@return_request.id}.png")
    File.binwrite(qr_path, qr_png.to_s)
    
    pdf.image qr_path, position: :center, width: 80
    File.delete(qr_path) if File.exist?(qr_path)
    
    pdf.move_down 5
    pdf.font_size(12) do
      pdf.text tracking_number, style: :bold, align: :center
    end
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 10
  end

  def draw_addresses(pdf)
    # Ship TO (Merchant)
    pdf.font_size(8) do
      pdf.text 'SHIP TO:', style: :bold
    end
    pdf.font_size(10) do
      pdf.text @merchant.name, style: :bold
      pdf.text @merchant.contact_person if @merchant.contact_person.present?
      pdf.text @merchant.address.to_s
    end
    
    pdf.move_down 10
    
    # Ship FROM (Customer)
    pdf.font_size(8) do
      pdf.text 'FROM:', style: :bold
    end
    pdf.font_size(10) do
      pdf.text @order.customer_name
      pdf.text @order.customer_email
    end
    
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 10
  end

  def draw_return_info(pdf)
    pdf.font_size(8) do
      pdf.text 'RETURN DETAILS:', style: :bold
    end
    pdf.font_size(9) do
      pdf.text "Order: #{@order.order_number}"
      pdf.text "Request ID: #{@return_request.id}"
      pdf.text "Reason: #{@return_request.reason.to_s.truncate(40)}"
    end
    pdf.move_down 10
  end

  def draw_footer(pdf, tracking_number)
    pdf.stroke_horizontal_rule
    pdf.move_down 5
    pdf.font_size(7) do
      pdf.text 'Affix this label to your package', align: :center
      pdf.text 'Drop off at any carrier location', align: :center
      pdf.move_down 5
      pdf.text "Generated: #{Time.current.strftime('%Y-%m-%d %H:%M')}", align: :center
    end
  end
end
