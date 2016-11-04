class Document < ActiveRecord::Base
  belongs_to :customer
  belongs_to :supplier

  has_attached_file :file, :path => "/document/:id_:filename", :url  => "/document/:id_:filename"
  validates_attachment :file, presence: true, content_type: { content_type: "application/pdf" }
end
