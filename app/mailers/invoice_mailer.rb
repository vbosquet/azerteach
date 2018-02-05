class InvoiceMailer < ApplicationMailer
	def send_invoice(invoice)
		@invoice = invoice
		attachments["#{@invoice.numero}.pdf"] = {
			mime_type: 'application/pdf',
			content: open(@invoice.pdf.url).read
		}
		#mail(:to => 'vivi_sander@hotmail.com', :subject => "Azerteach - nouvelle facture")
		mail(:to => 'paulgilsonchun@hotmail.com, vivi_sander@hotmail.com', :subject => "Facture Azerteach - test envoi automatique")
	end

	def send_reminder_to_admin(admin, unpaids_with_invoice, unpaids_with_no_invoices)
		@unpaids_with_invoice = unpaids_with_invoices
		@unpaids_with_no_invoices = unpaids_with_no_invoices
		@admin = admin
		mail(to: admin.email, subject: 'Azerteach - gestion des impayés')
	end

	def send_reminder_to_student(invoice)
		@invoice = invoice
		attachments["#{@invoice.numero}.pdf"] = {
			mime_type: 'application/pdf',
			content: open(@invoice.pdf.url).read
		}
		mail(:to => 'paulgilsonchun@hotmail.com, vivi_sander@hotmail.com', :subject => "Rappel Payement Facture Azerteach - test envoi automatique")
	end
end
