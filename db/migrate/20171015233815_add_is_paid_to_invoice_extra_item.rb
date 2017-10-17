class AddIsPaidToInvoiceExtraItem < ActiveRecord::Migration
  def change
    add_column :invoice_extra_items, :is_paid, :integer, default: 0
    add_column :invoice_extra_items, :paid_invoice_id, :integer, default: 0
    add_column :invoice_extra_items, :paid_invoice_type, :string
  end
end
