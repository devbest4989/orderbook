class AddCustomerIdToInvoiceExtraItems < ActiveRecord::Migration
  def change
  	add_column :invoice_extra_items, :customer_id, :integer, default: 0
  end
end
