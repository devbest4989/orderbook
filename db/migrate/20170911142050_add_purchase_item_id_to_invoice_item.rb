class AddPurchaseItemIdToInvoiceItem < ActiveRecord::Migration
  def change
    add_column :invoice_items, :purchase_item_id, :integer
    add_column :invoice_items, :purchase_custom_item_id, :integer
  end
end
