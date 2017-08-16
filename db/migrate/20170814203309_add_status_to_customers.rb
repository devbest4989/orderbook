class AddStatusToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :status, :integer, default: 0
    add_column :suppliers, :status, :integer, default: 0
  end
end
