class Payment < ActiveRecord::Base
	#payment_mode -1: Credit Note

	validates :payment_date, :amount, :payment_mode, :reference_no, presence: true
end
