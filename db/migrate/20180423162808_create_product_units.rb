class CreateProductUnits < ActiveRecord::Migration
  def change
    create_table :product_units do |t|
      t.string :name
      t.integer :ratio
      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
