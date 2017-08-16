class CreateConditionTerms < ActiveRecord::Migration
  def change
    create_table :condition_terms do |t|
      t.string :title
      t.string :description

      t.timestamps null: false
    end
  end
end
