class AddParentInfosToStudent < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :parent_lastname, :string
    add_column :students, :parent_firstname, :string
    add_column :students, :parent_email, :string
  end
end
