class AddReorderQtyToProduct < ActiveRecord::Migration
  def change
    add_column :products, :reorder_qty, :integer
    add_column :products, :stock_status, :integer
    add_column :products, :removed, :boolean, default: false
    add_column :products, :barcode, :string
  end
end
