class AddTaxToProducts < ActiveRecord::Migration
  def change
  	change_table :products do |t|
  		t.references :selling_tax
  		t.references :purchase_tax
  	end
    add_column :products, :selling_price_ex, :decimal, :precision => 8, :scale => 2 
    add_column :products, :purchase_price_ex, :decimal, :precision => 8, :scale => 2    
    add_column :products, :selling_price_type, :boolean
    add_column :products, :purchase_price_type, :boolean
    rename_column :products, :perchase_price, :purchase_price
  end
end
