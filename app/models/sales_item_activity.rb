class SalesItemActivity < ActiveRecord::Base
	ACTIVITIES = %w(book ship return cancel delete).freeze

    belongs_to :sales_item, class_name: 'SalesItem'
    belongs_to :updated_by, class_name: 'User', foreign_key: 'updated_by'
end
