class SalesItemActivity < ActiveRecord::Base
	ACTIVITIES = %w(pack ship).freeze

    belongs_to :sales_item, class_name: 'SalesItem'
    belongs_to :updated_by, class_name: 'User', foreign_key: 'updated_by'
end
