# -*- coding: utf-8 -*-
require 'uri'
require 'md5'

#get token from http://labs.tui3.cn/139/test.html or get from ARGV[0]
module M139
  def self.get_token
    #return ARGV[0]||"490008abc67313cfdd62888d56edcfd5"
     str=call_api({"method"=>"miop.connect.getSession", 'app_account' => 'test'})
     if str =~ /<key>(.*)<\/key>/m
       return $1
     else
       return "490008abc67313cfdd62888d56edcfd5"
     end

  end

  def self.server
    "http://api.139.com/restserver.php"
  end

  def self.app_key
    '9a19e634a385f643cb25734de3756241'
  end

  def self.app_secret
    '9516bcb1322ff4e2c1867137b38838dc'
  end


  def self.cal_sig(params)
    str=""
    params.sort {|k,v| k[0]<=>v[0]}.each do |k,v|
      str += "#{k}=#{v}"
    end
    str += app_secret
    
    MD5.hexdigest(str)
  end

  def self.cal_uri(params,sig)
#    str=""
#    params.sort {|k,v| k[0]<=>v[0]}.each do |k,v|
#      str += "#{k}=#{URI.encode(v.to_s)}&"
#    end
#    str += "mi_sig=#{sig}"
     str=""
     params.sort {|k,v| k[0]<=>v[0]}.each do |k,v|
       str += "#{k}=#{URI.encode(v.to_s)}&"
     end
     str += "mi_sig=#{sig}"
  end
  
  #####add##########
  def self.call_api(extra_params)
     params={
       "api_key"=>app_key,
       "call_id"=>Time.now.to_i,
       "v"=>"1.0"
     }
    
     params.merge!(extra_params)
     uri=cal_uri(params,cal_sig(params))
    
     str="curl -s -X POST -d \"#{uri}\" #{server}"
     %x{#{str}}
  end

  
  
  

  #get_user_info
  #call_api({"method"=>"miop.users.getInfo","ext"=>123})

  # =begin
  #    miop.feed.getList        'uid'=>$uid,'page_size'=>$page_size,'maxid'=>$max_id,'app_ids' => $app_ids,'source' => $source, 获取文本说客内容

  #    miop.italk.getTalks      'uid'=>$uid,'page'=>$page,'page_size'=>$page_size,'maxid'=>$max_id,'source' => $source, 获取所有feeds(彩信--未完善、文本、添加好友等)

  #    miop.italk.send          'text' => $text,'uid' => $uid,  发送说客

  #    miop.connect.getSession  'app_account' => $app_account,  获取绑定用户的SESSION

  #    miop.connect.isRegister  'app_account' =>$app_account,'format'=>'json'     检查是否已经绑定接口

  #    miop.connect.register    'uid'=>$uid,'app_account' =>$app_account,'format'=>'json'  添加绑定接口

  #    miop.connect.unRegister  'app_account'=>$app_account,'format'=>'json'   解除绑定接口

  #    miop.sms.send            'to_id' => $to_id,'content' => $content  发短信

  #    miop.users.getInfo       'uids' => $user_ids, 'fields' => $fields 用户信息
  #    =end

  # call_api({"method"=>"miop.connect.register","app_account"=>"mail07cn@yahoo.com","uid"=>'29490480'})
  #call_api({"method"=>"miop.italk.getTalks"})
  #call_api({"method"=>"miop.italk.send","text"=& gt;"中文"})
  #call_api({"method"=>"miop.connect.getSession", 'app_account' => 'test'})
  #call_api({"method"=>"miop.connect.isRegister",'format'=>'json' ,'app_account' =>'test'})
  #call_api({"method"=>"miop.connect.Register"})
  #call_api({"method"=>"miop.connect.unRegister"})
  #call_api({"method"=>"miop.sms.send","content"=>"test!!!"})
end
