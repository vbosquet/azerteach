class CreateInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :invoices do |t|
      t.string :numero
      t.integer :vat
      t.float :amount, default: 0.0
      t.boolean :payment_status, default: false
      t.date :payment_date
      t.date :sending_date
      t.integer :student_id

      t.timestamps
    end
  end
end
