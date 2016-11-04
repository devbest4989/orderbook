class CreateGlobalMaps < ActiveRecord::Migration
  def change
    create_table :global_maps do |t|
      t.string :key
      t.string :value

      t.timestamps null: false
    end
  end
end
