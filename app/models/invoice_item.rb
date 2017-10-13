class InvoiceItem < ActiveRecord::Base
	belongs_to :sales_item, class_name: 'SalesItem'
	belongs_to :sales_custom_item, class_name: 'SalesCustomItem'

	def available_quantity
		self.quantity - self.total_extra_quantity
	end

	def total_extra_quantity
		InvoiceExtraItem.where(sales_item_id: self.sales_item_id).sum(:quantity)
	end
end
