class InvoiceItem < ActiveRecord::Base
	belongs_to :sales_item, class_name: 'SalesItem'
	belongs_to :sales_custom_item, class_name: 'SalesCustomItem'
end
