class RedPacket < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user

  before_create :get_score

  def get_score
  	cs = self.tp.split(',')
  	self.score = 0
  	for c in cs
  		self.score += c.to_i * 10
  	end
  end
end
