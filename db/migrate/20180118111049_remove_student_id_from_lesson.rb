class RemoveStudentIdFromLesson < ActiveRecord::Migration[5.1]
  def change
    remove_column :lessons, :student_id, :integer
  end
end
