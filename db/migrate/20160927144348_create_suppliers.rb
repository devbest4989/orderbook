class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :first_name
      t.string :last_name
      t.string :company_name
      t.string :trading_name
      t.string :company_reg_no
      t.string :company_gst_no
      t.string :phone
      t.string :fax
      t.string :email
      t.string :bill_street
      t.string :bill_suburb
      t.string :bill_city
      t.string :bill_state
      t.string :bill_postcode
      t.string :bill_country
      t.string :ship_street
      t.string :ship_suburb
      t.string :ship_city
      t.string :ship_state
      t.string :ship_postcode
      t.string :ship_country
      t.integer :payment_term
      t.string :bank_name
      t.string :bank_account_name
      t.string :bank_number

      t.timestamps null: false
    end
  end
end
