class InvoiceExtraItem < ActiveRecord::Base
	belongs_to :sales_item, class_name: 'SalesItem'
	belongs_to :invoice, class_name: 'Invoice'
	belongs_to :paid_invoice, class_name: 'Invoice'
	enum extra_type: [:write_off, :credit_note]
end
