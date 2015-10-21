# -*- coding: utf-8 -*-
module Mms
  class Score    
    def self.trigger_event(event, description, score, exchange_ratio, params={})
      event == event.to_sym
      score_profile = record_to_db(event, description, score, exchange_ratio)
      return unless validate(score_profile, params)
      return unless yield(event,score_profile,params) if block_given?
      set_score(score_profile,params)
    end
    
    def self.set_score(score_profile,params)
      user,operator,post,order,cost,description = params[:user],params[:operator],params[:post],params[:order],params[:cost],params[:description]
      unit = ((params[:total]/score_profile.exchange_ratio).to_i unless params[:total].blank?) || 1
      score = cost||score_profile.score * unit
      ActiveRecord::Base.transaction do
        ::User.update_all(["users.score = users.score + ?",score],["users.id=?",user.id])
        user.reload
        score_event = ScoreEvent.create!(:event=>score_profile.event.to_s,:score=>score,:user_id=>user.id,:total_score=>user.score,:post_id=>post.try(:id),:tag_id=>post.try(:tag_id),:operator_id=>operator.try(:id)||-888, :order_id => order.try(:id), :unit => unit, :event_description => description||score_profile.description )
      end 
    end
    
    def self.record_to_db(event, description, score, exchange_ratio)
      score_profile = ScoreProfile.find_or_initialize_by_event(event.to_s)
      score_profile.update_attributes(:event=>event.to_s, :description => description, :score=> score, :exchange_ratio => exchange_ratio) if score_profile.new_record?
      score_profile.score = score
      score_profile
    end
    
    def self.validate(score_profile, params)
      return self.send(params[:cond], score_profile, params) if params[:cond].present? and self.respond_to?(params[:cond])
      return true
    end

    def self.by_days(score_profile,params)
      event = score_profile.event.to_sym
      return false if params[:user].blank?
      return false if params[:days].blank?
      days = params[:days].to_i
      return false if params[:per_day_event].blank?
      per_day_event = params[:per_day_event]
      today = Date.today
      begin_time = (today -  days).tomorrow.beginning_of_day
      end_time = today.end_of_day

      records = ScoreEvent.all :conditions=>["event = :event and created_at between :begin and :end and user_id = :user_id",{:event=>event.to_s, :begin=>begin_time, :end=>end_time, :user_id => params[:user].id}]      
      return false if records.present?
      
      days_record = ScoreEvent.all :conditions=>["event = :event and created_at between :begin and :end and user_id = :user_id",{:event=>per_day_event, :begin=>begin_time, :end=>end_time, :user_id => params[:user].id}]
      return false if days_record.size != days
      return true
    end
    
    def self.by_per_day(score_profile, params)
      event = score_profile.event.to_sym
      return false if params[:user].blank?
      today = Date.today
      records = ScoreEvent.all :conditions=>["event = :event and user_id = :user_id and created_day = :begin",{:event=>event.to_s, :begin=>today, :user_id => params[:user].id}]      
      return false if records.size > 0
      return true
    end
        
    def self.by_first_time(score_profile, params)
      return false if params[:user].blank?
      records = ScoreEvent.all :conditions => ["event = ? and user_id = ?",score_profile.event.to_s, params[:user].id]
      return false if records.present?
      return true
    end
    
    def self.by_first_order_id(score_profile, params)
      return false if params[:user].blank?
      return false if params[:order].blank?
      records = ScoreEvent.all :conditions => ["event = ? and user_id = ? and order_id = ?",score_profile.event.to_s, params[:user].id, params[:order].id]
      return false if records.present?
      return true
    end
    
  end
end
