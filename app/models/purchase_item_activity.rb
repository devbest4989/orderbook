class PurchaseItemActivity < ActiveRecord::Base
	  ACTIVITIES = %w(receive).freeze
    
    after_save :update_product_qty
    after_destroy :update_product_qty
    
    belongs_to :purchase_item, class_name: 'PurchaseItem'
    belongs_to :updated_by, class_name: 'User', foreign_key: 'updated_by'

    def discount_amount
      (quantity * purchase_item.unit_price / BigDecimal(100)) * purchase_item.discount_rate
    end

    def sub_total_amount
      quantity * purchase_item.unit_price - discount_amount
    end

    def tax_amount
      (quantity * purchase_item.unit_price / BigDecimal(100)) * purchase_item.tax_rate
    end

    def total_amount
      sub_total_amount + tax_amount
    end

    def update_product_qty
        self.purchase_item.purchased_item.stock!
    end    
end
