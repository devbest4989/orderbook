class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :invoice_id
      t.decimal :amount,      precision: 8, scale: 2, default: 0.0
      t.date :payment_date

      t.timestamps null: false
    end
  end
end
