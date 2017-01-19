class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :product_id
      t.string :name
      t.integer :price_type
      t.decimal :value, :precision => 8, :scale => 2 
      t.integer :cond

      t.timestamps null: false
    end
  end
end
