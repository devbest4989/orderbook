class GlobalMap < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true

  KEYS = %w(sales_no purchase_no)

  def self.sale_number
    order_number = GlobalMap.value_by('sales_no').to_i + 1
    GlobalMap.set_object('sales_no', order_number)
    return "SO-" + order_number.to_s.rjust(6, '0')
  end

  def self.set_object(key, value)
    item = GlobalMap.object_by(key)
    item.value = value
    item.save
  end

  def self.value_by(key)
    GlobalMap.object_by(key).try(:value)
  end

  def self.object_by(key)
    if GlobalMap::KEYS.include? key
      return GlobalMap.find_or_create_by(key: key)
    else
      return nil
    end
  end
end
