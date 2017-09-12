class CreatePurchaseItemActivities < ActiveRecord::Migration
  def change
    create_table :purchase_item_activities do |t|
      t.integer  :quantity
      t.string   :activity
      t.text     :note
      t.string   :activity_data
      t.string   :token
      t.integer  :purchase_order_id
      t.decimal  :sub_total,      precision: 8, scale: 2, default: 0.0
      t.decimal  :total,          precision: 8, scale: 2, default: 0.0
      t.decimal  :discount,       precision: 8, scale: 2, default: 0.0
      t.decimal  :tax,            precision: 8, scale: 2, default: 0.0
      t.string   :track_number

      t.references :purchase_item, index: true, foreign_key: true
      t.integer :updated_by, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
