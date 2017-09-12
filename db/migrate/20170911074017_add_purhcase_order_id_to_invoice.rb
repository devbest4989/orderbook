class AddPurhcaseOrderIdToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :purchase_order_id, :integer
  end
end
