class AddSalesCustomItemIdToInvoiceItems < ActiveRecord::Migration
  def change
    add_column :invoice_items, :sales_custom_item_id, :integer
  end
end
