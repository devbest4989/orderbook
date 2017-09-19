class BillPayment < ActiveRecord::Base
	validates :payment_date, :amount, :payment_mode, :reference_no, presence: true
end
