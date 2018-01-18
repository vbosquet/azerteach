class InvoiceMailer < ApplicationMailer
	def send_invoice(invoice)
		@invoice = invoice
		attachments["#{@invoice.numero}.pdf"] = {
			mime_type: 'application/pdf',
			content: open(@invoice.pdf.path).read
		}
		mail(:to => @invoice.student.email, :subject => "Azerteach - nouvelle facture")
	end
end
