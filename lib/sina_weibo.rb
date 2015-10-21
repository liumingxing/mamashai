module Weibo
  class Base 
    # 验证用户是否已经开通微博服务。 
    # 如果用户的新浪通行证身份验证成功，且用户已经开通微博则返回 http状态为 200，否则返回403错误。
    def verify_credentials (query={})
      perform_get('/account/verify_credentials.json', :query => query)
    end
    
    # 获取API的访问频率限制。返回当前小时内还能访问的次数
    def rate_limit_status (query={})
      perform_get('/account/rate_limit_status.json', :query => query)
    end
  end
  
end
   