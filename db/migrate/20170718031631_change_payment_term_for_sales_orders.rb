class ChangePaymentTermForSalesOrders < ActiveRecord::Migration
  def change
  	rename_column :sales_orders, :payment_term, :payment_term_id
  	rename_column :customers, :payment_term, :payment_term_id
  	rename_column :suppliers, :payment_term, :payment_term_id
  end
end
