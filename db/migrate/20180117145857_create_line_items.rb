class CreateLineItems < ActiveRecord::Migration[5.1]
  def change
    create_table :line_items do |t|
      t.integer :lesson_id
      t.integer :student_id
      t.integer :invoice_id
      t.boolean :paid, default: false

      t.timestamps
    end
  end
end
