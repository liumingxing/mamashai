class Age < ActiveRecord::Base
  has_many :posts
  has_many :products
  has_many :age_tags,:dependent => :delete_all
  has_many :post_tags,:through=>:age_tags,:conditions=> {:age_tags => {:tp => 0}},:source=>:tag
  has_many :ask_tags,:through=>:age_tags,:conditions=> {:age_tags => {:tp => 1}},:source=>:tag
  has_many :age_week_tags


  named_scope :named,lambda { |name|
    { :conditions => { :name => name } }
  }
  
  def name_str
   (self.id == 11) ? self.name : "#{self.name}#{APP_CONFIG['age_str']}"
  end

  def self.human_order
    ages = Age.find(:all)
    ages << ages.shift
    ages
  end
  
  
  ######################  methods   ######################
  
  def prev_age
    Age.find(:first, :conditions=>"id < #{self.id}", :order=>"id desc")
  end
  
  def next_age
    Age.find(:first, :conditions=>"id > #{self.id}", :order=>"id")
  end
  
  def self.get_age_id_from_birthday(birthday)
    return -1 if !birthday
    years = (Date.today - birthday.to_date).to_i/365
    return 2 if years < 0
    return 3 if years >= 0 and years < 1
    return 4 if years >= 1 and years < 2
    return 5 if years >= 2 and years < 3
    return 6 if years >= 3 and years < 5
    return 7 if years >= 5 and years < 7
    return 8 if years >= 7
  end
  
  def self.update_user_age_id(user)
    first_kid = user.first_kid
    if first_kid
      user.age_id = Age.get_age_id_from_birthday(first_kid.birthday)
    else
      user.age_id = 1
    end
    user.save(:validate=>false)
  end
  
  def self.get_kid_star_from_birthday(birthday)
    days = birthday.to_date.month * 30 + birthday.to_date.day
    return 1 if days >= 3 * 30 + 21 and days <= 4 * 30 + 19
    return 2 if days >= 4 * 30 + 20 and days <= 5 * 30 + 20
    return 3 if days >= 5 * 30 + 21 and days <= 6 * 30 + 21
    return 4 if days >= 6 * 30 + 22 and days <= 7 * 30 + 22
    return 5 if days >= 7 * 30 + 23 and days <= 8 * 30 + 22
    return 6 if days >= 8 * 30 + 23 and days <= 9 * 30 + 22
    return 7 if days >= 9 * 30 + 23 and days <= 10 * 30 + 23
    return 8 if days >= 10 * 30 + 24 and days <= 11 * 30 + 21
    return 9 if days >= 11 * 30 + 22 and days <= 12 * 30 + 21
    return 10 if days >= 12 * 30 + 22 or days <= 1 * 30 + 19
    return 11 if days >= 1 * 30 + 20 and days <= 2 * 30 + 18
    return 12 if days >= 2 * 30 + 19 and days <= 3 * 30 + 20
  end
  
  
end
