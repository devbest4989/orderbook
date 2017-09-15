class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.string :token
      t.integer :purchase_order_id
      t.decimal :sub_total, precision: 8, scale: 2, default: 0.0 
      t.decimal :discount, precision: 8, scale: 2, default: 0.0 
      t.decimal :tax, precision: 8, scale: 2, default: 0.0 
      t.decimal :total, precision: 8, scale: 2, default: 0.0 
      t.decimal :paid, precision: 8, scale: 2, default: 0.0 
      t.integer :status
      t.string :file_name
      t.string :preview_token

      t.timestamps null: false
    end
  end
end
