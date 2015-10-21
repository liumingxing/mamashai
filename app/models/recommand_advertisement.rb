class RecommandAdvertisement < ActiveRecord::Base
  upload_column :logo ,:process => '450x450', :versions => {:thumb50 => "c52x52",:thumb80 => "c62x80", :thumb70=>"c70x70"}
  
  #validates_length_of :content, :within => 2..40,:too_long=>'内容太长了',:too_short=>'内容太短了'
  
  def self.get(template=1, tp='home', age_id=nil, limit=1)
    conditions = ["1=1"]
    conditions << ["position='#{template}'"] if template
    conditions << "tp='#{tp}'"
    conditions << "age like '%,#{age_id},%'" if age_id
    results = RecommandAdvertisement.find(:all, :conditions=>conditions.join(' and '), :limit=>limit)
    if results.size == 0
      RecommandAdvertisement.find(:all, :conditions=>"position='#{template}' and tp='#{tp}'", :limit=>limit)
    else
      results
    end
  end
end
