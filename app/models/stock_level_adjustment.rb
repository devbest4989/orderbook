class StockLevelAdjustment < ActiveRecord::Base
    # The orderable item which the stock level adjustment belongs to
    belongs_to :item, class_name: 'Product'

    # The parent (Sales Order Item) which the stock level adjustment belongs to
    belongs_to :parent, polymorphic: true

    # Validations
    validates :description, presence: true
    validates :adjustment, numericality: true
    validate { errors.add(:adjustment, 'Stock adjustment must be greater than or equal to zero') if adjustment == 0 }

    # All stock level adjustments ordered by their created date desending
    scope :ordered, -> { order(id: :desc) }
end
