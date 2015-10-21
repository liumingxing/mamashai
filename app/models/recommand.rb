class Recommand < ActiveRecord::Base
  def self.get(tp, limit=3)
    recommand_ids = (Recommand.find(:all, :conditions=>"t='#{tp}'", :limit=>limit, :order=>"id desc").collect{|r| r.t_id}<<-1).join(',')
    if %w(post ask blog column).include?(tp) 
      Post.find(:all, :conditions=>"id in (#{recommand_ids})", :order=>"id desc")
    elsif %w(picture).include?(tp)
      Picture.find(:all, :conditions=>"id in (#{recommand_ids})", :order=>"id desc")
    elsif %w(subject).include?(tp)
      Subject.find(:all, :conditions=>"id in (#{recommand_ids})", :order=>"id desc")
    elsif %w(tools tools2).include?(tp)
      Mms::Tool.find(:all, :conditions=>"id in (#{recommand_ids})", :order=>"id desc")
    elsif %w(gou).include?(tp)
      Gou.find(:all, :conditions=>"id in (#{recommand_ids})")
    elsif %w(tuan_site).include?(tp)
      TuanWebsite.find(:all, :conditions=>"id in (#{recommand_ids})")
    elsif %w(brand).include?(tp)
      GouBrand.find(:all, :conditions=>"id in (#{recommand_ids})")
    end
  end
end
