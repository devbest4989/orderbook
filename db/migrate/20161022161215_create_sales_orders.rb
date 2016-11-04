class CreateSalesOrders < ActiveRecord::Migration
  def change
    create_table :sales_orders do |t|
      t.string :token
      t.string :status
      t.date :order_at
      t.date :shipped_at
      t.date :booked_at
      t.date :rejected_at
      t.text :notes
      t.decimal :amount_paid,       precision: 8, scale: 2
      t.string :invoice_number

      t.references :customer, index: true, foreign_key: true
      t.references :rejected_by
      t.references :booked_by

      t.timestamps null: false
    end
  end
end
