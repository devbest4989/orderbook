class Price < ActiveRecord::Base
	belongs_to :product

	validates :product_id, uniqueness: {scope: :name}
end
