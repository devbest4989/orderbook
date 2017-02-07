class AddContactToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :contact_name, :string
    add_column :sales_orders, :contact_email, :string
    add_column :sales_orders, :contact_phone, :string
    add_column :sales_orders, :ref_no, :string
    remove_column :sales_orders, :contact_id
  end
end
