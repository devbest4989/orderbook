class CreateSalesItems < ActiveRecord::Migration
  def change
    create_table :sales_items do |t|
      t.integer :quantity
      t.decimal :unit_price,       precision: 8, scale: 2
      t.decimal :unit_cost_price,  precision: 8, scale: 2
      t.decimal :tax_amount,       precision: 8, scale: 2
      t.decimal :tax_rate,         precision: 8, scale: 2

      t.references :sales_order, index: true, foreign_key: true
      t.references :sold_item, inidex: true

      t.timestamps null: false
    end
  end
end
