class CreateSalesItemActivities < ActiveRecord::Migration
  def change
    create_table :sales_item_activities do |t|
      t.integer :quantity
      t.string :activity
      t.text :note
      t.references :sales_item, index: true, foreign_key: true
      t.integer :updated_by, index: true, foreign_key: true
      
      t.timestamps null: false
    end
  end
end
