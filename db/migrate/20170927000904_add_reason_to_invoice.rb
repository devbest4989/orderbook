class AddReasonToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :reason, :string
    add_column :sales_orders, :reason, :string
    add_column :purchase_orders, :reason, :string
  end
end
