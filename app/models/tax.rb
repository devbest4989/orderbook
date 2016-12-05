class Tax < ActiveRecord::Base
	def short_desc
		"#{name} - #{rate}%"
	end
end
