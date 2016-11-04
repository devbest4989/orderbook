class Contact < ActiveRecord::Base
  belongs_to :customer
  belongs_to :supplier
  
  def full_name
    "#{first_name} #{last_name}"
  end  
end
