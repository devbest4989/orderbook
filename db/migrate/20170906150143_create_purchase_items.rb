class CreatePurchaseItems < ActiveRecord::Migration
  def change
    create_table :purchase_items do |t|
      t.integer :quantity
      t.decimal :unit_price,      precision: 8, scale: 2
      t.decimal :tax_amount,      precision: 8, scale: 2
      t.decimal :tax_rate,        precision: 8, scale: 2
      t.decimal :discount_rate,   precision: 8, scale: 2
      t.decimal :discount_amount, precision: 8, scale: 2

      t.references :purchase_order, index: true, foreign_key: true
      t.references :purchased_item, inidex: true

      t.timestamps null: false
    end
  end
end
