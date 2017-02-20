class SalesOrder < ActiveRecord::Base
  extend ActiveModel::Callbacks

  # These additional callbacks allow for applications to hook into other
  # parts of the order lifecycle.
  define_model_callbacks :confirmation, :cancellation, :shipping, :returning, :deleting

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

  def ship!(user = nil)
    run_callbacks :shipping do
      self.shipped_at = Time.now
      self.status = ship_status
      save!
      deliver_shipped_order_email
    end
    true
  end

  def ship_status
    if shipped?
      (total_quantity_to_ship == 0) ? 'shipped' : 'part-shipped'
    else
      self.status
    end
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