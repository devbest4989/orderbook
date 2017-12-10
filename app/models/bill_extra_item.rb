class BillExtraItem < ActiveRecord::Base
	belongs_to :purchase_item, class_name: 'PurchaseItem'
	belongs_to :bill, class_name: 'Bill'
	belongs_to :supplier
end
