class AddActivityToSalesItems < ActiveRecord::Migration
  def change
    add_column :sales_items, :discount_amount, :decimal, precision: 8, scale: 2 
  	rename_column :sales_orders, :rejected_at, :cancelled_at
  	rename_column :sales_orders, :rejected_by_id, :cancelled_by_id
  	rename_column :sales_orders, :amount_paid, :total_amount
  end
end
