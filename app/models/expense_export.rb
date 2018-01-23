class ExpenseExport < ApplicationRecord
	has_many :lessons
	belongs_to :teacher

	has_attached_file :pdf
	validates_attachment_content_type :pdf, content_type: "application/pdf"

	def generate_pdf
		av = ActionView::Base.new()
		av.view_paths = ActionController::Base.view_paths

		av.class_eval do
			include Rails.application.routes.url_helpers
			include ApplicationHelper
		end

		pdf_html = av.render template: 'admin/expense_exports/expense_export.pdf.erb', locals: {expense_export: self}
		doc_pdf = WickedPdf.new.pdf_from_string(
			pdf_html,
			page_size: 'Letter',
			javascript_delay: 6000
			)
		pdf_path = Rails.root.join('public', "#{self.numero}.pdf")
		File.open(pdf_path, 'wb') do |file|
			file << doc_pdf
		end
		self.pdf = File.open pdf_path
		self.save!
		File.delete(pdf_path) if File.exist?(pdf_path)
	end
end
