class CreateSubProducts < ActiveRecord::Migration
  def change
    create_table :sub_products do |t|
      t.string :option1, default: ''
      t.string :value1, default: ''
      t.string :option2, default: ''
      t.string :value2, default: ''
      t.string :option3, default: ''
      t.string :value3, default: ''

      t.string :sku
      t.integer :quantity
      t.string :barcode
      t.integer :open_qty
      t.integer :reorder_qty
      t.integer :stock_status
      t.integer :warehouse_id

      t.boolean  :status, default: true
      t.boolean  :removed, default: false
      t.decimal  :purchase_price,    precision: 8, scale: 2
      t.decimal  :selling_price,   precision: 8, scale: 2
      t.integer  :selling_tax_id
      t.integer  :purchase_tax_id
      t.decimal  :selling_price_ex,    precision: 8, scale: 2
      t.decimal  :purchase_price_ex,   precision: 8, scale: 2
      t.boolean  :selling_price_type
      t.boolean  :purchase_price_type

      t.attachment :image

      t.references :product, index: true, foreign_key: true
      
      t.timestamps null: false
    end
  end
end
