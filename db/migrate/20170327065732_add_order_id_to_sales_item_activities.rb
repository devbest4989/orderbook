class AddOrderIdToSalesItemActivities < ActiveRecord::Migration
  def change
  	add_column :sales_item_activities, :sales_order_id, :integer
  	add_column :sales_item_activities, :sub_total, :decimal, :precision => 8, :scale => 2, default: 0 
  	add_column :sales_item_activities, :total, :decimal, :precision => 8, :scale => 2, default: 0 
  	add_column :sales_item_activities, :discount, :decimal, :precision => 8, :scale => 2, default: 0 
  	add_column :sales_item_activities, :tax, :decimal, :precision => 8, :scale => 2, default: 0 
  end
end
