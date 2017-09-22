include Carmen
class PurchaseOrder < ActiveRecord::Base
    require_dependency 'purchase_order/states'
    require_dependency 'purchase_order/actions'

    # All items which make up this order
    has_many :purchase_items, dependent: :destroy, class_name: 'PurchaseItem', inverse_of: :purchase_order
    accepts_nested_attributes_for :purchase_items, allow_destroy: true, reject_if: proc { |a| a['purchased_item_id'].blank? }

    has_many :purchase_custom_items, dependent: :destroy, class_name: 'PurchaseCustomItem', inverse_of: :purchase_order
    accepts_nested_attributes_for :purchase_custom_items, allow_destroy: true

    # All products which are part of this order (accessed through the items)
    has_many :products, through: :purchase_items, class_name: 'Product', source: :purchased_item
    has_many :purchase_item_activities, class_name: 'PurchaseItemActivity'
    has_many :action_histories, -> { where(item_type: 'PurchaseOrder') }, class_name: 'ActionHistory', foreign_key: 'item_id', dependent: :destroy
    has_many :bills, class_name: 'Bill'

    # The order can belong to a supplier
    belongs_to :supplier
    belongs_to :payment_term
    belongs_to :condition_term
    belongs_to :warehouse

    self.per_page = 25

    scope :token_like, ->(search) { where("token LIKE ?", "%#{search}%") }    
    scope :created_at_between, ->(from, to) { where(created_at: from..to) }
    scope :order_date_between, ->(from, to) { where(order_date: from..to) }
    scope :total_amount_between, ->(from, to) { where("(total_amount >= ? OR ? = 0) AND (total_amount <= ? OR ? = 0)", from.to_f, from.to_f, to.to_f, to.to_f) }
    scope :by_status, ->(search) { where("status = ? OR '' = ?", "#{search}", "#{search}") }
    scope :by_supplier_name, ->(search) { joins(:supplier).where("LOWER(suppliers.first_name) LIKE ? OR LOWER(suppliers.last_name) LIKE ? OR LOWER(suppliers.company_name) LIKE ?", "%#{search.downcase}%", "%#{search.downcase}%", "%#{search.downcase}%") }
    scope :ordered, -> { order({order_date: :desc, token: :desc}) }
    scope :paid_amount, -> { joins("LEFT JOIN purchase_items ON purchase_orders.id = purchase_items.purchase_order_id")
                             .joins("LEFT JOIN purchase_items ON purchase_orders.id = purchase_items.purchase_order_id")
                            }

    def bill_country_long
        if !self.bill_country.blank?
         Country.coded(self.bill_country).name
        else
          return ""
        end
    end

    def bill_state_long
        if !self.bill_country.blank? && !self.bill_state.blank?
          if self.bill_country == 'NZ'
           self.bill_state
          else
           Country.coded(self.bill_country).subregions.coded(self.bill_state).name
          end
        else
          return ""
        end
    end

    def ship_country_long
        if !self.ship_country.blank?
          Country.coded(self.ship_country).name
        else
          return ""
        end   
    end

    def ship_state_long
        if !self.ship_country.blank? && !self.ship_state.blank?
          if self.ship_country == 'NZ'
           self.ship_state
          else
           Country.coded(self.ship_country).subregions.coded(self.ship_state).name
          end
        else
          return ""
        end
    end


    def billing_address
        "#{bill_street} #{bill_suburb} #{bill_city} #{bill_postcode} #{bill_state_long} #{bill_country_long}"
    end

    def shipping_address
        "#{ship_street} #{ship_suburb} #{ship_city} #{ship_postcode} #{ship_state_long} #{ship_country_long}"
    end

    def supplier_name
      supplier.name
    end

    # The full name of the supplier created by concatinting the first & last name
    #
    # @return [String]
    def supplier_full_name
      "#{supplier.company_name} <br/> (<small>#{supplier.full_name}</small>)"
    end

    # Is this order empty? (i.e. doesn't have any items associated with it)
    #
    # @return [Boolean]
    def empty?
      purchase_items.empty?
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
      purchase_items.inject(0) { |t, i| t + i.quantity }
    end

    def payment_term_info
        ApplicationHelper::PAYMENT_TERMS[self.payment_term - 1]
    end

    def sub_total
        sub_total = 0
        purchase_items.each do |item|
            sub_total += item.sub_total - item.discount_amount
        end
        purchase_custom_items.each do |item|
            sub_total += item.sub_total - item.discount_amount
        end
        sub_total
    end

    def total_quantity_to_receive
        qty_to_receive = 0
        purchase_items.each do |item|
            qty_to_receive += item.quantity_to_receive
        end
        qty_to_receive
    end

    def total_received_quantity
        received_qty = 0
        purchase_items.each do |item|
            received_qty += item.received_quantity
        end
        received_qty
    end

    def discount_amount
        purchase_items.sum("discount_amount") + purchase_custom_items.sum("discount_amount")
    end

    def tax_amount
        purchase_items.sum("tax_amount") + purchase_custom_items.sum("tax_amount")
    end

    def bill_total
        bills.sum("total")
    end

    def total_paid_amount
        total_paid = 0
        bills.each do |item|
            total_paid += item.total_paid
        end
        total_paid
    end

    def cancel_activities
        self.purchase_item_activities.where(activity: 'cancel')
    end

    def return_activities
        self.purchase_item_activities.where(activity: 'return').order(:token)
    end

    def receive_activities
        self.purchase_item_activities.where(activity: 'receive').order(:token)
    end

    def bill_activities
        self.purchase_item_activities.where(activity: 'bill').order(:token)
    end

    def receive_activities_elems
        self.purchase_item_activities.where(activity: 'receive').group(:token).count
    end

    def bill_activities_elems
        self.purchase_item_activities.where(activity: 'bill').group(:token).count
    end

    def bill_activities_datas
        self.purchase_item_activities.where(activity: 'bill').group(:activity_data).select(:activity_data).map{|elem| elem.activity_data}
    end
end
