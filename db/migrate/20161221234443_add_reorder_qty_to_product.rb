class AddReorderQtyToProduct < ActiveRecord::Migration
  def change
    add_column :products, :reorder_qty, :integer
    add_column :products, :stock_status, :integer
  end
end
