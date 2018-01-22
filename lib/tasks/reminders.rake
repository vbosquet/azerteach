namespace :reminders do

	task :send_to_admin => :environment do
		unpaids_with_invoice = Lesson.joins(:invoice).where("lessons.invoice_status != ? and lessons.invoice_id IS NOT NULL and invoices.sending_date <= ?", 1, Date.today - 14.days)
		unpaids_with_no_invoices = Lesson.joins(:invoice).where("lessons.invoice_status != ? and lessons.invoice_id IS NULL and lessons.invoice_date <= ?", 1, Date.today - 14.days)
		if unpaids_with_invoice.present? || unpaids_with_no_invoices.present?
			User.all.each do |user|
				InvoiceMailer.send_reminder_to_admin(user, unpaids_with_invoice, unpaids_with_no_invoices).deliver
			end
		end
	end

end