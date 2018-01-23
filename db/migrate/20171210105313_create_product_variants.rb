class CreateProductVariants < ActiveRecord::Migration
  def change
    create_table :product_variants do |t|
      t.string :name
      t.text :value
      t.integer :order_num

      t.references :product, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
