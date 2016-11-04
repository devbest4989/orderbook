class ChangeColumnNameForSalesOrder < ActiveRecord::Migration
  def change
  	rename_column :sales_orders, :order_at, :order_date
  	rename_column :sales_orders, :req_ship_at, :req_ship_date
  end
end
