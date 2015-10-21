class Vote < ActiveRecord::Base
  belongs_to :user
  
  def election_count
    @count || @count = VoteElection.count(:conditions=>"vote_id = #{self.id}")
  end
  
  def percent(option)
    return 0 if election_count == 0
    return VoteElection.count(:conditions=>"vote_id = #{self.id} and `option` = '#{option}'")*100 / election_count
  end
  
  def count(option)
    return VoteElection.count(:conditions=>"vote_id = #{self.id} and `option` = '#{option}'")
  end
  
  #是否投过票
  def voted?(user_id)
    VoteElection.find(:first, :conditions=>"vote_id = #{self.id} and user_id = #{user_id}") ? true : false
  end
  
  def mode_str()
    return "单选" if tp == 1
    return "最多选#{tp}个" if tp > 1
  end
end
