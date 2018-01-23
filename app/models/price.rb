class Price < ActiveRecord::Base
    include ActionView::Helpers::NumberHelper
    
    belongs_to :product
    belongs_to :sub_product

    validates :sub_product, uniqueness: {scope: :name}

    def price_tax_exclude
        ex_value = 0
        if price_type == 1
            ex_value = value
        else
            ex_value = number_with_precision(value * 100 / (tax_value + 100), precision: 2)
        end
        return ex_value
    end

    def price_tax_include
        in_value = 0
        if price_type == 0
            in_value = value
        else
            in_value = number_with_precision(value * (tax_value + 100) / 100, precision: 2)
        end
        return in_value
    end

end
