class AddDiscountToSalesItem < ActiveRecord::Migration
  def change
    add_column :sales_items, :discount_rate, :decimal, precision: 8, scale: 2
  end
end
