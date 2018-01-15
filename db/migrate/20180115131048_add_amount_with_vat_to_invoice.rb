class AddAmountWithVatToInvoice < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :amount_with_vat, :float, default: 0.0
  end
end
