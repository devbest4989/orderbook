include Carmen
class SalesOrder < ActiveRecord::Base

    require_dependency 'sales_order/states'
    require_dependency 'sales_order/actions'
        
    # All items which make up this order
    has_many :sales_items, dependent: :destroy, class_name: 'SalesItem', inverse_of: :sales_order
    accepts_nested_attributes_for :sales_items, allow_destroy: true, reject_if: proc { |a| a['sold_item_id'].blank? }

    # All products which are part of this order (accessed through the items)
    has_many :products, through: :sales_items, class_name: 'Product', source: :sold_item
    has_many :sales_item_activities, class_name: 'SalesItemActivity'
    has_many :action_histories, -> { where(item_type: 'SalesOrder') }, class_name: 'ActionHistory', foreign_key: 'item_id', dependent: :destroy
    has_many :invoices, class_name: 'Invoice'

    # The order can belong to a customer
    belongs_to :customer
    belongs_to :shipping_method

    self.per_page = 25

    scope :token_like, ->(search) { where("token LIKE ?", "%#{search}%") }    
    scope :created_at_between, ->(from, to) { where(created_at: from..to) }
    scope :order_date_between, ->(from, to) { where(order_date: from..to) }
    scope :total_amount_between, ->(from, to) { where("(total_amount >= ? OR ? = 0) AND (total_amount <= ? OR ? = 0)", from.to_f, from.to_f, to.to_f, to.to_f) }
    scope :by_status, ->(search) { where("status = ? OR '' = ?", "#{search}", "#{search}") }
    scope :by_customer_name, ->(search) { joins(:customer).where("LOWER(customers.first_name) LIKE ? OR LOWER(customers.last_name) LIKE ? OR LOWER(customers.company_name) LIKE ?", "%#{search.downcase}%", "%#{search.downcase}%", "%#{search.downcase}%") }
    scope :ordered, -> { order({order_date: :desc, token: :desc}) }
    scope :paid_amount, -> { joins("LEFT JOIN sales_items ON sales_orders.id = sales_items.sales_order_id")
                             .joins("LEFT JOIN sales_items ON sales_orders.id = sales_items.sales_order_id")
                            }

    def customer_name
      customer.name
    end

    # The full name of the customer created by concatinting the first & last name
    #
    # @return [String]
    def customer_full_name
      customer.full_name
    end

    # Is this order empty? (i.e. doesn't have any items associated with it)
    #
    # @return [Boolean]
    def empty?
      sales_items.empty?
    end

    # Does this order have items?
    #
    # @return [Boolean]
    def has_items?
      total_items > 0
    end

    # Return the number of items in the order?
    #
    # @return [Integer]
    def total_items
      sales_items.inject(0) { |t, i| t + i.quantity }
    end

    def payment_term_info
        ApplicationHelper::PAYMENT_TERMS[self.payment_term - 1]
    end

    def sub_total
        sub_total = 0
        sales_items.each do |item|
            sub_total += item.sub_total - item.discount_amount
        end
        sub_total
    end

    def total_quantity_to_ship
        qty_to_ship = 0
        sales_items.each do |item|
            qty_to_ship += item.quantity_to_ship
        end
        qty_to_ship
    end

    def total_shipped_quantity
        shipped_qty = 0
        sales_items.each do |item|
            shipped_qty += item.shipped_quantity
        end
        shipped_qty
    end

    def total_quantity_to_pack
        qty_to_pack = 0
        sales_items.each do |item|
            qty_to_pack += item.quantity_to_pack
        end
        qty_to_pack
    end

    def total_packed_quantity
        packed_qty = 0
        sales_items.each do |item|
            packed_qty += item.packed_quantity
        end
        packed_qty
    end

    def discount_amount
        sales_items.sum("discount_amount")
    end

    def tax_amount
        sales_items.sum("tax_amount")
    end

    def invoice_total
        invoices.sum("total")
    end

    def total_paid_amount
        total_paid = 0
        invoices.each do |item|
            total_paid += item.total_paid
        end
        total_paid
    end

    def total_ship_amount
        self.sales_item_activities.where(activity: 'ship').sum(:total)
    end

    def shipping_cost
    end

    def cancel_activities
        self.sales_item_activities.where(activity: 'cancel')
    end

    def return_activities
        self.sales_item_activities.where(activity: 'return')
    end

    def ship_activities
        self.sales_item_activities.where(activity: 'ship').order(:token)
    end

    def pack_activities
        self.sales_item_activities.where(activity: 'pack').order(:token)
    end

    def invoice_activities
        self.sales_item_activities.where(activity: 'invoice').order(:token)
    end

    def pack_activities_elems
        self.sales_item_activities.where(activity: 'pack').group(:token).count
    end

    def ship_activities_elems
        self.sales_item_activities.where(activity: 'ship').group(:token).count
    end

    def ship_activities_datas
        self.sales_item_activities.where(activity: 'ship').group(:activity_data).select(:activity_data).map{|elem| elem.activity_data}
    end

    def invoice_activities_elems
        self.sales_item_activities.where(activity: 'invoice').group(:token).count
    end

    def invoice_activities_datas
        self.sales_item_activities.where(activity: 'invoice').group(:activity_data).select(:activity_data).map{|elem| elem.activity_data}
    end
end
