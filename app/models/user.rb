class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable
  
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/avatar/:style/default_image.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  scope :main_like, ->(search) { where("(LOWER(first_name) LIKE :search) or (LOWER(last_name) LIKE :search) or (email LIKE :search)", :search => "%#{search.downcase}%") }

  def full_name
    "#{first_name} #{last_name}"
  end  

  def role_name
  	case self.role
  	when 0
  	  "Admin"
  	when 1
  	  "Sales Manager"
  	when 2
  	  "Seller"
  	when 3
  	  "Owner"
  	end  	
  end
end
