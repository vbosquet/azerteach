class AddInvoiceNUmberAndInvoiceNumberAndInvoiceStatusToLesson < ActiveRecord::Migration[5.1]
  def change
    add_column :lessons, :invoice_date, :date
    add_column :lessons, :invoice_number, :string
    add_column :lessons, :invoice_status, :integer
  end
end
