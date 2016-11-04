class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone_number, :string
    add_column :users, :role, :integer, default: 0 # 0: Admin, 1: Sales, 2: Manager, 3: Support
  end
end
