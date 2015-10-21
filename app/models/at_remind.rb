class AtRemind < ActiveRecord::Base
	belongs_to :post
	belongs_to :user

	after_create :make_comment_at_remind

	def make_comment_at_remind
		begin
			CommentAtRemind.create(:tp=>"post", :author_id=>self.post.id, :user_id=>self.user_id, :comment_id => self.post_id, :created_at=>self.post.created_at)
		rescue
		end
	end	
end
