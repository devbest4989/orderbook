class CreateUnitMeasures < ActiveRecord::Migration
  def change
    create_table :unit_measures do |t|
      t.string :name
      t.integer :ratio
      t.integer :unit_category_id

      t.timestamps null: false
    end
  end
end
