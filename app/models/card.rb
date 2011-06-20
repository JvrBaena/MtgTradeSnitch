require "open-uri"

class Card < ActiveRecord::Base
  has_attached_file :pic
  
  def picture_from_url(url)
      self.pic = open(url)
  end
end
