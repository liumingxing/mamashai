class Api::AgesController < Api::ApplicationController
	
  # ==获取年龄段列表。
  #   [路径]: ages
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/ages.json
  #   [是否需要登录]： false
  # 
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  #
  # ====示例
  #   curl "http://your.api.domain/ages.json?source=appkey"
  #
  def index
  	ages = Age.all
    render :json=>ages
  end
  
end