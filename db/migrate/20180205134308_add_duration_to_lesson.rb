class AddDurationToLesson < ActiveRecord::Migration[5.1]
  def change
    add_column :lessons, :duration, :integer
  end
end
