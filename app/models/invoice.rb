class Invoice < ActiveRecord::Base
	has_many :invoice_items, class_name: 'InvoiceItem'

	belongs_to :sales_order, class_name: 'SalesOrder'
	
	enum status: [:draft, :confirmed]

	def file_name_path
		'/invoices/' + file_name
	end

	def is_updated_pdf
		updated_at = self.updated_at.to_i.to_s + ".pdf"
		ori_filename = (self.file_name.blank?) ? "" : self.file_name
		pdf_updated_at = ori_filename[11..-1]
		return updated_at == pdf_updated_at
	end
end
