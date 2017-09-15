class CreateBillItems < ActiveRecord::Migration
  def change
    create_table :bill_items do |t|
      t.integer :bill_id
      t.integer :purchase_item_id
      t.integer :quantity
      t.decimal :sub_total, precision: 8, scale: 2, default: 0.0 
      t.decimal :total, precision: 8, scale: 2, default: 0.0 
      t.decimal :discount, precision: 8, scale: 2, default: 0.0 
      t.decimal :tax, precision: 8, scale: 2, default: 0.0 
      t.integer :purchase_custom_item_id

      t.timestamps null: false
    end
  end
end
