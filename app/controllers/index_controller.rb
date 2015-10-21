class IndexController < ApplicationController 
  #caches_page :index
  # before_filter :check_test_domain,:except=>['wait']
  before_filter :get_login_user, :except=>['adv_tongji', 'apk']
  #before_filter :check_block
  layout "main"

  def check_block
    if @user 
      if Blockname.find_by_user_id(@user.id);
        render :text=>"您的账号被锁定，请联系管理员"
        return false;
      end
    end
  end

  def download
    if params.keys.include?("ty")
      TongjiTy.create(:ip=>request.env["HTTP_X_REAL_IP"]||request.env["REMOTE_ADDR"], :agent=>request.env['HTTP_USER_AGENT'], :url=>request.env['REQUEST_URI'][0, 200], :refer=>request.env['HTTP_REFERER'])
    end

    if request.env['HTTP_USER_AGENT'].to_s.downcase.include?('iphone') || request.env['HTTP_USER_AGENT'].to_s.downcase.include?('ipad')
        redirect_to "http://www.mamashai.com/index/ipa"
    elsif request.env['HTTP_USER_AGENT'].to_s.downcase.include?('android')
        redirect_to "http://www.mamashai.com/index/apk"
    else
        redirect_to "http://www.mamashai.com/mobile/bbrl"
    end
  end

  def apk
    #send_file RAILS_ROOT "downloads/babycalendar.apk"
    send_file "#{::Rails.root.to_s}/public/downloads/babycalendar.apk"
  end

  def ipa
    redirect_to "https://itunes.apple.com/cn/app/bao-bao-ri-li-huai-yun-yu/id499828643?ls=1&mt=8"
  end

  def adv_tongji
    id = Base64.decode64(params[:id])
    @tip = CalendarTipAdv.find(id)
    text = `curl 'http://api.flurry.com/eventMetrics/Event?apiAccessCode=NP7JWXVZ1X5LRFVBJ58G&apiKey=ZLLEP9WR3RUHHQ5XKMUY&startDate=#{@tip.created_at.to_date.to_s(:db)}&endDate=#{@tip.status == 'online' ? Time.new.to_date.to_s(:db) : @tip.updated_at.to_date.to_s(:db)}&eventName=zhinan_advertisement_#{@tip.id}'`
    @json = JSON.parse(text)

    sleep(1)
    text = `curl 'http://api.flurry.com/eventMetrics/Event?apiAccessCode=NP7JWXVZ1X5LRFVBJ58G&apiKey=ZLLEP9WR3RUHHQ5XKMUY&startDate=#{@tip.created_at.to_date.to_s(:db)}&endDate=#{@tip.status == 'online' ? Time.new.to_date.to_s(:db) : @tip.updated_at.to_date.to_s(:db)}&eventName=zhinan_advertisement_click_#{@tip.id}'`
    @json_click = JSON.parse(text)

    render :layout=>"mms_admin"
  end

  def ty_tongji
    @tongjis = TongjiTy.paginate :page=>params[:page], :per_page=>40, :order=>"id desc"
    render :layout=>"mms_admin"
  end

  def flurry_tongji
    @advs = CalendarTipAdv.all(:conditions=>["client= ?", params[:id]])
    @advs += CalendarAdv.all(:conditions=>["client= ?", params[:id]])

    @result = {}
    for adv in @advs
      if adv['logo']    #半屏广告
        text = `curl 'http://api.flurry.com/eventMetrics/Event?apiAccessCode=NP7JWXVZ1X5LRFVBJ58G&apiKey=ZLLEP9WR3RUHHQ5XKMUY&startDate=#{adv.created_at.to_date.to_s(:db)}&endDate=#{adv.status == 'online' ? Time.new.to_date.to_s(:db) : adv.updated_at.to_date.to_s(:db)}&eventName=calendar_advertisement_#{adv.id}'`
      else              #指南广告
        text = `curl 'http://api.flurry.com/eventMetrics/Event?apiAccessCode=NP7JWXVZ1X5LRFVBJ58G&apiKey=ZLLEP9WR3RUHHQ5XKMUY&startDate=#{adv.created_at.to_date.to_s(:db)}&endDate=#{adv.status == 'online' ? Time.new.to_date.to_s(:db) : adv.updated_at.to_date.to_s(:db)}&eventName=zhinan_advertisement_#{adv.id}'`    
      end
      json = JSON.parse(text)
      sleep(1)
      if adv['logo']
        text = `curl 'http://api.flurry.com/eventMetrics/Event?apiAccessCode=NP7JWXVZ1X5LRFVBJ58G&apiKey=ZLLEP9WR3RUHHQ5XKMUY&startDate=#{adv.created_at.to_date.to_s(:db)}&endDate=#{adv.status == 'online' ? Time.new.to_date.to_s(:db) : adv.updated_at.to_date.to_s(:db)}&eventName=calendar_advertisement_click_#{adv.id}'`
      else
        text = `curl 'http://api.flurry.com/eventMetrics/Event?apiAccessCode=NP7JWXVZ1X5LRFVBJ58G&apiKey=ZLLEP9WR3RUHHQ5XKMUY&startDate=#{adv.created_at.to_date.to_s(:db)}&endDate=#{adv.status == 'online' ? Time.new.to_date.to_s(:db) : adv.updated_at.to_date.to_s(:db)}&eventName=zhinan_advertisement_click_#{adv.id}'`
      end
      json_click = JSON.parse(text)
      sleep(1)
      
      for day in json["day"]
        click = nil
        for c in json_click['day']
          click = c if c['@date'] == day["@date"]
        end

        if !@result[day['@date']]
          @result[day['@date']] = [click ? click['@totalCount'].to_i : 0, click ? click['@uniqueUsers'].to_i : 0, day['@totalCount'].to_i, day['@uniqueUsers'].to_i]
        else
          @result[day['@date']] = [@result[day['@date']][0] + (click ? click['@totalCount'].to_i : 0), @result[day['@date']][1] + (click ? click['@uniqueUsers'].to_i : 0), @result[day['@date']][2] + day['@totalCount'].to_i, @result[day['@date']][3] + day['@uniqueUsers'].to_i]
        end
      end

    end

    if params[:full]
      render :action=>"flurry_tongji2", :layout=>"mms_admin" and return;
    end
    render :layout=>"mms_admin"
  end
  
  def method_missing(args)
    redirect_to :action=>"index"
  end
  
  def post_from_lama
    require 'uri'

    params[:post] = {}
    params[:post][:content] = URI.decode(params[:content]) if params[:content]
    if params[:email]
      user = User.find_by_email(params[:email])
    elsif params[:uid]
      user = User.find_decrypt_user(params[:uid])
    end
    if !params[:logo]
      if params[:picture]
        file_name = web_file(params[:picture])
        params[:post][:logo] = File.open(file_name, 'r')
        params[:post][:from] = "lama_#{params[:from_url].to_s.size > 0 ? params[:from_url] : 'web'}"
        `rm file_name`
      else
        if params[:lamaid]
          params[:post][:logo] = Lamadiary.find(params[:lamaid]).pic_path
          params[:post][:from] = "lama_#{params[:from_url].to_s.size > 0 ? params[:from_url] : 'web'}"
        end
      end
    else
      params[:post][:logo] = params[:logo]
      params[:post][:from] = "lama_phone"
      params[:post][:from] = params[:from] if params[:from] && params[:from].to_s.size > 0
    end
    
    render :text=>0 and return if !user      
    
    if params[:lamaid]
      params[:post][:from_id] = params[:lamaid]
    else      
      diary = Lamadiary.new
      diary.uid = user.id
      diary.pic_path = params[:post][:logo]
      diary.data = params[:data]
      diary.save
      params[:post][:from_id] = diary.id
    end

    #if %w(vkid vancl).include?(params[:from_url].to_s)
    #  show_url = " http://#{params[:from_url]}.mamashai.com"
    #elsif %w(sntp tongqu).include?(params[:from_url].to_s)
    #  show_url = " http://www.mamashai.com/#{params[:from_url].gsub("sntp", "sunuo")}"
    #elsif %w(tonghua).include?(params[:from_url].to_s)
    #  show_url = " http://www.mamashai.com/#{params[:from_url]}"
    #else
    #  show_url = " http://lama.mamashai.com/main/img/#{params[:post][:from_id]}"
    #end


    @post = Post.create_post(params,user)
    
    if !@post.errors.empty?
      render :text=>0 and return false 
    end    
    
    render :text=>1
  end
  
  def register_from_lama
    if params[:email].to_s == "" || params[:password].to_s == ""
      render :text=>"请输入账号密码"
      return
    end
    
    name = params[:name]
    name = params[:email][0,params[:email].index('@')] if !name
    index = 1
    exist = User.find_by_name(name)
    while exist
      name = name + index.to_s
      exist = User.find_by_name(name)
      index += 1
    end
    
    params[:user_signup] = {}
    params[:user_signup][:email] = params[:email]
    params[:user_signup][:name] = name
    params[:user_signup][:password] = params[:password]
    params[:user_signup][:from] = "辣妈日报Android"
    @user_signup = User.create_user_signup(params,request.env["HTTP_X_REAL_IP"]||request.remote_ip) 
    unless @user_signup.errors.empty?
      errors = []
      @user_signup.errors.each do |attribute, errors_array|
        errors << errors_array
      end
      render :text=>errors.join(";")
    else
      render :text=>"1"
    end
  end
  
  def index
    agent = request.env['HTTP_USER_AGENT'].to_s.downcase
    if agent.include?('iphone') || agent.include?('ipad') || agent.include?("android")
      redirect_to "http://www.mamashai.com/qing" and return;
    end

    http_host = request.env["HTTP_HOST"]

    redirect_to "http://zhenyoufu.taobao.com" and return if http_host.to_s.include?('veryfu.com')

    host = "www"
    host = http_host.split('.')[0] if http_host
    redirect_to "http://www.mamashai.com/index/bang" and return if host == "yuerbang"
    if topic = EbookTopic.find_by_ebook_action(host)
      redirect_to "http://www.mamashai.com/ebook/#{host}"
    end
    
    if host.downcase == 'bca'
    	redirect_to "http://bca.mamashai.com/bafu_form/" and return;
   	end
    
    if host == "lama"
      redirect_to "http://www.mamashai.com/lmrb" and return;
    end
    
    if host == "baobaorili" || host == "bbrl"
      redirect_to "http://www.mamashai.com/bbrl" and return;
    end
    
    @ddhs = Ddh.duihuan.find(:all, :conditions=>"begin_at >= '#{Time.new.at_beginning_of_month().to_s(:db)}' and begin_at <= '#{Time.new.at_end_of_month().to_s(:db)}'", :order=>"begin_at desc", :limit=>2)
    @authors = ColumnAuthor.find(:all,:conditions => "recommend = 1")
  end
  
  def bang
    if @user && !params[:step]
      case @user.age_id
      when 3..5
        params[:step] = '2'
      when 6..7
        params[:step] = '3'
      when 8..12
        params[:step] = '4'
      else
        params[:step] = '1'
      end
    else
      params[:step] ||= '1'
    end
    
    @vars = {"1"=>"孕期", "2"=>"0-3岁", "3"=>"3-6岁", "4"=>"6岁以上"}
    @mms_tools = Mms::Tool.paginate :page=>params[:rp], :per_page=>9, :conditions=>"step_id = #{params[:step]}", :order=>"#{params[:order]||'users_count'} desc"
    
    @books = EbookTopic.find(:all, :conditions=>"step_id like '%#{params[:step]||1}%'", :order=>"id desc")
    the_book = @books[0]
    conditions = ["1=1"]
    conditions << "user_id = #{@user.id}" if @user && params[:from] == 'my'
    conditions << "user_id in (#{@user.follow_user_ids.join(',')})" if @user && params[:from] == "follow"
    if params[:topic].to_s.size > 0
        conditions << "match(content_) against ('#{RMMSeg.segment(params[:topic]).collect{|t| "+" + t}.join(' ')}' in boolean mode)"
    else
        if the_book.age_id.to_s.size > 0
          conditions << "age_id in (#{the_book.age_id})"
        else
          conditions << "match(content_) against ('#{RMMSeg.segment(the_book.topic_filter).collect{|t| "+" + t}.join(' ')}' in boolean mode)"
        end
    end
    params[:page] = 50 if params[:page].to_i > 50
    @posts = Post.not_visit.paginate :page=>params[:page], :total_entries=>500, :per_page=>10, :order=>"created_at desc", :conditions=>conditions.join(" and ")
    if params[:topic].to_s.size > 0
      @tags = RMMSeg.segment(params[:topic])
    end
    
    if @user && @user.age_id && !params[:step]
      @age = @user.age
    else
      age_id = 2
      case params[:step]
      when '2'
        age_id = 3
      when '3'
        age_id = 6
      when '4'
        age_id = 7
      end
      @age = Age.find_by_id(age_id)
    end
    
    if params[:topic]
      @post = Post.new(:content=>"##{params[:topic]}#")
    end
    
    render :layout=>false
  end
  
  def posts
    redirect_to :controller=>"account", :action=>"login" and return if !@user

    @current_uri = request.env["REQUEST_URI"]
    page = params[:page].to_i
    page = 100 if page > 100
    page = 1 if page == 0
    @posts = Post.not_hide.not_visit.not_private.paginate :page=>page, :per_page=>40, :total_entries => 2000, :order=>"id desc" 
  end

  def hot
    redirect_to :controller=>"account", :action=>"login" and return if !@user

    @current_uri = request.env["REQUEST_URI"]
    page = params[:page].to_i
    page = 40 if page > 40
    page = 1 if page == 0
    @posts = Post.not_hide.not_visit.paginate :page=>page, :per_page=>40, :conditions=>"comments_count + forward_posts_count >=4", :total_entries => 2000, :order=>"id desc" 
    render :action=>"posts"
  end
  
  def jh
    redirect_to :controller=>"account", :action=>"login" and return if !@user

    @current_uri = request.env["REQUEST_URI"]
    page = params[:page].to_i
    page = 40 if page > 40
    page = 1 if page == 0
    @posts = Post.not_hide.not_visit.paginate :page=>page, :per_page=>40, :conditions=>"created_at >= '#{Time.new.ago(1.days).beginning_of_day.to_s(:db)}' and comments_count + claps_count + post_rates_count >= 20", :order=>"comments_count+claps_count+post_rates_count desc" 
    render :action=>"posts"
  end

  def rookie
    redirect_to :controller=>"account", :action=>"login" and return if !@user

    page = params[:page].to_i
    page = 100 if page > 100
    page = 1 if page == 0
    @posts = Post.not_hide.not_visit.not_private.paginate :page=>page, :per_page=>params[:per_page] || 25, :total_entries=>2000, :joins=>"left join users on users.id = posts.user_id", :conditions=>"users.mms_level = 1", :order=>"posts.id desc"
    render :action=>"posts"
  end
  
  def find_posts
    redirect_to :controller=>"account", :action=>"login" and return if !@user

    redirect_to :action=>'no_search' and return false if params[:id].blank? || params[:id].to_s.size == 0
    
    @tag = Tag.new(:name=>params[:id])
    
    opt1 = {
          "query" => {
            "filtered"=> {
              "query"=> { "match_phrase"=> {"content"=> URI.decode(params[:id])} },
              "filter"=> {
                "and"=> [
                {
                  "bool"=>{
                       "must"=>[
                         {
                           "term"=>{"is_hide"=> false}
                        },
                        {
                          "term"=>{"is_private"=> false}
                        }]
                    }
                }]
              }
            }
          },
          "sort"=> {"id"=> {"order"=> "desc"}}
    }

    @posts = Post.__elasticsearch__.search(opt1).per_page(25).page(params[:page]).records
    #@posts = Post.search URI.decode(params[:id]), :page=>params[:page], :per_page=>params[:per_page] || 25, :order=>"id desc", :with=>{:is_private=>false, :is_hide=>false}
    @articles = Article.__elasticsearch__.search(URI.decode(params[:id])).per_page(10).page(1).records

    #@tag = Tag.new(:name=>params[:id])
    #@posts = Post.not_hide.not_visit.not_private.paginate(:conditions=>["match(content_) against (? in boolean mode)", RMMSeg.segment(params[:id]).collect{|t| "+" + t}.join(' ')], :page=>params[:page], :per_page=>params[:per_page] || 25, :order=>"created_at desc")
    #@article_contents = ArticleContent.find(:all, :joins=>"left join articles on articles.id = article_contents.article_id", :conditions=>["gou_brand_article_id is null and gou_brand_story_id is null and match(content) against (? in boolean mode)", RMMSeg.segment(params[:id]).collect{|t| t}.join(' ')], :limit=>10)
  end
  
  def find_users
    redirect_to :controller=>"account", :action=>"login" and return if !@user

    @users = User.__elasticsearch__.search("name:#{URI.decode(params[:id])}").per_page(25).page(params[:page]).records
  end
  
  def no_search
    
  end

  def share
  end

  def join
  end

  def contract
  end

  def media
  end

  def biz1
  end

  def biz2
  end

  def biz3
  end

  def biz4
  end

  def map
    render :layout=>false
  end

  def fahuo
    @orders = AOrder.all(:conditions=>"status='待发货'", :order=>"pay_at desc")
    render :layout=>false
  end
end
