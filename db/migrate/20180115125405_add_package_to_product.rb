class AddPackageToProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :package, :boolean, default: false
  end
end
