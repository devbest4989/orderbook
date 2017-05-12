class Invoice < ActiveRecord::Base
	has_many :invoice_items, class_name: 'InvoiceItem'

	belongs_to :sales_order, class_name: 'SalesOrder'
	
	enum status: [:draft, :paid]
end
