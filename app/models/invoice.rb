class Invoice < ApplicationRecord
  belongs_to :student
  has_many :line_items
  has_many :lessons, through: :line_items

  has_attached_file :pdf
  validates_attachment_content_type :pdf, content_type: "application/pdf"

  def set_payment_date
  	self.payment_date = Date.today
    self.save
    self.line_items.each do |item|
    	item.paid = true
    	item.save
    end
  end

  def generate_pdf
    av = ActionView::Base.new()
    av.view_paths = ActionController::Base.view_paths

    av.class_eval do
      include Rails.application.routes.url_helpers
      include ApplicationHelper
    end

    pdf_html = av.render template: 'admin/invoices/invoice.pdf.erb', locals: {invoice: self}
    doc_pdf = WickedPdf.new.pdf_from_string(
      pdf_html,
      page_size: 'Letter',
      javascript_delay: 6000
      )
    pdf_path = Rails.root.join('public/exports', "#{self.numero}.pdf")
    File.open(pdf_path, 'wb') do |file|
      file << doc_pdf
    end
    self.pdf = File.open pdf_path
    self.save!
    File.delete(pdf_path) if File.exist?(pdf_path)
  end

  def update_line_items(new_lesson_ids)
    lesson_ids = self.lessons.map(&:id)
    if lesson_ids.size > new_lesson_ids.size # remove line_items from invoice
      items = self.line_items.where('lesson_id NOT IN(?)', new_lesson_ids)
      items.each do |item|
        item.invoice_id = nil 
        item.save
      end
    elsif lesson_ids.size < new_lesson_ids.size # add line_items to invoive
      items = LineItem.where("lesson_id IN(?) and student_id = ?", new_lesson_ids, self.student_id)
      Rails.logger.debug("ITEMS: #{items.inspect}")
      items.each do |item|
        item.invoice_id = self.id 
        item.save
      end
    end
  end

end
