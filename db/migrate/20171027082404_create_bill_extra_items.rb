class CreateBillExtraItems < ActiveRecord::Migration
  def change
    create_table :bill_extra_items do |t|
      t.integer :bill_id
      t.integer :purchase_item_id
      t.integer :quantify
      t.decimal :sub_total,         precision: 8, scale: 2, default: 0.0
      t.decimal :total,             precision: 8, scale: 2, default: 0.0
      t.decimal :discount,          precision: 8, scale: 2, default: 0.0
      t.decimal :tax,               precision: 8, scale: 2, default: 0.0
      t.string  :note
      t.integer :is_paid,                                   default: 0
      t.integer :supplier_id,                               default: 0

      t.timestamps null: false
    end
  end
end
