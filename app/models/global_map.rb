class GlobalMap < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true

  KEYS = %w(sales_no purchase_no track_no shipping_no)

  def self.sale_number
    order_number = GlobalMap.value_by('sales_no').to_i + 1
    GlobalMap.set_object('sales_no', order_number)
    return "SO#" + order_number.to_s.rjust(6, '0')
  end

  def self.purchase_number
    order_number = GlobalMap.value_by('purchase_no').to_i + 1
    GlobalMap.set_object('purchase_no', order_number)
    return "PO#" + order_number.to_s.rjust(6, '0')
  end

  def self.track_number
    track_number = GlobalMap.value_by('track_no').to_i + 1
    GlobalMap.set_object('track_no', track_number)
    return "GST#" + track_number.to_s.rjust(8, '0')
  end

  def self.shipping_number
    shipping_number = GlobalMap.value_by('shipping_no').to_i + 1
    GlobalMap.set_object('shipping_no', shipping_number)
    return "SHP#" + shipping_number.to_s.rjust(8, '0')
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
