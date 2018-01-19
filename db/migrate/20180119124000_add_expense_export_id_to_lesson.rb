class AddExpenseExportIdToLesson < ActiveRecord::Migration[5.1]
  def change
    add_column :lessons, :expense_export_id, :integer
  end
end
