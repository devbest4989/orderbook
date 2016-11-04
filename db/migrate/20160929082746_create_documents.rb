class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.references :customer, index: true, foreign_key: true
      t.references :supplier, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
