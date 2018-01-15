class CreateStudents < ActiveRecord::Migration[5.1]
  def change
    create_table :students do |t|
      t.string :firstname
      t.string :lastname
      t.date :birthdate
      t.string :phone_number
      t.string :email
      t.string :street
      t.integer :street_number
      t.integer :box
      t.integer :zipcode
      t.string :city

      t.timestamps
    end
  end
end
