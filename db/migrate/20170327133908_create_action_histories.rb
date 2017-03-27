class CreateActionHistories < ActiveRecord::Migration
  def change
    create_table :action_histories do |t|
      t.string :item_type
      t.integer :item_id
      t.string :action_name
      t.string :action_type
      t.string :action_number
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
