module ProductsHelper
    def movement_status status
        case status
        when "quote"
          "label-default"
        when "confirmed"
          "label-info"
        when "packed"
          "label-warning"
        when "shipped"
          "label-primary"
        when "partial_shipped"
          "label-primary"
        when "fullfilled"
          "label-success"
        end     
    end
end
