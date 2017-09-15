class PurchaseOrder < ActiveRecord::Base
  # An array of all the available statuses for an order
  STATUSES = %w(draft approved received partial_received fullfilled).freeze

  belongs_to :canceller, class_name: 'User', foreign_key: 'cancelled_by_id'
  belongs_to :booker, class_name: 'User', foreign_key: 'booked_by_id'

  # Validations
  validates :status, inclusion: { in: STATUSES }

  # Set the status to building if we don't have a status
  after_initialize { self.status = STATUSES.first if status.blank? }

  scope :draft, -> { where(status: 'draft') }
  scope :approved, -> { where(status: 'approved') }
  scope :received, -> { where(status: 'received') }
  scope :partial_received, -> { where(status: 'partial_received') }
  scope :bill, -> { where(status: 'fullfilled') }

  def draft?
    status == 'draft'
  end

  def approved?
    status == 'approved'
  end

  def received?
    status == 'received'
  end

  def partial_received?
    status == 'partial_received'
  end

  def fullfilled?
    status == 'fullfilled'
  end

  def status_text
    if status == 'partial_received'
      'partial Received'
    else
      status
    end
  end

  def status_class
    case status
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
    end
  end

  def status_label
    if status == 'fullfilled'
      "completed"
    elsif status == 'partial_received'
      "partial Received"
    else
      status
    end
  end
end
