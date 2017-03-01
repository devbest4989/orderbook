class AddActivityDataToSalesItemActivities < ActiveRecord::Migration
  def change
    add_column :sales_item_activities, :activity_data, :string
    add_column :sales_item_activities, :token, :string
  end
end
