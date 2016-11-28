class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :key
      t.string :value
      t.integer :conf_type
      t.string :description

      t.timestamps null: false
    end
  end
end
