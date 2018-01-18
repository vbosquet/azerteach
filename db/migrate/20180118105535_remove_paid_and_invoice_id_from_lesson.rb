class RemovePaidAndInvoiceIdFromLesson < ActiveRecord::Migration[5.1]
  def change
    remove_column :lessons, :paid, :boolean
    remove_column :lessons, :invoice_id, :integer
  end
end
