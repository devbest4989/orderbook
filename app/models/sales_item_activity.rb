class SalesItemActivity < ActiveRecord::Base
	ACTIVITIES = %w(pack ship).freeze

    belongs_to :sales_item, class_name: 'SalesItem'
    belongs_to :updated_by, class_name: 'User', foreign_key: 'updated_by'

    def discount_amount
      (quantity * sales_item.unit_price / BigDecimal(100)) * sales_item.discount_rate
    end

    def sub_total_amount
      quantity * sales_item.unit_price - discount_amount
    end

    def tax_amount
      (quantity * sales_item.unit_price / BigDecimal(100)) * sales_item.tax_rate
    end

end
