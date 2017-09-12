class PurchaseCustomItem < ActiveRecord::Base
    belongs_to :purchase_order, class_name: 'PurchaseOrder', touch: true, inverse_of: :purchase_custom_items

    # The unit price for the item
    #
    # @return [BigDecimal]
    def unit_price
      read_attribute(:unit_price) || BigDecimal(0)
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

    # The sub total for the product
    #
    # @return [BigDecimal]
    def sub_total
      quantity * unit_price
    end

    # The total price including tax for the order line
    #
    # @return [BigDecimal]
    def total
      tax_amount + sub_total - discount_amount
    end

    def confirm!
        write_attribute :unit_price, unit_price
        write_attribute :tax_rate, tax_rate
        write_attribute :tax_amount, (sub_total / BigDecimal(100)) * tax_rate
        write_attribute :discount_rate, discount_rate
        write_attribute :discount_amount, (sub_total / BigDecimal(100)) * discount_rate
        
        save!
    end
end
