class AddFirstReminderDateToInvoice < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :first_reminder_date, :date
  end
end
