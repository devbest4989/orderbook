include Carmen
class Supplier < ActiveRecord::Base
  
  has_many :documents, :dependent => :destroy
  has_many :contacts, :dependent => :destroy

  self.per_page = 25

  scope :name_like, ->(search) { where("(first_name LIKE :search) or (last_name LIKE :search)", :search => "%#{search}%") }
  scope :company_name_like, ->(search) { where("company_name LIKE ?", "%#{search}%") }
  scope :trading_name_like, ->(search) { where("trading_name LIKE ?", "%#{search}%") }
  scope :phone_like, ->(search) { where("phone LIKE ?", "%#{search}%") }
  scope :email_like, ->(search) { where("email LIKE ?", "%#{search}%") }

  def full_name
    "#{first_name} #{last_name}"
  end  

  def bill_country_long
    if !self.bill_country.blank?
  	 Country.coded(self.bill_country).name
    else
      return ""
    end
  end

  def bill_state_long
    if !self.bill_country.blank? && !self.bill_state.blank?
  	  Country.coded(self.bill_country).subregions.coded(self.bill_state).name
    else
      return ""
    end
  end

  def ship_country_long
    if !self.ship_country.blank?
      Country.coded(self.ship_country).name
    else
      return ""
    end  	
  end

  def ship_state_long
    if !self.ship_country.blank? && !self.ship_state.blank?
  	  Country.coded(self.ship_country).subregions.coded(self.ship_state).name
    else
      return ""
    end
  end

  def billing_address
  	"#{bill_street} #{bill_suburb} #{bill_city} #{bill_postcode} #{bill_state_long} #{bill_country_long}"
  end

  def shipping_address
  	"#{ship_street} #{ship_suburb} #{ship_city} #{ship_postcode} #{ship_state_long} #{ship_country_long}"
  end
end
