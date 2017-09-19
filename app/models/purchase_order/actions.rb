class PurchaseOrder < ActiveRecord::Base
  extend ActiveModel::Callbacks

  # These additional callbacks allow for applications to hook into other
  # parts of the order lifecycle.
  define_model_callbacks :approving, :cancellation, :deleting, :receiving, :invoicing

  def draft!
    purchase_items.each(&:confirm!)
    purchase_custom_items.each(&:confirm!)
  end
  # This method should be executed by the application when the order should be completed
  # by the customer. It will raise exceptions if anything goes wrong or return true if
  # the order has been approved successfully
  #
  # @return [Boolean]
  def approve!(user = nil)
    run_callbacks :approving do
      # If we have successfully charged the card (i.e. no exception) we can go ahead and mark this
      # order as 'booked' which means it can be accepted by staff.
      self.status = 'approved'
      self.booked_at = Time.now
      save!

      purchase_items.each(&:confirm!)
    end
    # We're all good.
    true
  end

  def cancel!(user = nil)
    run_callbacks :cancellation do
      write_attribute :cancelled_at, Time.now
      write_attribute :total_amount, total_amount
      self.status = 'cancelled'
      self.canceller = user if user
      save!      

      purchase_items.each(&:cancel!)
    end
    true
  end

  def receive!(user = nil)
    run_callbacks :receiving do
      self.status = receive_status
      save!
    end
    true
  end

  def bill!(user = nil)
    run_callbacks :invoicing do
      self.status = bill_status
      save!
    end
    true    
  end

  def confirm_status!(user = nil)
    run_callbacks :invoicing do
      self.status = confirm_status
      save!
    end
    true
  end

  def bill_status
    result = self.status
    if (total_paid_amount >= total_amount && self.received?)
      result = 'fullfilled'
    elsif (total_paid_amount <= total_amount)
      result = receive_status
    end
    return result
  end

  def confirm_status
    result = 'approved'
    if (total_received_quantity > 0 && total_quantity_to_receive > 0)
      result = 'partial_received'
    elsif (total_received_quantity > 0 && total_quantity_to_receive == 0)
      result = 'received'
    end

    if (total_paid_amount >= total_amount && self.received?)
      result = 'fullfilled'
    end
    return result
  end

  def receive_status
    (total_quantity_to_receive == 0) ? 'received' : 'approved'
  end

  def delete!(user = nil)
    run_callbacks :deleting do
      self.status = 'delete'
      save!
      purchase_items.each(&:delete!)
    end
    true
  end  
end