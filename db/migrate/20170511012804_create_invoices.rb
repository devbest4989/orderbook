class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :token
      t.integer :sales_order_id
      t.decimal :sub_total,      precision: 8, scale: 2, default: 0.0
      t.decimal :discount,       precision: 8, scale: 2, default: 0.0
      t.decimal :tax,            precision: 8, scale: 2, default: 0.0
      t.decimal :shipping,       precision: 8, scale: 2, default: 0.0
      t.decimal :total,          precision: 8, scale: 2, default: 0.0
      t.decimal :paid,           precision: 8, scale: 2, default: 0.0
      t.integer :status, default: 0

      t.timestamps null: false
    end
  end
end
