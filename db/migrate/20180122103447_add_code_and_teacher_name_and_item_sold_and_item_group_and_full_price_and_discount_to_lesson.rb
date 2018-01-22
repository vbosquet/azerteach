class AddCodeAndTeacherNameAndItemSoldAndItemGroupAndFullPriceAndDiscountToLesson < ActiveRecord::Migration[5.1]
  def change
    add_column :lessons, :code, :string
    add_column :lessons, :teacher_name, :string
    add_column :lessons, :item_sold, :string
    add_column :lessons, :item_group, :string
    add_column :lessons, :full_price, :float
    add_column :lessons, :discount, :float
  end
end
