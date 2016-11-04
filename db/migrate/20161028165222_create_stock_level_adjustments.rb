class CreateStockLevelAdjustments < ActiveRecord::Migration
  def change
    create_table :stock_level_adjustments do |t|
      t.string :description
      t.integer :adjustment
      t.references :item, index: true
      t.references :parent, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
