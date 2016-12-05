class AddNameToTaxes < ActiveRecord::Migration
  def change
    add_column :taxes, :name, :string
  end
end
