namespace :reminders do

	task :send_to_admin => :environment do
		unpaid_lessons = Lesson.all.where("invoice_status != ?", 1).order('invoice_date ASC').select {|l| l.invoice.present? && l.invoice.sending_date.present? && TimeDifference.between(l.invoice.sending_date, Date.today).in_days > 15}
		if unpaid_lessons.present?
			InvoiceMailer.send_reminder_to_admin(unpaid_lessons).deliver
		end
	end

end
