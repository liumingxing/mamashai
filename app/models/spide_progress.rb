class SpideProgress < ActiveRecord::Base
  set_table_name :spide_progress
  
  def self.get(site_id)
    progress = SpideProgress.find(:first, :conditions=>"site_id = #{site_id}")
    if progress
      progress.url
    else
      nil
    end
  end
  
  def self.set(site_id, url)
    progress = SpideProgress.find(:first, :conditions=>"site_id = #{site_id}")
    progress = SpideProgress.new(:site_id => site_id) if !progress
    progress.url = url
    progress.save
  end
  
  def self.remove(site_id)
    SpideProgress.delete_all("site_id = #{site_id}")
  end
end
