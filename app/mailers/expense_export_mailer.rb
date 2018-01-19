class ExpenseExportMailer < ApplicationMailer
	def send_expense_export(expense_export)
		@expense_export = expense_export
		attachments["#{@expense_export.numero}.pdf"] = {
			mime_type: 'application/pdf',
			content: open(@expense_export.pdf.path).read
		}
		mail(:to => @expense_export.teacher.email, :subject => "Azerteach - nouvelle note de frais")
	end
end
