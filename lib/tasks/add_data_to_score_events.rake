# -*- coding: utf-8 -*-
namespace :mamashai do
  desc "add data to score events"
  task :add_data_to_score_events  => [:environment] do
    score_events = ScoreEvent.all
    events = {}
    APP_CONFIG.each do |key, value|
       if key =~ /^score_/
         event = key[6..key.length]
         events[event.to_sym] = value
       end
    end
    i = 0
    score_events.each do |score_event|
      events.each do |event, value|
        if score_event.event == event.to_s
          i = i + 1
          ActiveRecord::Base.transaction do 
            score_event.event_description = value
            if score_event.save
              puts "修改#{score_event.user.name}--#{score_event.event}--#{score_event.event_description}成功！" if i % 10000 == 0
            else
              puts "修改#{score_event.user.name}--#{score_event.event}--#{score_event.event_description}失败！" if i % 10000 == 0
            end
          end
        end
      end
    end
  end
end
