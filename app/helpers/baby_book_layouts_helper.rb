# -*- coding: utf-8 -*-
module BabyBookLayoutsHelper
  def history_links(instance,column,action)
    history=instance.send(column)
    links=[]
    v_params={}
    params.select{|k,v| k.to_s=~/_version$/}.each{|v| v_params.merge!(v[0]=>v[1]) }
    unless history.blank?
      history.each_with_index do |v,i|
        links << link_to("版本 #{i} ",v_params.merge!("#{column}_version"=>i.to_s)) #
      end
    end
    links << link_to("当前版本")
    return links.reverse.join("&nbsp;&nbsp;")
  end
end
