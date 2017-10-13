class InvoiceExtraItem < ActiveRecord::Base
	belongs_to :sales_item, class_name: 'SalesItem'
	enum extra_type: [:write_off, :credit_note]
end
