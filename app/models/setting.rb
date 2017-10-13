class Setting < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true  
  scope :company_profile, -> { where(:conf_type => 1) }
  scope :station, -> { where(:conf_type => 2) }
  scope :email_template, -> { where(:conf_type => 3) }

  KEYS = %w(
    company.image 
    company.name 
    company.trading 
    company.address 
    company.phone 
    company.fax 
    company.email 
    company.url

    format.currency
    format.customer_balance

    invoice.template
    invoice.color
    invoice.title
    invoice.logo

    package.template
    package.color
    package.title
    package.logo

    shipment.template
    shipment.color
    shipment.title
    shipment.logo

    quote.template
    quote.color
    quote.title
    quote.logo
    )

  def self.value_by(key)
    Setting.object_by(key).try(:value)
  end

  def self.object_by(key)
    if Setting::KEYS.include? key
      return Setting.find_or_create_by(key: key)
    else
      return nil
    end
  end
end
