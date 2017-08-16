class Payment < ActiveRecord::Base
	validates :payment_date, :amount, :payment_mode, :reference_no, :note, presence: true
end
