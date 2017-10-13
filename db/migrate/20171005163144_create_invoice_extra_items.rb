class CreateInvoiceExtraItems < ActiveRecord::Migration
  def change
    create_table :invoice_extra_items do |t|
      t.integer :invoice_id
      t.integer :sales_item_id
      t.integer :quantity
      t.decimal :sub_total, precision: 8, scale: 2, default: 0.0 
      t.decimal :total, precision: 8, scale: 2, default: 0.0 
      t.decimal :discount, precision: 8, scale: 2, default: 0.0 
      t.decimal :tax, precision: 8, scale: 2, default: 0.0 
      t.integer :extra_type
      t.string  :note

      t.timestamps null: false
    end
  end
end
