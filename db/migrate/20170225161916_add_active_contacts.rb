class AddActiveContacts < ActiveRecord::Migration
  def change
    add_column :contacts,  :is_default, :integer
    add_column :customers, :default_price, :string
    add_column :prices, :tax_value, :decimal, :precision => 8, :scale => 2 
  end
end
