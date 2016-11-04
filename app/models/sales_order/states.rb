class SalesOrder < ActiveRecord::Base
  # An array of all the available statuses for an order
  STATUSES = %w(draft booked shipped part-shipped cancel delete).freeze

  belongs_to :canceller, class_name: 'User', foreign_key: 'cancelled_by_id'
  belongs_to :booker, class_name: 'User', foreign_key: 'booked_by_id'

  # Validations
  validates :status, inclusion: { in: STATUSES }

  # Set the status to building if we don't have a status
  after_initialize { self.status = STATUSES.first if status.blank? }

  scope :draft, -> { where(status: 'draft') }

  scope :ordered, -> { order(id: :desc) }

  def draft?
    status == 'draft'
  end

  def booked?
    status == 'booked'
  end

  def cancelled?
    !!cancelled_at
  end

  def shipped?
    !!shipped_at
  end

  def status_class
    case status
    when "draft"
      "label-warning"
    when "booked"
      "label-primary"
    when "shipped"
      "label-success"
    when "part-shipped"
      "label-success"
    when "cancel"
      "label-danger"
    when "delete"
      "label-danger"
    end
  end
end
