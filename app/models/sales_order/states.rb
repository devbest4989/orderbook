class SalesOrder < ActiveRecord::Base
  # An array of all the available statuses for an order
  STATUSES = %w(quote confirmed packed shipped fullfilled partial_shipped).freeze

  belongs_to :canceller, class_name: 'User', foreign_key: 'cancelled_by_id'
  belongs_to :booker, class_name: 'User', foreign_key: 'booked_by_id'

  # Validations
  validates :status, inclusion: { in: STATUSES }

  # Set the status to building if we don't have a status
  after_initialize { self.status = STATUSES.first if status.blank? }

  scope :quote, -> { where(status: 'quote') }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :packed, -> { where(status: 'packed') }
  scope :shipped, -> { where(status: 'shipped') }
  scope :partial_shipped, -> { where(status: 'shipped') }
  scope :drop_shipped, -> { where(status: 'drop_shipped') }
  scope :invoice, -> { where(status: 'fullfilled') }

  def quote?
    status == 'quote'
  end

  def confirmed?
    status == 'confirmed'
  end

  def packed?
    status == 'packed'
  end

  def shipped?
    status == 'shipped'
  end

  def partial_shipped?
    status == 'partial_shipped'
  end

  def fullfilled?
    status == 'fullfilled'
  end

  def status_text
    if status == 'partial_shipped'
      'partial-shipped'
    else
      status
    end
  end

  def status_class
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

  def status_label
    if status == 'fullfilled'
      "completed"
    else
      status
    end
  end
end
