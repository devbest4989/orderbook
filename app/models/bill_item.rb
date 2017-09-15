class BillItem < ActiveRecord::Base
	belongs_to :purchase_item, class_name: 'PurchaseItem'
	belongs_to :purchase_custom_item, class_name: 'PurchaseCustomItem'
end
