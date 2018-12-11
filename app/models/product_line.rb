class ProductLine < ActiveRecord::Base
	has_many :products

	validates :name, presence: true, uniqueness: true

	def product_count
		self.products.count
	end
end
