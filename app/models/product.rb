class Product < ActiveRecord::Base
  before_save :update_stock_status

  belongs_to :category
  belongs_to :brand
  belongs_to :product_line

  has_many :sales_items, dependent: :restrict_with_exception, as: :sold_item
  has_many :sales_orders, through: :sales_items, class_name: 'SalesOrder'

  belongs_to :selling_tax, class_name: 'Tax'
  belongs_to :purchase_tax, class_name: 'Tax'

  # Stock level adjustments for this product
  has_many :stock_level_adjustments, dependent: :destroy, class_name: 'StockLevelAdjustment', as: :item

  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/nothumb.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/


  scope :main_like, ->(search) { where("(products.name LIKE :search) or (products.sku LIKE :search)", :search => "%#{search}%") }
  scope :name_like, ->(search) { where("name LIKE :search", :search => "%#{search}%") }
  scope :sku_like, ->(search) { where("sku LIKE :search", :search => "%#{search}%") }
  scope :by_category, ->(search) { where("(category_id = :search) OR (:search = 0)", :search => "#{search}") }
  scope :by_brands, ->(search) { where("(brand_id = :search) OR (:search = 0)", :search => "#{search}") }
  scope :by_line, ->(search) { where("(product_line_id = :search) OR (:search = 0)", :search => "#{search}") }
  scope :ordered, -> { order(:name) }
  scope :actived, -> { where(:status => true) }
  scope :inactived, -> { where(:status => false) }

  enum stock_status: [:instock, :reorderstock, :lowstock]

  def main_selling_price
    (selling_price_type == true) ? selling_price : selling_price_ex
  end

  def main_purchase_price
    (purchase_price_type == true) ? purchase_price : purchase_price_ex
  end

  def in_stock?
    stock > 0
  end

  def stock
    #stock_level_adjustments.sum(:adjustment)
    quantity
  end

  def status_label
    (status == true) ? 'Active' : 'Inactive'
  end

  def markup
    (main_selling_price.to_f - main_purchase_price.to_f) * 100 / main_purchase_price.to_f
  end

  def gross_profit
    (main_selling_price.to_f - main_purchase_price.to_f) * 100 / main_selling_price.to_f
  end

  def stock_status_text    
    if self.instock?
      "In-Stock"
    elsif self.reorderstock?
      "Re-Order"
    else
      "Low-Stock"
    end
  end

  def update_stock_status
    if self.stock.to_i > self.reorder_qty.to_i * 2
      self.stock_status = :instock
    elsif self.stock.to_i > self.reorder_qty.to_i && self.stock.to_i <= self.reorder_qty.to_i * 2 && self.stock.to_i > 0
      self.stock_status = :reorderstock
    else
      self.stock_status = :lowstock
    end
  end

end
