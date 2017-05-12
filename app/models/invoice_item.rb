class InvoiceItem < ActiveRecord::Base
	belongs_to :sales_item, class_name: 'SalesItem'
end
