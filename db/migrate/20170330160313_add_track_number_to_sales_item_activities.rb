class AddTrackNumberToSalesItemActivities < ActiveRecord::Migration
  def change
    add_column :sales_item_activities, :track_number, :string
  end
end
