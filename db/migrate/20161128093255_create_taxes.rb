class CreateTaxes < ActiveRecord::Migration
  def change
    create_table :taxes do |t|
      t.decimal :rate, precision: 3, scale: 2
      t.string :description

      t.timestamps null: false
    end
  end
end
