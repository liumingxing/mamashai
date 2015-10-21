
module MamashaiTools
  class ScoreUtil
    def initialize
    end
    
    def self.action_scores
      {:signup=>15,:create_age_or_tag=>1,:delete_age_or_tag=>-1,:create_reward_tag=>2,:delete_reward_tag=>-2,:create_spot_tag=>2,:delete_spot_tag=>-2,
        :create_forward_post=>1,:delete_forward_post=>-1,:create_favorite_post=>1,:delete_favorite_post=>-1,
        :create_fans=>1,:delete_fans=>-1,:create_question=>1,:delete_question=>-1,:create_mobile_post=>1,:delete_mobile_post=>-1,
        :user_logo=>10,:user_kid_logo=>10,:user_profile=>10,:user_kid_profile=>10,:over_50_follows=>10,
        :user_domain=>5,:user_blogs=>5,:user_mobile=>10,:invite_user=>15,:admin_delete_post=>-5,:cancel_event_signup=>-5,
        :user_book_score=>-380}
    end
    
    def self.user_book_abs_score(user)
      if user.is_get_reward_book? 
        return 0
      elsif UserReward.find_by_user_id(user.id)
        return 260
      else
        return self.action_scores[:user_book_score].abs
      end
    end
    
    def self.update_score(user,tp,params={})
      score = 0
      user_profile = user.user_profile
      if params[:one_time_action]
        return 0 if user_profile and user_profile.score_actions and user_profile.score_actions.index(tp.to_s)
      end 
      
      score = self.action_scores[tp] unless params[:score]
      score = params[:score] if params[:score]
      
      ActiveRecord::Base.transaction do
        User.update_all(["score = score + ?",score],["id=?",user.id])
        total_score = User.find(user.id).score
        score_event = ScoreEvent.new(:event=>tp.to_s,:score=>score,:user_id=>user.id,:total_score=>total_score)
        if params[:post]
          score_event.post_id = params[:post].id
          score_event.tag_id = params[:post].tag_id
        end
        if params[:user_name]
          score_event.user_name = params[:user_name]
        end
        score_event.save
     
        
        if params[:one_time_action] and user_profile
          user_profile.update_score_actions(tp.to_s)
        end
      end 
      return score
    end
    
    
  end
end
