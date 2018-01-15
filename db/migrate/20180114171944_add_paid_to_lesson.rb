class AddPaidToLesson < ActiveRecord::Migration[5.1]
  def change
    add_column :lessons, :paid, :boolean, default: false
  end
end
