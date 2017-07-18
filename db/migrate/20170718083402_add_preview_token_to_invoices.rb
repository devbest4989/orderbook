class AddPreviewTokenToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :preview_token, :string
  end
end
