class CreateExpenseExports < ActiveRecord::Migration[5.1]
  def change
    create_table :expense_exports do |t|
      t.string :numero
      t.float :amount
      t.datetime :sending_date

      t.timestamps
    end
  end
end
