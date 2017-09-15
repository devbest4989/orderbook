class CreateBillPayments < ActiveRecord::Migration
  def change
    create_table :bill_payments do |t|
      t.integer :bill_id
      t.decimal :amount, precision: 8, scale: 2, default: 0.0 
      t.date :payment_date
      t.integer :payment_mode
      t.string :reference_no
      t.string :note

      t.timestamps null: false
    end
  end
end
