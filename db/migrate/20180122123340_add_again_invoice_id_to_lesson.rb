class AddAgainInvoiceIdToLesson < ActiveRecord::Migration[5.1]
  def change
    add_column :lessons, :invoice_id, :integer
  end
end
