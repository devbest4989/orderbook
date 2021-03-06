class SalesItem < ActiveRecord::Base
    after_save :update_product_qty
    after_destroy :update_product_qty

    belongs_to :sales_order, class_name: 'SalesOrder', touch: true, inverse_of: :sales_items
    belongs_to :sold_item, class_name: 'SubProduct'

    validates :quantity, numericality: true
    validates :sold_item, presence: true

    # Any stock level adjustments which have been made for this order item
    has_many :stock_level_adjustments, as: :parent, dependent: :nullify, class_name: 'StockLevelAdjustment'
    has_many :sales_item_activities, dependent: :destroy, class_name: 'SalesItemActivity'

    # Before saving an order item which belongs to a received order, cache the pricing again if appropriate.
    before_save do
    end

    # After saving, if the order has been shipped, reallocate stock appropriate
    # it should be implemented for shipping and returning.
    after_save do
      #allocate_unallocated_stock! if sales_order.shipped?
    end

    # The unit price for the item
    #
    # @return [BigDecimal]
    def unit_price
      read_attribute(:unit_price) || sold_item.try(:selling_price) || BigDecimal(0)
    end

    # The cost price for the item
    #
    # @return [BigDecimal]
    def unit_cost_price
      read_attribute(:unit_cost_price) || sold_item.try(:purchase_price) || BigDecimal(0)
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
      read_attribute(:discount_amount) || (sub_total / BigDecimal(100)) * discount_rate
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

    # The total cost for the product
    #
    # @return [BigDecimal]
    def total_cost
      real_quantity * unit_cost_price
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
      write_attribute :unit_cost_price, unit_cost_price
      write_attribute :tax_rate, tax_rate
      write_attribute :tax_amount, (sub_total / BigDecimal(100)) * tax_rate
      write_attribute :discount_rate, discount_rate
      write_attribute :discount_amount, (sub_total / BigDecimal(100)) * discount_rate
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
      self.sold_item.save!
    end

    # Trigged when the associated order is cancelled..
    def cancel!
        self.sales_item_activities.destroy_all
        # if quantity_to_ship >= amount.to_i && amount.to_i > 0
        #     self.sales_item_activities.create!(sales_item: self, quantity: amount, note: description, activity: 'cancel', updated_by: user)
        #     cache_pricing!
        # end
    end

    # Trigged when the associated order is returned..
    def return!(amount, description, user)
        if shipped_quantity >= amount.to_i && amount.to_i > 0
            self.sales_item_activities.create!(sales_item: self, quantity: amount, note: description, activity: 'return', updated_by: user)
            save!
        end
    end

    # Trigged when the associated order is shipped..
    def ship!(amount, description, user, data)
        if quantity_to_ship >= amount.to_i && amount.to_i > 0
            self.sales_item_activities.create!(sales_item: self, quantity: amount, note: description, activity: 'ship', updated_by: user, token: data)
            save!
        end
    end

    # Trigged when the associated order is shipped..
    def pack!(amount, description, user, data, unit_id, unit_name, unit_ratio)
        if quantity_to_pack >= amount.to_i && amount.to_i > 0
            self.sales_item_activities.create!( sales_item: self, 
                                                quantity: amount, 
                                                note: description, 
                                                activity: 'pack', 
                                                updated_by: user, 
                                                token: data,
                                                sales_order_id: self.sales_order.id,
                                                unit_id: unit_id,
                                                unit_name: unit_name,
                                                unit_ratio: unit_ratio
                                                )
            save!
        end
    end

    # Trigged when the associated order is deleted..
    def delete!
    end

    def update_product_qty
        self.sold_item.stock!
    end

    def cancel_quantity
        sales_item_activities.where(activity: 'cancel').sum(:quantity)
    end

    def return_quantity
        sales_item_activities.where(activity: 'return').sum(:quantity)
    end

    def shipped_quantity
        sales_item_activities.where(activity: 'ship').sum(:quantity)
    end

    def packed_quantity
        sales_item_activities.where(activity: 'pack').sum(:quantity)
    end

    def real_quantity
        self.quantity
    end

    def quantity_to_ship
        # packed_quantity - shipped_quantity
        self.quantity - shipped_quantity
    end

    def quantity_to_pack
        self.quantity - packed_quantity
    end

    # Do we have the stock needed to fulfil this order?
    #
    # @return [Boolean]
    def in_stock?
      if sold_item
        sold_item.stock >= unallocated_stock
      else
        true
      end
    end

    def in_stock_shipped_amount?(amount)
      if sold_item
        sold_item.stock >= amount
      else
        true
      end
    end

    # How much stock remains to be allocated for this order?
    #
    # @return [Fixnum]
    def unallocated_stock
      self.quantity - allocated_stock
    end

    # How much stock has been allocated to this item?
    #
    # @return [Fixnum]
    def allocated_stock
      0 - stock_level_adjustments.sum(:adjustment)
    end

    # Validate the stock level against the product and update as appropriate. This method will be executed
    # before an order is completed. If we have run out of this product, we will update the quantity to an
    # appropriate level (or remove the order item) and return the object.
    def validate_stock_levels
      if in_stock?
        false
      else
        self.quantity = sold_item.stock
        self.quantity == 0 ? destroy : save!
        self
      end
    end

    # Allocate any unallocated stock for this order item. There is no return value.
    def allocate_unallocated_stock!
      if unallocated_stock != 0
        sold_item.stock_level_adjustments.create!(parent: self, adjustment: 0 - unallocated_stock, description: "Sales Order ##{sales_order.token}")
      end
    end

end
