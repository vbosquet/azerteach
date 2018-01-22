class AddMobileToStudent < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :mobile, :string
  end
end
