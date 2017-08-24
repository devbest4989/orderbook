class CreateSalesCustomItems < ActiveRecord::Migration
  def change
    create_table :sales_custom_items do |t|
      t.decimal :quantity,         precision: 8, scale: 2
      t.decimal :unit_price,       precision: 8, scale: 2
      t.decimal :tax_amount,       precision: 8, scale: 2
      t.decimal :tax_rate,         precision: 8, scale: 2
      t.integer :sales_order_id
      t.string  :item_name
      t.decimal :discount_rate,    precision: 8, scale: 2
      t.decimal :discount_amount,  precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
