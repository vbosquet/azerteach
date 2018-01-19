class AddTeacherIdToExpenseExport < ActiveRecord::Migration[5.1]
  def change
    add_column :expense_exports, :teacher_id, :integer
  end
end
