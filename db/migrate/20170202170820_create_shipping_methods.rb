class CreateShippingMethods < ActiveRecord::Migration
  def change
    create_table :shipping_methods do |t|
      t.string :name

      t.timestamps null: false
    end

    change_table :sales_orders do |t|
      t.integer  :shipping_method_id
      t.integer  :contact_id
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
      t.string   :price_name
    end   
  end
end
