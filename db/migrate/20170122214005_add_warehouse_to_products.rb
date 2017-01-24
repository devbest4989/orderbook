class AddWarehouseToProducts < ActiveRecord::Migration
  def change
    add_column :products, :warehouse_id, :integer
  end
end
