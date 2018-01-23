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
        when "receive"
          "label-success"
        when "draft"
          "label-default"
        when "approved"
          "label-info"
        when "partial_received"
          "label-warning"
        when "received"
          "label-primary"
        when "fullfilled"
          "label-success"
        when "cancelled"
          "label-danger"
        end     
    end
end
