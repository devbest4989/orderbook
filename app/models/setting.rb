class Setting < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true  
  scope :company_profile, -> { where(:conf_type => 1) }

  KEYS = %w(company.image company.name company.trading company.address company.phone company.fax company.email company.url)

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
