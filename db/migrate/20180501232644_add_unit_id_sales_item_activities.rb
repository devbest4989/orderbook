class AddUnitIdSalesItemActivities < ActiveRecord::Migration
  def change
    add_column :sales_item_activities, :unit_id, :integer
    add_column :sales_item_activities, :unit_name, :string
    add_column :sales_item_activities, :unit_ratio, :integer
  end
end
