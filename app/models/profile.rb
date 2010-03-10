class Profile < ActiveRecord::Base
  has_many :assignments
  has_many :rankings, :dependent => :destroy, 
    :include => {:skill => :category},
    :order => 'skills.name'
  has_many :skills, :through => :rankings
  
  accepts_nested_attributes_for :assignments, :allow_destroy => true
  accepts_nested_attributes_for :rankings, :allow_destroy => true
  
  def name
    first_name + " " + last_name
  end
  
  def munged_name
    munge(first_name) + "_" + munge(last_name)
  end
  
  def munge text
    text.gsub(/\s+/, '-').gsub(/[^\w-]+/, '')
  end
  
  def self.find id, *more
    if /_/.match id.to_s
      first_name, last_name = *id.to_s.split('_').collect {|s| s.gsub '-', ' '}
      find_by_first_name_and_last_name(first_name, last_name, more) || super
    else
      super
    end
  end
  
  def to_param
    munged_name
  end
  
  def file_name
    %w{ÅA åa ÄA äa ÖO öo ÜU üu}.inject(munged_name) {|s,r| s.gsub *r.scan(/./)}
  end
  
  def image_path
    p = jpeg_file_path file_name
    if p.exist?
      p
    else
      jpeg_file_path 'Default'
    end    
  end
  
  def categories
    rankings.collect {|q| q.skill.category}.uniq
  end
  
  def html_image_path
    '/images/' + File.basename(image_path) 
  end

  def jpeg_file_path name
    Rails.root.join 'public', 'images', name + '.jpg'
  end
end
