class AddCodeToStudent < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :code, :string
  end
end
