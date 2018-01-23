class SubProduct < ActiveRecord::Base
	belongs_to :product
	belongs_to :warehouse

	has_many :prices

	belongs_to :selling_tax, class_name: 'Tax'
	belongs_to :purchase_tax, class_name: 'Tax'

	has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/nothumb.png"
	validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

	# validates :barcode, presence: true, uniqueness: true

	accepts_nested_attributes_for :prices
	
	scope :main_like, ->(search) { joins(:product).where("(LOWER(products.name) LIKE :search) or (LOWER(sub_products.sku) LIKE :search)", :search => "%#{search.downcase}%") }

	scope :actived, -> { where(:status => true, :removed => false) }
	scope :inactived, -> { where(:status => false, :removed => false) }
	scope :removed, -> { where(:removed => true) }
	scope :lived, -> { where(:removed => false) }

	def main_selling_price
		(selling_price_type == false) ? selling_price : selling_price_ex
	end

	def main_purchase_price
		(purchase_price_type == false) ? purchase_price : purchase_price_ex
	end

	def in_stock?
		stock > 0
	end

	def stock
		quantity
		# open_qty - sales_qty + purchase_qty
	end

	def stock!
		#stock_level_adjustments.sum(:adjustment)
		self.quantity = open_qty - sales_qty + purchase_qty - return_qty + credit_note_qty
		if self.quantity.to_i > self.reorder_qty.to_i
		  self.stock_status = :instock
		else
		  self.stock_status = :lowstock
		end
		save!
		self.product.stock!
	end

	def sales_qty
		SalesItem.includes(:sales_order).where(sold_item: self.id).where("sales_orders.status NOT IN ('quote', 'cancelled')").sum(:quantity)
	end

	def purchase_qty
		PurchaseItemActivity.includes(:purchase_item).where(activity: 'receive').where("purchase_items.purchased_item_id = #{self.id}").sum(:quantity)
	end

	def return_qty
		PurchaseItemActivity.includes(:purchase_item).where(activity: 'return').where("purchase_items.purchased_item_id = #{self.id}").sum(:quantity)
	end

	def credit_note_qty
		InvoiceExtraItem.includes(:sales_item).where(extra_type: 1).where("sales_items.sold_item_id = #{self.id}").sum(:quantity)
	end

	def status_label
		(removed == true) ? 'Deleted' : ((status == true) ? 'Active' : 'Inactive')
	end

	def markup
		(main_selling_price.to_f - main_purchase_price.to_f) * 100 / main_purchase_price.to_f
	end

	def gross_profit
		(main_selling_price.to_f - main_purchase_price.to_f) * 100 / main_selling_price.to_f
	end

	def stock_status_text    
		if self.stock.to_i > self.reorder_qty.to_i
			"In-Stock"
		else
			"Low-Stock"
		end
	end

	def variant_name
		variant_slug = self.value1
		variant_slug += "-" + (self.value2) unless self.value2.blank?
		variant_slug += "-" + (self.value3) unless self.value3.blank?
		return variant_slug
	end

	def option_value pos
		if pos == 1
		  return self.value1
		elsif pos == 2
		  return self.value2
		else
		  return self.value3
		end
	end

	def name
		"#{self.product.name} #{self.variant_name}"
	end
	
end
