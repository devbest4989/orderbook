class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.string :token
      t.string :status
      t.date :order_date
      t.date :issue_date
      t.date :booked_at
      t.date :cancelled_at
      t.text :notes
      t.decimal  :total_amount, precision: 8, scale: 2
      t.string   :invoice_number
      t.integer  :payment_term_id
      t.integer  :warehouse_id
      t.string   :bill_street
      t.string   :bill_suburb
      t.string   :bill_city
      t.string   :bill_state
      t.string   :bill_postcode
      t.string   :bill_country
      t.string   :ship_street
      t.string   :ship_suburb
      t.string   :ship_city
      t.string   :ship_state
      t.string   :ship_postcode
      t.string   :ship_country
      t.string   :ref_no
      t.integer  :condition_term_id

      t.timestamps null: false

      t.references :supplier, index: true, foreign_key: true
      t.references :booked_by
      t.references :cancelled_by

    end
  end
end
