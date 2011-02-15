class BadgeImage < ActiveRecord::Base
  MAX_IMAGE_SIZE = 3145728 # Max bytes
  CONTENT_TYPES = ['image/jpg', 'image/jpeg', 'image/gif', 'image/png']
  THUMB_SIZE = "100x100!"
  ORIGINAL_SIZE = "100x100!"

  validates_attachment_presence :image
  validates_attachment_size :image, :less_than => MAX_IMAGE_SIZE
  validates_attachment_content_type :image, { :content_type => CONTENT_TYPES }
  
  attr_protected :id
  
  belongs_to :client
  has_many :badges
  
  has_attached_file :image, {
    :styles => { 
      :thumb => THUMB_SIZE, 
      :original => ORIGINAL_SIZE 
    }
  }.merge(OPTIONS[:paperclip_storage_options])
  
end
