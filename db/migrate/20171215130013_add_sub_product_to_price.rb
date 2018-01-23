class AddSubProductToPrice < ActiveRecord::Migration
  def change
    add_column :prices, :sub_product_id, :integer
  end
end
