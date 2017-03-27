class SalesOrder < ActiveRecord::Base
  extend ActiveModel::Callbacks

  # These additional callbacks allow for applications to hook into other
  # parts of the order lifecycle.
  define_model_callbacks :confirmation, :cancellation, :shipping, :returning, :deleting, :packaging, :invoicing

  def quote!
    sales_items.each(&:confirm!)
  end
  # This method should be executed by the application when the order should be completed
  # by the customer. It will raise exceptions if anything goes wrong or return true if
  # the order has been confirmed successfully
  #
  # @return [Boolean]
  def confirm!(user = nil)
    run_callbacks :confirmation do
      # If we have successfully charged the card (i.e. no exception) we can go ahead and mark this
      # order as 'booked' which means it can be accepted by staff.
      self.status = 'confirmed'
      self.booked_at = Time.now
      save!

      sales_items.each(&:confirm!)

      # Send an email to the customer
      deliver_booked_order_email
    end
    # We're all good.
    true
  end

  def cancel!(user = nil)
    run_callbacks :cancellation do
      write_attribute :cancelled_at, Time.now
      write_attribute :total_amount, total_amount
      self.canceller = user if user
      save!
      deliver_cancelled_order_email
    end
    true
  end

  def return!(user = nil)
    run_callbacks :returning do
      deliver_returned_order_email
    end
    true
  end

  def pack!(user = nil)
    run_callbacks :packaging do
      self.status = pack_status
      save!
    end
    true
  end

  def ship!(user = nil)
    run_callbacks :shipping do
      self.shipped_at = Time.now
      self.status = ship_status
      save!
      deliver_shipped_order_email
    end
    true
  end

  def invoice!(user = nil)
    run_callbacks :invoicing do
      self.status = invoice_status
      save!
    end
    true    
  end

  def invoice_status
    result = self.status

    ship_count = self.ship_activities_datas.length
    invoice_count = self.invoice_activities_elems.length

    if (ship_count == invoice_count) && (self.total_quantity_to_pack == 0)
      result = 'fullfilled'
    else
      result = self.status
    end

    return result
  end

  def ship_status
    (total_quantity_to_ship == 0) ? 'shipped' : ((total_shipped_quantity > 0) ? 'partial_shipped' : 'packed')
  end

  def pack_status
    (total_quantity_to_pack == 0) ? 'packed' : 'confirmed'
  end

  def delete!(user = nil)
    run_callbacks :deleting do
      self.status = 'delete'
      save!
      sales_items.each(&:delete!)
    end
    true
  end  

  def deliver_booked_order_email
    #OrderMailer.accepted(self).deliver
  end

  def deliver_cancelled_order_email
    #OrderMailer.rejected(self).deliver
  end

  def deliver_shipped_order_email
    #OrderMailer.received(self).deliver
  end

  def deliver_returned_order_email
    #OrderMailer.received(self).deliver
  end
end