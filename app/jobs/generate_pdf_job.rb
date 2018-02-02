class GeneratePdfJob < ApplicationJob
  queue_as :default

  def perform(invoice)

    av = ActionView::Base.new()
    av.view_paths = ActionController::Base.view_paths

    av.class_eval do
      include Rails.application.routes.url_helpers
      include ApplicationHelper
    end

    pdf_html = av.render template: 'admin/invoices/invoice.pdf.erb', locals: {invoice: invoice}
    doc_pdf = WickedPdf.new.pdf_from_string(
      pdf_html,
      page_size: 'Letter',
      javascript_delay: 6000
    )
    pdf_path = Rails.root.join('public', "#{invoice.numero}.pdf")
    File.open(pdf_path, 'wb') do |file|
      file << doc_pdf
    end
    invoice.pdf = File.open pdf_path
    invoice.status = 1
    invoice.save!
    File.delete(pdf_path) if File.exist?(pdf_path)
  end
end
