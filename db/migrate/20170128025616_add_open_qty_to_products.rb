class AddOpenQtyToProducts < ActiveRecord::Migration
  def change
    add_column :products, :open_qty, :integer
  end
end
