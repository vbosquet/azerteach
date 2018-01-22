class InvoiceMailer < ApplicationMailer
	def send_invoice(invoice)
		@invoice = invoice
		attachments["#{@invoice.numero}.pdf"] = {
			mime_type: 'application/pdf',
			content: open(@invoice.pdf.path).read
		}
		mail(:to => 'vivi_sander@hotmail.com', :subject => "Azerteach - nouvelle facture")
	end

	def send_reminder_to_admin(admin, unpaids_with_invoice, unpaids_with_no_invoices)
		@unpaids_with_invoice = unpaids_with_invoices
		@unpaids_with_no_invoices = unpaids_with_no_invoices
		@admin = admin
		mail(to: admin.email, subject: 'Azerteach - gestion des impayés')
	end
end
