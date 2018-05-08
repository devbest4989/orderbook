class AddUnitIdPurchaseItems < ActiveRecord::Migration
  def change
    add_column :purchase_items, :unit_id, :integer
    add_column :purchase_items, :unit_name, :string
    add_column :purchase_items, :unit_ratio, :integer
    add_column :purchase_items, :unit_one_price, :decimal, precision: 8, scale: 2, default: 0.0 
  end
end
