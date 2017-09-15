class PurchaseItem < ActiveRecord::Base
    before_save :update_product_qty
    before_destroy :update_product_qty

    belongs_to :purchase_order, class_name: 'PurchaseOrder', touch: true, inverse_of: :purchase_items
    belongs_to :purchased_item, class_name: 'Product'

    validates :quantity, numericality: true
    validates :purchased_item, presence: true

    # Any stock level adjustments which have been made for this order item
    has_many :stock_level_adjustments, as: :parent, dependent: :nullify, class_name: 'StockLevelAdjustment'
    has_many :purchased_item_activities, dependent: :destroy, class_name: 'PurchaseItemActivity'

    # Before saving an order item which belongs to a received order, cache the pricing again if appropriate.
    before_save do
    end

    # After saving, if the order has been shipped, reallocate stock appropriate
    # it should be implemented for shipping and returning.
    after_save do
      #allocate_unallocated_stock! if purchase_order.shipped?
    end

    # The unit price for the item
    #
    # @return [BigDecimal]
    def unit_price
      read_attribute(:unit_price) || purchased_item.try(:purchase_price) || BigDecimal(0)
    end

    # The discount rate for the item
    #
    # @return [BigDecimal]
    def dicount_rate
      read_attribute(:discount_rate) || BigDecimal(0)
    end

    # The total discount for the item
    #
    # @return [BigDecimal]

    def discount_amount
      read_attribute(:discount_amount) || 0
    end

    # The tax rate for the item
    #
    # @return [BigDecimal]
    def tax_rate
      read_attribute(:tax_rate) || BigDecimal(0)
    end

    # The total tax for the item
    #
    # @return [BigDecimal]

    def tax_amount
      read_attribute(:tax_amount) || (sub_total / BigDecimal(100)) * tax_rate
    end

    # The sub total for the product
    #
    # @return [BigDecimal]
    def sub_total
      real_quantity * unit_price
    end

    # The total price including tax for the order line
    #
    # @return [BigDecimal]
    def total
      tax_amount + sub_total - discount_amount
    end

    # Cache the pricing for this order item
    def cache_pricing
      write_attribute :unit_price, unit_price
      write_attribute :tax_rate, tax_rate
      write_attribute :tax_amount, (sub_total / BigDecimal(100)) * tax_rate
      write_attribute :discount_rate, 0
      write_attribute :discount_amount, 0
    end

    # Cache the pricing for this order item and save
    def cache_pricing!
      cache_pricing
      save!
    end

    # Trigger when the associated order is confirmed. It handles caching the values
    # of the monetary items and allocating stock as appropriate.
    def confirm!
      cache_pricing!
      self.purchased_item.save!
    end

    # Trigged when the associated order is cancelled..
    def cancel!(amount, description, user)
        if quantity_to_receive >= amount.to_i && amount.to_i > 0
            self.purchased_item_activities.create!(purchase_item: self, quantity: amount, note: description, activity: 'cancel', updated_by: user)
            cache_pricing!
        end
    end

    # Trigged when the associated order is shipped..
    def receive!(amount, description, user, data)
        if quantity_to_receive >= amount.to_i && amount.to_i > 0
            self.purchased_item_activities.create!( purchase_item: self, 
                                                quantity: amount, 
                                                note: description, 
                                                activity: 'receive', 
                                                updated_by: user, 
                                                token: data,
                                                purchase_order_id: self.purchase_order.id)
            save!
        end
    end

    # Trigged when the associated order is deleted..
    def delete!
    end

    def update_product_qty
        self.purchased_item.stock!
    end

    def cancel_quantity
        purchased_item_activities.where(activity: 'cancel').sum(:quantity)
    end

    def received_quantity
        purchased_item_activities.where(activity: 'receive').sum(:quantity)
    end

    def real_quantity
        self.quantity
    end

    def quantity_to_receive
        self.quantity - received_quantity
    end

    # Validate the stock level against the product and update as appropriate. This method will be executed
    # before an order is completed. If we have run out of this product, we will update the quantity to an
    # appropriate level (or remove the order item) and return the object.
    def validate_stock_levels
        self.quantity = purchased_item.stock
        self.quantity == 0 ? destroy : save!
        self
    end

    # Allocate any unallocated stock for this order item. There is no return value.
    # def allocate_unallocated_stock!
    #   if unallocated_stock != 0
    #     purchased_item.stock_level_adjustments.create!(parent: self, adjustment: 0 - unallocated_stock, description: "Purchase Order ##{purchase_order.token}")
    #   end
    # end
end
