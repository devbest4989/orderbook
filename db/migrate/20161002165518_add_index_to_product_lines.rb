class AddIndexToProductLines < ActiveRecord::Migration
  def change
    add_index :product_lines, :name, unique: true
  end
end
