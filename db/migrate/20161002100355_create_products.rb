class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :sku
      t.string :name
      t.string :description
      t.decimal :perchase_price, precision: 8, scale: 2
      t.decimal :selling_price, precision: 8, scale: 2
      t.integer	:quantity
      t.references :category, index: true, foreign_key: true
      t.references :product_line, index: true, foreign_key: true
      t.references :brand, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
