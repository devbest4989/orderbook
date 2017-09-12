class InvoiceItem < ActiveRecord::Base
	belongs_to :sales_item, class_name: 'SalesItem'
	belongs_to :sales_custom_item, class_name: 'SalesCustomItem'
	belongs_to :purchase_item, class_name: 'PurchaseItem'
	belongs_to :purchase_custom_item, class_name: 'PurchaseCustomItem'
end
