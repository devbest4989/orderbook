class Product < ActiveRecord::Base
  belongs_to :category
  belongs_to :brand
  belongs_to :product_line

  has_many :sales_items, dependent: :restrict_with_exception, as: :sold_item
  has_many :sales_orders, through: :sales_items, class_name: 'SalesOrder'

  # Stock level adjustments for this product
  has_many :stock_level_adjustments, dependent: :destroy, class_name: 'StockLevelAdjustment', as: :item

  scope :name_like, ->(search) { where("name LIKE :search", :search => "%#{search}%") }
  scope :sku_like, ->(search) { where("sku LIKE :search", :search => "%#{search}%") }
  scope :by_category, ->(search) { where("(category_id = :search) OR (:search = 0)", :search => "#{search}") }
  scope :by_brands, ->(search) { where("(brand_id = :search) OR (:search = 0)", :search => "#{search}") }
  scope :by_line, ->(search) { where("(product_line_id = :search) OR (:search = 0)", :search => "#{search}") }
  scope :ordered, -> { order(:name) }

  def in_stock?
    stock > 0
  end

  def stock
    stock_level_adjustments.sum(:adjustment)
  end

end
