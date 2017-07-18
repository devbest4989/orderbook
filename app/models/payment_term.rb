class PaymentTerm < ActiveRecord::Base
	enum term_type: [:after_days, :fixed_day]
end
