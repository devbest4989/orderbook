class AddFileNameToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :file_name, :string
  end
end
