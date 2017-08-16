class AddConditionTermIdToSalesOrder < ActiveRecord::Migration
  def change
    add_column :sales_orders, :condition_term_id, :integer
  end
end
