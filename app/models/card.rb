require "open-uri"

class Card < ActiveRecord::Base
  has_attached_file :pic, :url => '/system/:id/:file_name', :path => ':rails_root/public/system/:id/:file_name'
  
  Paperclip.interpolates :file_name  do |attachment, style|
     attachment.instance.file_name
   end
     
  def picture_from_url(url)
      self.pic = open(url)
  end
  
  def file_name
    "card_"+self.id.to_s 
  end
end
