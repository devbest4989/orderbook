class AddReqShipDateToSalesOrder < ActiveRecord::Migration
  def change
    add_column :sales_orders, :req_ship_at, :date
    add_column :sales_orders, :estimate_ship_date, :date
    add_column :sales_orders, :payment_term, :integer
  end
end
