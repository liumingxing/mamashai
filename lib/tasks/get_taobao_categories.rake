require 'mamashai_tools/taobao_util'
include MamashaiTools

namespace :mamashai do
  desc "获取淘宝类目"
  task :get_taobao_categories  => [:environment] do
    for category in TaoCategory.find(:all)
      next if !category.is_parent
      get_children_of(category)
    end
  end
  
  def get_children_of(category) 
      json = taobao_call("taobao.itemcats.get", {"fields"=>"cid,parent_cid,name,is_parent", "parent_cid"=>category.code.to_s})
      for item in json["itemcats_get_response"]["item_cats"]["item_cat"]
        child = TaoCategory.new(:parent_id => category.id)
        child.code = item['cid']
        child.name = child.taobao_name = item['name']
        child.parent_code = item['parent_cid']
        child.is_parent = item["is_parent"]
        child.save
        p child
        
        if child.is_parent
          get_children_of(child)
        end
      end
  end
end