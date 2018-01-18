class AddContactInfosToTeacher < ActiveRecord::Migration[5.1]
  def change
    add_column :teachers, :email, :string
    add_column :teachers, :phone_number, :string
    add_column :teachers, :street, :string
    add_column :teachers, :street_number, :integer
    add_column :teachers, :zipcode, :integer
    add_column :teachers, :city, :string
    add_column :teachers, :box, :integer
  end
end
