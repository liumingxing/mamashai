require 'uri'
class Api::StatusesController < Api::ApplicationController
  # before_filter :authenticate!,
  #   :only => [:friends_timeline, :user_timeline, :unread, :reset_count, :update, :upload, :destroy, :repost, :comment,:comment_destroy, :friends_timeline, :home_timeline]
  before_filter :authenticate!, :except=>[:public_timeline1, :public_timeline, :user_timeline, :location_timeline, :public_timeline_daren, :public_timeline_jh, :public_timeline_hot, :public_timeline_count, :search, :show, :article_category, :articles, :column_categories, :column_authors, :column_books, :column_chapters, :column_chapter, :comments, :lama_stars, :lama_advs, :hot_topic, :the_hot_topic, :lama_posts, :bbrl_version, :gifts, :ddh, :ddh_list, :ddh_list_v2, :ddh_list_v3, :ddh_users, :poi_get_offset_and_address, :poi, :calendar_advs, :half_screen_advs, :calendar_tip_adv, :calendar_tip_adv_list, :calendar_tip_adv_list2, :ddh_visit, :find_users, :find_posts, :find_products, :find_articles, :comments_and_like, :comments_and_like2, :ddh_rules, :ddh_rules2, :about, :version_check, :invite_user, :album_book_count, :tiantian_tejia, :ddh_code, :qinzi, :qinzi_detail, :gou_pinzhi, :get_city_from_gps, :subscribe, :get_bbrl_poi_comments, :tao_ages, :set_silent, :get_silent]

  before_filter :check_block, :only=>%w(update upload repost comment ddh_get send_gift clap)

  def children_day
    obj = ChildrenDay.where(user_id: @user.id).first
    if obj
      render text: 'duplicate'
    else
      obj = ChildrenDay.create(user_id: @user.id)
      code = CommandCode.new
      code.code = %Q!
        if ScoreEvent.find(:first, :conditions=>"user_id = #{@user.id} and event = 'children_day_616'") == nil
          Mms::Score.trigger_event(:children_day_616, "成功分享616任性兑", 50, 1, {:user => User.find(#{@user.id})});
        end
      !
      code.after = Time.now.since(10.minutes)
      code.status = 'wait'
      code.save
      render text: 'ok'
    end
  end

  def bokergen_vote
    obj = BokergenVote.new(name: params[:name].strip, vote_num: params[:vote_num], user_id: params[:user_id])
    if obj.save
      render text: 'ok'
    else
      render text: 'duplicate'
    end
  end

  def check_block
    if Blockname.find_by_user_id(@user.id)
      render :text=>"对不起，操作失败！"
      return false;
    end
  end

  #订阅推送
  def subscribe
    tp = {"com.mamashai.babycalendar"=>1, "com.mamashai.yunfree"=>2, "com.mamashai.yufree"=>3}[params[:app]]
    tp += 3 if params[:os] == "android"
    device = ApnDevice.find_by_device_token_and_tp(params[:token], tp)
    if !device
      device = ApnDevice.new(:device_token=>params[:token], :tp=>tp)
    end
    device.active = true
    if params[:id]
      user = User.find_by_id(params[:id])
      if user
        device.alias = user.email
        device.user_id = user.id
      end
    else
      device.user_id = nil
      device.alias = nil
    end
    device.parse_obj_id = params[:sid] if params[:sid]
    device.save

    render :text=>"ok"
  end
  #caches_page :the_hot_topic
  # ==获取最新的公共微博消息(默认10条)
  #   [路径]: statuses/public_timeline
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/statuses/public_timeline.json
  #   [是否需要登录]： false
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - count 每次返回的记录数, 缺省值为10
  #
  # ====示例
  #   curl -u "username:password"
  #   "http://your.api.domain/statuses/public_timeline.json?source=appkey&count=5"
  #
  def public_timeline
    conditions = ["(long_post_id is null)"]
    conditions << "`from` = '#{params[:from]}'" if params[:from]
    conditions << "from_id is not null" if params[:from] == "video"
    conditions << "`from` like '#{params[:from_like]}'" if params[:from_like]
    conditions << "(`from`='caiyi' or `from`='biaoqing' or `from`='bbyulu' or `from`='shijian') and logo is not null" if params[:tp] == "template"
    conditions << URI.decode(params[:cond]) if params[:cond]
    conditions << URI.decode(params[:cond1]) if params[:cond1]
    
    
    if !params[:tag]
      posts = Post.not_hide.not_visit.not_private.not_taotaole_fav.all(:include=>%w(user post_logos), :limit=>params[:count]||15, :conditions=>conditions.join(' and '), :order=>"id desc")
    else
      key = "gt"
      value = 0
      if params[:cond]
        m = params[:cond].scan(/posts.id ([<>])(\d+)/)
        if m.size == 1 && m[0].size == 2
          if m[0][0] == '>'
            key = "gt"
            value  = m[0][1].to_i
          elsif m[0][0] == '<'
            key = "lt"
            value = m[0][1].to_i
          end
        end
      end
      

      opt1 = {
          "query" => {
            "filtered"=> {
              "query"=> { "match_phrase"=> {"content"=> URI.decode(params[:tag])} },
              "filter"=> {
                "and"=> [{
                  "range"=> {
                    "id"=> {
                      key=> value
                    }
                  }
                },
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

      response = Post.__elasticsearch__.search(opt1).per_page(params[:count]||15).page(1)
      ids = response.results.map{|r| r.id}
      ids << -1
      posts = Post.all(:conditions=>"id in (#{ids.join(',')})", :order=>"id desc", :include=>%w(user post_logos))
      render :json=>posts
      return


      options = {:limit=>params[:count]||15, :order=>"id desc", :with=>{:is_private=>false, :is_hide=>false}}
      if params[:cond]
        m = params[:cond].scan(/posts.id ([<>])(\d+)/)
        if m.size == 1 && m[0].size == 2
          if m[0][0] == '>'
            options[:with][:sphinx_internal_id] = (m[0][1].to_i + 1)..100000000000
          elsif m[0][0] == '<'
            options[:with][:sphinx_internal_id] = 0..(m[0][1].to_i - 1)
          end
        end
      end
      posts = Post.search URI.decode(params[:tag]), options
    end
    #  params[:per_page] ||= 30
    #  params[:total_entries] = params[:per_page]
    #  posts = Post.find_tag_posts(URI.decode(params[:tag]), params)


    #end
    
    render :text=>"null" and return if posts.size == 0
    render :json=>posts
  end

  #同城
  #可传入参数,3选1 1:user_id, 2:province_id, 3:city_id
  def location_timeline
    key = "gt"
    value = 0
    if params[:cond]
        m = params[:cond].scan(/posts.id ([<>])(\d+)/)
        if m.size == 1 && m[0].size == 2
          if m[0][0] == '>'
            key = "gt"
            value  = m[0][1].to_i
          elsif m[0][0] == '<'
            key = "lt"
            value = m[0][1].to_i
          end
        end
    end
    opt1 = {
          "query" => {
            "filtered"=> {
              "filter"=> {
                "and"=> [{
                  "range"=> {
                    "id"=> {
                      key=> value
                    }
                  }
                },
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

    if params[:user_id]     #传入了用户，同省，同市
      user = User.find(params[:user_id])
      if !user.province_id && !user.city_id        #没填省，没填市
        render :text=>"null" and return
      end
      
      if user.province_id
        opt1["query"]["filtered"]["filter"]["and"][1]["bool"]["must"] << {"term"=>{"province_id"=>user.province_id}}
      end

      if user.city_id
        opt1["query"]["filtered"]["filter"]["and"][1]["bool"]["must"] << {"term"=>{"city_id"=>user.city_id}}
      end  
    else
      if !params[:province_id] && !params[:city_id]       #没有传入省和市的信息
        render :text=>"null" and return
      end
      
      if params[:province_id]
        opt1["query"]["filtered"]["filter"]["and"][1]["bool"]["must"] << {"term"=>{"province_id"=>params[:province_id]}}
      end

      if params[:city_id]
        opt1["query"]["filtered"]["filter"]["and"][1]["bool"]["must"] << {"term"=>{"city_id"=>params[:city_id]}}
      end
    end
    
    response = Post.__elasticsearch__.search(opt1).per_page(params[:count]||15).page(1)
    ids = response.results.map{|r| r.id}
    ids << -1
    posts = Post.all(:conditions=>"id in (#{ids.join(',')})", :order=>"id desc", :include=>%w(user post_logos))
    render :json=>posts
      
    return

    #conditions = ["posts.created_at > '#{Time.new.ago(100.days).to_s(:db)}'"]
    #conditions << URI.decode(params[:cond]) if params[:cond]
    #conditions << URI.decode(params[:cond1]) if params[:cond1]

    #user_conditions = ["1=1"]
    #if params[:user_id]     #同省，同市，如果是直辖市则同区
    #  user = User.find(params[:user_id])
    #  if !user.province_id && !user.city_id        #没填省，没填市
    #    render :text=>"null" and return
    #  elsif user.province_id && !user.city_id      #填了省，没填市
    #    user_conditions << "users.province_id = #{user.province_id}"
    #  else                                         #填了市
    #    user_conditions << "users.city_id = #{user.city_id}"
    #  end
    #elsif params[:province_id]
    #  user_conditions << "users.province_id = #{params[:province_id]}"
    #elsif params[:city_id]
    #  user_conditions << "users.city_id = #{params[:city_id]}"
    #end
    #users = User.all(:conditions=>user_conditions.join(" and "), :order=>"users.last_login_at + users.posts_count*1000000 desc", :limit=>20)
    #ids = users.collect{|u| u.id}<<0
    #conditions << "posts.user_id in (#{ids.join(',')})"

    options = {:limit=>params[:count]||15, :order=>"id desc", :with=>{:is_private=>false, :is_hide=>false}}
    if params[:cond]
        m = params[:cond].scan(/posts.id ([<>])(\d+)/)
        if m.size == 1 && m[0].size == 2
          if m[0][0] == '>'
            options[:with][:sphinx_internal_id] = (m[0][1].to_i + 1)..100000000000
          elsif m[0][0] == '<'
            options[:with][:sphinx_internal_id] = 0..(m[0][1].to_i - 1)
          end
        end
    end

    if params[:user_id]     #传入了用户，同省，同市
      user = User.find(params[:user_id])
      if !user.province_id && !user.city_id        #没填省，没填市
        render :text=>"null" and return
      end
      options[:with][:province_id] = user.province_id if user.province_id   #填了省
      options[:with][:city_id] = user.city_id if user.city_id               #填了市
    else
      if !params[:province_id] && !params[:city_id]       #没有传入省和市的信息
        render :text=>"null" and return
      end
      options[:with][:province_id] = params[:province_id] if params[:province_id]   #填了省
      options[:with][:city_id] = params[:city_id] if params[:city_id]   #填了市
    end

    posts = Post.search "", options
    render :text=>"null" and return if posts.size == 0
    render :json=>posts
  end

  def public_timeline_daren
    user_ids = BbrlVip.all.collect{|v| v.user_id} + ColumnAuthor.all.collect{|v| v.user_id}
    conditions = ["posts.user_id in (#{user_ids.join(',')})"]
    conditions << params[:cond] if params[:cond]
    conditions << params[:cond1] if params[:cond1]
    posts = Post.not_hide.not_visit.not_private.all(:limit=>params[:count]||15, :conditions=>conditions.join(' and '), :order=>"id desc")
    
    render :json=>posts
  end

  def public_timeline_jh
    conditions = ["comments_count + forward_posts_count > 3"]
    conditions << params[:cond] if params[:cond]
    conditions << params[:cond1] if params[:cond1]
    posts = Post.not_hide.not_visit.not_private.all(:limit=>params[:count]||15, :conditions=>conditions.join(' and '), :order=>"id desc")
    
    render :text=>"null" and return if posts.size == 0
    render :json=>posts
  end

  def public_timeline_rookie
    conditions = ["(users.mms_level = 1)"]
    conditions << params[:cond] if params[:cond]
    conditions << params[:cond1] if params[:cond1]
    posts = Post.not_hide.not_visit.not_private.all :limit=>params[:count]||15, :conditions=>conditions.join(' and '), :joins=>"left join users on users.id = posts.user_id",  :order=>"posts.id desc"
    render :text=>"null" and return if posts.size == 0
    render :json=>posts
  end

  def public_timeline_hot
    render :json => Rails.cache.fetch("public_timeline_hot_#{params[:page]}_#{params[:count]}", :expires_in=>10.minutes){
      page = (params[:page]||1).to_i
      per_page = (params[:count] || 15).to_i

      block_ids = Blockname.all.collect{|b| b.user_id}
      block_ids += Blockpublic.all.collect{|b| b.user_id}
      block_ids += Blockstar.all.collect{|b| b.user_id}

      posts = Post.not_hide.not_visit.all :limit=>per_page, :offset=>(page - 1) * per_page, :conditions=>"user_id not in (#{block_ids.join(',')}) and created_at >= '#{Time.new.ago(1.days).beginning_of_day.to_s(:db)}' and comments_count + claps_count + post_rates_count >= 20", :order=>"comments_count+claps_count+post_rates_count desc" 
      posts.as_json
    }

    return

    if HotPost.count == 0
      posts = Post.not_hide.not_visit.all :conditions=>"created_at >= '#{Time.new.ago(1.days).beginning_of_day.to_s(:db)}' and comments_count + claps_count + post_rates_count >= 20", :order=>"comments_count+claps_count+post_rates_count desc" 
      block_ids = Blockname.all.collect{|b| b.user_id}
      block_ids += Blockpublic.all.collect{|b| b.user_id}
      block_ids += Blockstar.all.collect{|b| b.user_id}
      for post in posts
        next if block_ids.include?(post.user_id)
        hot = HotPost.new
        hot.post_id = post.id
        hot.save rescue nil
      end
    end

    page = (params[:page]||1).to_i
    per_page = (params[:count] || 15).to_i
    hots = HotPost.all :limit=>per_page, :offset=>(page - 1) * per_page, :order=>"id"
    ids = hots.map{|h| h.post_id}.join(",")
    posts = Post.all :conditions=>"id in (#{ids})", :order=>"find_in_set(id, '#{ids}')"
    
    #page = (params[:page]||1).to_i
    #per_page = (params[:count] || 15).to_i

    #posts = Post.not_hide.not_visit.all :limit=>per_page, :offset=>(page - 1) * per_page, :conditions=>"created_at >= '#{Time.new.ago(1.days).beginning_of_day.to_s(:db)}' and comments_count + claps_count + post_rates_count >= 20", :order=>"comments_count+claps_count+post_rates_count desc" 
    
    ##posts = Post.not_hide.not_visit.paginate :page=>params[:page], :per_page=>params[:count]||15, :conditions=>"created_at >= '#{Time.new.ago(1.days).beginning_of_day.to_s(:db)}' and comments_count + claps_count + post_rates_count >= 20", :order=>"comments_count+claps_count+post_rates_count desc" 
    
    render :text=>"null" and return if posts.size == 0
    render :json=>posts
  end
  
  def public_timeline1
    conditions = ["1=1"]
    conditions << params[:cond] if params[:cond]
    conditions << params[:cond1] if params[:cond1]
    if !params[:tag]
      posts = Post.not_hide_pure.not_visit.not_private.paginate(:page=>params[:page], :per_page=>params[:count]||15, :conditions=>conditions.join(' and '), :order=>"id desc")
    else
      posts = Post.find_tag_posts(params[:tag], params)
    end
    
    render :text=>"null" and return if posts.size == 0
    render :json=>posts
  end
  
  def public_timeline_count
    conditions = ["1=1"]
    conditions << params[:cond] if params[:cond]
    conditions << params[:cond1] if params[:cond1]
    
    conditions<< "posts.kid_id = #{params[:kid_id]}" if params[:kid_id]

    count = Post.not_hide.not_visit.not_private.count(:conditions=>conditions.join(' and '))
    render :text => count
  end

  # ==获取当前登录用户及其所关注用户的最新微博消息 (别名: statuses/home_timeline)
  #   [路径]:statuses/friends_timeline
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/statuses/friends_timeline.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - count  指定每页返回的记录条数。默认值10
  # - page  页码,默认是1。
  # - post_tp  微博类型，空为全部，original原创，groups群组, picture图片，video视频，blog博客. 返回指定类型的微博信息内容。
  # - post_age_id 年龄段, 1:没有孩子, 2:孕期, 3:0-1岁, 4:1-2岁, 5:2-3岁, 6:3-5岁, 7:5-7岁, 8:7-9岁, 9:9-12岁, 10:12-15岁, 11:15-18岁, 12:18岁以上
  #
  # ====示例
  #   curl -u "username:password"
  #   "http://your.api.domain/statuses/friends_timeline.json?source=appkey&count=20&page=1"
  #
  def friends_timeline
    if @user.follow_user_ids.size == 0
      render :text=>"null" and return
    end


    key = "gt"
    value = 0
    if params[:cond]
        m = params[:cond].scan(/posts.id ([<>])(\d+)/)
        if m.size == 1 && m[0].size == 2
          if m[0][0] == '>'
            key = "gt"
            value  = m[0][1].to_i
          elsif m[0][0] == '<'
            key = "lt"
            value = m[0][1].to_i
          end
        end
    end
    opt1 = {
          "query" => {
            "filtered"=> {
              "filter"=> {
                "and"=> [{
                  "range"=> {
                    "id"=> {
                      key=> value
                    }
                  }
                },
                {
                  "bool"=>{
                       "must"=>[
                         {"terms" =>{ "user_id" => @user.follow_user_ids << -1}},
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

    response = Post.__elasticsearch__.search(opt1).per_page(params[:count]||30).page(1)
    ids = response.results.map{|r| r.id}
    ids << -1
    posts = Post.all(:conditions=>"id in (#{ids.join(',')})", :order=>"id desc", :include=>%w(user post_logos))
    render :json=>posts
    return




    if @user.follow_user_ids.size == 0
      render :text=>"null" and return
    end
    conditions = ["posts.user_id in (#{@user.follow_user_ids.join(",")})"]
    conditions << params[:cond] if params[:cond]
    conditions << params[:cond1] if params[:cond1]
    count = params[:count].to_i
    count = 30 if count == 0
    posts = Post.all(:conditions=>conditions.join(" and "), :include=>%w(user post_logos), :limit=>count, :order=>"posts.id desc")
    render :text=>"null" and return if posts.size == 0
    render :json=>posts  and return
  end

  alias :home_timeline :friends_timeline
  
  #获得孩子相同年龄段的微博
  def sameage_timeline
    conditions = ["posts.age_id='#{@user.age_id}' and posts.user_id <> #{@user.id}"]
    conditions << params[:cond] if params[:cond]
    conditions << params[:cond1] if params[:cond1]
    posts = Post.not_hide.not_visit.not_private.all(:limit=>params[:count]||15, :conditions=>conditions.join(' and '), :order=>"posts.id desc")
    
    render :text=>"null" and return if posts.size == 0
    render :json=>posts
  end

  #获得同月孩子的记录
  def samemonth_timeline
    key = "gt"
      value = 0
      if params[:cond]
        m = params[:cond].scan(/posts.id ([<>])(\d+)/)
        if m.size == 1 && m[0].size == 2
          if m[0][0] == '>'
            key = "gt"
            value  = m[0][1].to_i
          elsif m[0][0] == '<'
            key = "lt"
            value = m[0][1].to_i
          end
        end
      end
      
      opt1 = {
          "query" => {
            "filtered"=> {
              "filter"=> {
                "and"=> [{
                  "range"=> {
                    "id"=> {
                      key=> value
                    }
                  }
                },
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

      if params[:kid_id]     #传入了月份
        kid = UserKid.find_by_id(params[:kid_id])
        render :text=>"null" and return if !kid
        
        opt1["query"]["filtered"]["filter"]["and"][1]["bool"]["must"] << {"term"=>{"kid_month"=>kid.month}}
      else                  #没传入月份，用第一个孩子的月份
        kid = @user.first_kid
        render :text=>"null" and return if !kid

        opt1["query"]["filtered"]["filter"]["and"][1]["bool"]["must"] << {"term"=>{"kid_month"=>kid.month}}
      end

      response = Post.__elasticsearch__.search(opt1).per_page(params[:count]||30).page(1)
      ids = response.results.map{|r| r.id}
      ids << -1
      posts = Post.all(:conditions=>"id in (#{ids.join(',')})", :order=>"id desc", :include=>%w(user post_logos))
      render :json=>posts
      return



    if params[:kid_id]     #传入了月份
      kid = UserKid.find_by_id(params[:kid_id])
      render :text=>"null" and return if !kid
      
      month = kid.month
    else                  #没传入月份，用第一个孩子的月份
      kid = @user.first_kid
      render :text=>"null" and return if !kid

      month = kid.month
    end

    conditions = ["kid_month = #{month}"]
    conditions << params[:cond] if params[:cond]
    conditions << params[:cond1] if params[:cond1]
    posts = Post.not_hide.not_visit.not_private.all(:limit=>params[:count]||30, :conditions=>conditions.join(' and '), :order=>"posts.id desc", :include=>%w(user post_logos))

    render :text=>"null" and return if posts.size == 0
    render :json=>posts
    return

    #conditions = ["1=1"]
    #conditions << params[:cond] if params[:cond]
    #conditions << params[:cond1] if params[:cond1]

    #if params[:kid_id] 
    #  kid = UserKid.find_by_id(params[:kid_id])
    #else
    #  kid = @user.first_kid
    #end

    #render :text=>"null" and return if !kid
    #conditions<<"user_kids.month = #{kid.month}"
    
    #count = params[:count].to_i
    #count = 30 if count == 0
    #posts = Post.all(:conditions=>conditions.join(' and '), :joins=>"left join user_kids on user_kids.user_id = posts.user_id", :include=>["user", "post_logos"], :order=>"posts.id desc", :limit=>count)
    #render :text=>"null" and return if posts.size == 0
    #render :json=>posts and return


    options = {:limit=>params[:count]||15, :order=>"id desc", :with=>{:is_private=>false, :is_hide=>false}}
    if params[:cond]
        m = params[:cond].scan(/posts.id ([<>])(\d+)/)
        if m.size == 1 && m[0].size == 2
          if m[0][0] == '>'
            options[:with][:sphinx_internal_id] = (m[0][1].to_i + 1)..100000000000
          elsif m[0][0] == '<'
            options[:with][:sphinx_internal_id] = 0..(m[0][1].to_i - 1)
          end
        end
    end

    if params[:kid_id]     #传入了月份
      kid = UserKid.find_by_id(params[:kid_id])
      render :text=>"null" and return if !kid
      
      options[:with][:month] = kid.month
    else                  #没传入月份，用第一个孩子的月份
      kid = @user.first_kid
      render :text=>"null" and return if !kid

      options[:with][:month] = kid.month
    end

    posts = Post.search "", options
    render :text=>"null" and return if posts.size == 0
    render :json=>posts
  end

  #获得孩子相同星座的微博
  def samestar_timeline
    conditions = ["1=1"]
    conditions << params[:cond] if params[:cond]
    conditions << params[:cond1] if params[:cond1]
    
    if @user.first_kid
      conditions << "user_kids.star = #{@user.first_kid.star}"
      conditions << "users.user_kids_count = 1"
      conditions << "users.id <> #{@user.id}"
      posts = Post.not_hide.not_visit.not_private.all(:limit=>params[:count]||15, 
        :joins=>"left join users on users.id = posts.user_id left join user_kids on user_kids.user_id = users.id",
        :conditions=>conditions.join(' and '),
        :order=>"posts.id desc")
    else
      posts = Post.not_hide.not_visit.not_private.all(:limit=>params[:count]||15, :conditions=>conditions.join(' and '), :order=>"id desc")
    end

    render :text=>"null" and return if posts.size == 0
    render :json=>posts
  end

  # ==获取当前登录用户发布的微博消息列表
  #   [路径]:statuses/user_timeline
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/statuses/user_timeline.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - :id  根据用户ID返回指定用户的最新微博消息列表, 如果:id未指定, 则返回当前登录用户最近发表的微博消息列表。
  # - count  指定每页返回的记录条数。默认值10
  # - page  页码,默认是1。
  # - post_tp  微博类型，空为全部，original原创，groups群组, picture图片，video视频，blog博客. 返回指定类型的微博信息内容。
  # - post_age_id 年龄段, 1:没有孩子, 2:孕期, 3:0-1岁, 4:1-2岁, 5:2-3岁, 6:3-5岁, 7:5-7岁, 8:7-9岁, 9:9-12岁, 10:12-15岁, 11:15-18岁, 12:18岁以上
  #
  # ====示例
  #   curl -u "username:password"
  #   "http://your.api.domain/statuses/user_timeline.json?source=appkey&count=20"
  # ====注意
  #   :id为指定的用户ID，使用url为：
  #   http://your.api.domain/statuses/user_timeline/:id.json
  #   如果不指定id，则返回当前登录用户最近发表的微博消息列表,url为:
  #   http://your.api.domain/statuses/user_timeline.json
  #
  def user_timeline_old
    params[:per_page] = params[:count]||10
    params[:user] = @user
    user = User.find(params[:id]) rescue @user
    posts = Post.find_my_posts(user,params)
    if params[:no_user_json]
      posts.each{|post|
        post.no_user_json = true
      }
    end

    render :text=>"null" and return if posts.size == 0
    render :json=>posts
  end

  # 用于获取用户发过的posts，可以传参筛选。
  def user_timeline
    params[:per_page] = params[:count]||10
    if params[:id]
      user = User.find(params[:id])
      if params[:username]            #可以匿名看
        authenticate!
        params[:user] = @user
      end
    else
      authenticate!
      params[:user] = @user
      user = @user
    end
    
    posts = Post.find_my_posts(user,params)
    if params[:no_user_json]
      posts.each{|post|
        post.no_user_json = true
      }
    end

    render :text=>"null" and return if posts.size == 0
    render :json=>posts
  end

  #获得当前用户的消息，包括别人的评论、点赞、转发、送礼物
  def user_reminds
    cond = ["user_id = #{@user.id}"]
    cond << params[:cond] if params[:cond]
    reminds = CommentAtRemind.all(:conditions=>cond.join(' and '), :order=>"id desc", :limit=>30)

    reminds.delete_if{|r| r.tp == 'comment' && (!r.comment || !r.comment.post)}

    @user.unread_comments_count = 0
    @user.unread_atme_count = 0
    @user.unread_gifts_count = 0
    @user.unread_fans_count = 0
    @user.unread_claps_count = 0
    @user.save(:validate=>false)


    render :json=>reminds
  end

  #获得当前用户的收藏，包括记录和宝典
  def user_favourites
    cond = ["user_id = #{@user.id}"]
    cond << params[:cond] if params[:cond]
    favourites = Favourite.all(:conditions=>cond.join(' and '), :order=>"id desc", :limit=>30)

    render :json=>favourites
  end

  #根据时段返回用户在这个区段内的记录，如果少于5条，则用主动提示充数
  def user_album_book_timeline
    params[:cond] += " and posts.created_at >= '#{params[:from_day]}' "
    params[:cond] += " and posts.created_at <= '#{params[:to_day]}' "
    params[:per_page] = params[:count]||10
    user = User.find(params[:id]) rescue @user
    posts = Post.find_my_posts(user,params)

    #多余100条，则过滤有图片的记录
    if posts.size > 100
      params[:cond] += " and posts.logo is not null "
      posts = Post.find_my_posts(user,params)
    end

    if params[:no_user_json]
      posts.each{|post|
        post.no_user_json = true
      }
    end
    if posts.size > 5               #多于5条
      render :json=>posts
    else                            #少于5条，塞入自动提示
      from = Time.parse(params[:from_day])
      to   = Time.parse(params[:to_day])
      kid  = UserKid.find_by_id(params[:kid_id])
      kid  = user.user_kids.first if !params[:kid_id] || !kid
      birthday = Time.parse(kid.birthday.to_s)

      from_week = MamashaiTools::ToolUtil.calc_distance(kid.birthday, from.to_date)
      to_week = MamashaiTools::ToolUtil.calc_distance(kid.birthday, to.to_date)

      if birthday - from > 2.days         #孕期
        tips = CalEnd::Tip.find(:all, :conditions=>"title is not null and t='闪光时刻' and distance >= #{from_week} and distance <= #{to_week}")
      elsif to - birthday > 360.days    #1岁以上
        tips = CalEnd::Tip.find(:all, :conditions=>"title is not null and (t='闪光时刻' or t='宝宝发育') and distance >= #{from_week} and distance <= #{to_week}")
      else                                    #出生至一岁
        tips = CalEnd::Tip.find(:all, :conditions=>"title is not null and (t='闪光时刻' or t='宝宝发育' or t='养育贴士' or t='成长早教') and distance >= #{from_week} and distance <= #{to_week}")
      end
      posts = [] if tips.size > 0
      tips.each_with_index{|tip, index|
        post = Post.new
        post.id = index
        post.content = tip.title
        post.user_id = user.id
        if birthday - from > 2.days     #孕期
          post.created_at = birthday + tip.distance.weeks
        else
          post.created_at = birthday + (tip.distance/4).months + (tip.distance%4).weeks
        end
        posts << post
      }
      render :json=>posts.reverse
    end
  end
  
  #返回用户哪些日期是有记录的
  def user_dot_dates
    posts = Post.not_hide.find(:all, :select=>"created_at, user_id", :conditions=>"user_id = #{params[:id] || @user.id}", :limit=>10000)
    str = posts.collect{|p| p.created_at.strftime("%Y-%m-%d") }.uniq.join(',')
    render :json=>{:dates=>str}.to_json
  end
  
  #获取用户喜欢的
  def user_claps
    claps = Clap.find(:all, :conditions=>"user_id=#{params[:id] || @user.id} and tp = 'post'")
    clap_ids = claps.collect{|c| c.tp_id}
    clap_ids << -1
    
    conditions = ["posts.is_hide <> 1"]
    conditions << "posts.id in (#{clap_ids.join(',')})"
    conditions << "posts.`from` like '#{params[:from]}'" if params[:from]
    conditions << params[:cond] if params[:cond]
    
    posts = Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>conditions.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc", :total_entries=>1000)
    render :json=>posts
  end

  #获取用户喜欢的宝典
  def user_clap_articles
    conditions = [] << "claps.tp = 'article' and claps.user_id = #{@user.id}"
    conditions << params[:cond] if params[:cond]
    articles = Article.find(:all, :select=>"articles.*", :joins=>"left join claps on articles.id = claps.tp_id", :conditions=>conditions.join(" and "), :order=>"articles.id desc", :group=>"articles.id")
    render :json=>articles
  end

  # ==获取当前用户未读消息数
  #   [路径]:statuses/unread
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/statuses/unread.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  #
  # ====示例
  #   curl -u "username:password"
  #   "http://your.api.domain/statuses/unread.json?source=appkey"
  # ====注意
  #   获取当前用户Web主站未读消息数，包括：
  # - 是否有新微博消息(todo)
  # - 最新提到“我”的微博消息数, 对应字段: mentions
  # - 新评论数, 对应字段: comments
  # - 新私信数, 对应字段: dm
  # - 新粉丝数, 对应字段: followers
  #   此接口对应的清零接口为 statuses/reset_count
  def unread
    attrs = {
      :mentions => @user.unread_atme_count,
      :comments => @user.unread_comments_count,
      :dm => @user.unread_messages_count,
      :followers => @user.unread_fans_count,
      :gifts => @user.unread_gifts_count,
      :claps => @user.unread_claps_count
    }
    arr = request.env['HTTP_USER_AGENT'].scan(/\(([\w\W]+);([\w\W]+);([\w\W]+);/)
    if arr.length == 1
      if arr[0][1].include?('iPhone')
        UserInfo.set_info(@user.id, {:mobile=>arr[0][0]})
      else
        manu = arr[0][0]
        version = arr[0][1]
        version.scan(/\d+/)
        UserInfo.set_info(@user.id, {:mobile=>manu + "/" + $&})
      end
    end

    if params[:sid] && @user.sid != params[:sid]
      UserInfo.set_info(@user.id, {:sid=>params[:sid]})
    end
    render :json => attrs
  end

  # ==未读消息数清零接口
  #   [路径]:statuses/reset_count
  #   [HTTP请求方式]: POST
  #   [URL]: http://your.api.domain/statuses/reset_count.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - type 清零的计数类别有：1. 评论数comments，2. @me数mentions，3. 私信数dm，4. 关注数followers，tp为空，则全部清零
  #
  # ====示例
  #   curl -u "username:password" -d "type=1"
  #   "http://your.api.domain/statuses/reset_count.json?source=appkey"
  # ====注意
  #  将当前登录用户的某种新消息的未读数为0。可以清零的计数类别有：1. 评论数comments，2. @me数mentions，3. 私信数dm，4. 关注数followers
  #  如果tp为空，则全部清零
  #  如果清零成功返回 ok，失败返回 error
  def reset_count
    # 1. 评论数，2. @me数，3. 私信数，4. 关注数
    attrs = {
      1 => :unread_comments_count,
      2 => :unread_atme_count,
      3 => :unread_messages_count,
      4 => :unread_fans_count
    }
    attr = attrs[params[:type].try(:to_i)]
    result = false
    if attr.blank?
    result = @user.update_attributes(:unread_comments_count=>0, :unread_atme_count=>0, :unread_messages_count=>0, :unread_fans_count=>0)
    else
      result = MamashaiTools::ToolUtil.clear_unread_infos(@user,attr)
    end
    render :text => result ? "ok" : "error"
  end

  # ==根据ID获取单条微博消息，以及该微博消息的作者信息
  #   [路径]:statuses/show/:id
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/statuses/show/:id.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - :id  要获取的微博消息ID，该参数为REST风格的参数
  #
  # ====示例
  #   curl -u "username:password" -d 'status=abc'
  #   "http://your.api.domain/statuses/update.json?source=appkey"
  # ====注意
  # - 如果:id参数输入一个不存在的微博ID，则返回null
  def show
    post = Post.find(params[:id])
    render :json=>post
  end

  # ==发布一条微博信息
  #   [路径]:statuses/update
  #   [HTTP请求方式]: POST
  #   [URL]: http://your.api.domain/statuses/update.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - status 要发布的微博消息文本内容
  #
  # ====示例
  #   curl -u "username:password" -d 'status=abc'
  #   "http://your.api.domain/statuses/update.json?source=appkey"
  #

  def update
    sid = @user.sid
    sid = UserInfo.find_by_user_id(@user.id).try(:sid) if !sid
    if sid.to_s.size > 6
      if Blacksid.first(:conditions=>"sid='#{sid}'")
        render :text=>"恶意骚扰用户请离开本社区" and return
      end
    end

    attr = {:post=>{:content=>URI::decode(params[:status]), :from=>params[:from], :from_id=>params[:from_id], :score=>params[:score], :created_at=>params[:created_at]}}
    attr[:post][:is_private] = 1 if params[:is_private] == "1" || params[:is_private] == "true"
    attr[:post][:sina_weibo_id] = params[:sina_weibo_id] if params[:sina_weibo_id] && params[:sina_weibo_id].to_i != 0
    attr[:post][:tencent_weibo_id] = params[:tencent_weibo_id] if params[:tencent_weibo_id] && params[:tencent_weibo_id].to_i != 0
    attr[:post][:qzone_id] = params[:qzone_id] if params[:qzone_id] && params[:qzone_id].to_i != 0
    attr[:post][:kid_id] = params[:kid_id] if params[:kid_id]

    attr[:poi] = {:lon => params[:longitude], :lat=>params[:latitude], :title=>params[:location_title] }

    post = Post.create_post(attr,@user)
    
    if params[:latitude] && params[:longitude]
      location = PostLocation.create(:post_id=>post.id, :latitude=>params[:latitude], :longitude=>params[:longitude], :title=>params[:location_title])
    end
    
    render :text=>'error' and return if post.errors.present?
    render :json=>post
  end

  # ==上传图片并发布一条微博信息
  #   [路径]:statuses/upload
  #   [HTTP请求方式]: POST
  #   [URL]: http://your.api.domain/statuses/upload.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - status 要发布的微博消息文本内容
  # - pic 要上传的图片。仅支持JPEG,GIF,PNG图片,为空返回400错误。目前上传图片大小限制为<5M。
  #
  # ====示例
  #   curl -u "username:password" -F "pic=@1.png" -d "status=分享图片"
  #   "http://your.api.domain/statuses/upload.json?source=appkey"
  #
  def upload
    sid = @user.sid
    sid = UserInfo.find_by_user_id(@user.id).try(:sid) if !sid
    if sid.to_s.size > 6
      if Blacksid.first(:conditions=>"sid='#{sid}'")
        render :text=>"恶意骚扰用户请离开本社区" and return
      end
    end

    if params[:video]     #上传了视频
      video = Video.new
      video.path = params[:video]
      video.user_id = @user.id
      video.save
      video.reload()
      
      image_path = "#{::Rails.root.to_s}/tmp/#{Time.new.to_i}_#{rand(10000)}.jpg"
      `ffmpeg -i #{video.path.path} #{image_path} -r 1 -vframes 1 -an -vcodec mjpeg`
      params[:from] = 'video'
      params[:from_id] = video.id
      params[:pic] = File.open(image_path)
    end  

    attr = {:post=>{:content=>URI::decode(params[:status]||"图片"), :logo=>params[:pic]||params[:pic0], :from=>params[:from], :from_id=>params[:from_id], :created_at=>params[:created_at]}}
    attr[:post][:is_private] = 1 if params[:is_private] == "1" || params[:is_private] == "true"
    attr[:post][:sina_weibo_id] = params[:sina_weibo_id] if params[:sina_weibo_id] && params[:sina_weibo_id].to_i != 0
    attr[:post][:tencent_weibo_id] = params[:tencent_weibo_id] if params[:tencent_weibo_id] && params[:tencent_weibo_id].to_i != 0
    attr[:post][:qzone_id] = params[:qzone_id] if params[:qzone_id] && params[:qzone_id].to_i != 0
    attr[:poi] = {:lon => params[:longitude], :lat=>params[:latitude], :title=>params[:location_title] }
    attr[:post][:logo] = nil if params[:pic] == "images/video@2x.png"
    attr[:post][:kid_id] = params[:kid_id] if params[:kid_id]
    attr[:post][:extra1] = params[:extra1]
    post = Post.create_post(attr,@user)
    
    #检查多图(至少上传了2张图)
    if post && post.id && params["pic1"]
      0.upto(8) do |i|
        break if !params["pic#{i}"]
        PostLogo.create(:post_id=>post.id, :user_id=>@user.id, :logo=>params["pic#{i}"])
      end
    end

    if params[:latitude] && params[:longitude]
      location = PostLocation.create(:post_id=>post.id, :latitude=>params[:latitude], :longitude=>params[:longitude], :title=>params[:location_title])
    end
    
    render :text=>"error" and return if post.errors.present?
    render :json=>post
  end

  # ==删除一条微博信息
  #   [路径]:statuses/destroy/:id
  #   [HTTP请求方式]: DELETE/POST
  #   [URL]: http://your.api.domain/statuses/destroy/:id.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - :id  要删除的微博消息ID
  #
  # ====示例
  #   curl -u "username:password" -X DELETE
  #   "http://your.api.domain/statuses/destroy/11011.json?source=appkey"
  #
  # ====注意
  # - 如果id不存在或者id对应的微博不存在，将返回404错误
  def destroy
    post = Post.find(params[:id])

    if post.logo
      post.user.add_level_score(-10, "删除记录")
    end
    #if post.logo
    #  Mms::Score.trigger_event(:self_delete_post, "退还晒豆", -1, 1, {:user => post.user})
    #end
    
    render :text=> Post.delete_post(params[:id],@user)||'ok'


  end

  # ==转发一条微博消息(转晒)
  #
  #   [路径]：statuses/repost
  #   [HTTP请求方式]: POST
  #   [URL]: http://your.api.domain/statuses/repost.json
  #   [是否需要登录]: true
  #
  # ====参数:
  # - source:  申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。 (必选)
  # - :id:   要转发的微博ID (必选)
  # - status:  添加的转发文本。必须做URLEncode,信息内容不超过140个汉字。如不填则默认为“转发微博”。(必选)
  # - is_comment:  是否在转发的同时发表评论。1表示发表评论，0表示不发表。默认为0。 (todo)
  #
  # ====示例
  #
  #   curl -u "username:password" -d "id=111904&status=test repost"
  #   "http://your.api.domain/statuses/repost.json?source=appkey"
  #
  # ====注意
  # - 请求必须用POST方式提交

  def repost
    the_post = Post.find(params[:id])
    the_post.forward_posts_count += 1
    the_post.save
    post = Post.create_forward_post(URI::decode(params[:status]||"转晒"), @user, the_post, params[:from])
    
    #同时评论给原微博作者
    if params[:is_comment] == "1" || params[:is_comment] == "true"
      if !the_post.is_hide && !the_post.is_private
        attr = {:comment=>{:content=>URI::decode(params[:status])}}
        comment = Comment.create_comment(attr,@user,the_post)
      end
    end
    render :json=>post
  end

  #收藏某条记录或宝典
  def favourite
    params[:tp] = params[:tp] || "post"
    fav = Favourite.first(:conditions=>["tp = ? and user_id = ? and tp_id = ?", params[:tp], @user.id, params[:id]])
    if fav
      fav.destroy
      render :text=>"cancel"
    else
      fav = Favourite.new
      fav.user_id = @user.id
      fav.tp_id = params[:id]
      fav.tp = params[:tp]
      fav.save

      if params[:tp] == "dianping"
        poi = ActiveSupport::JSON.decode(params[:json])
        place = Place.find_by_business_id(poi["business_id"])
        if !place
          place = Place.create(:json=>params[:json])
        end
      end
      render :text=>"ok"
    end
  end
  
  #对某条微博或照片书进行鼓掌
  def clap
    params[:tp] = params[:tp] || "post"
    
    clap = Clap.new
    clap.user_id = @user.id
    clap.tp_id = params[:id]
    clap.tp = params[:tp]
    clap.save

    if Clap.count(:conditions=>"tp_id = #{params[:id]} and tp = 'post' and user_id = #{@user.id}") >= 6
      if params[:tp] == "post"
        post = Post.find(params[:id])
        render :json=>post
      else
        render :text=>"full"
      end
      
      return
    end
    claps_count = 1
    if params[:tp] == "post"
      post = Post.find(params[:id])
      post.claps_count += 1
      post.save

      render :json=>post
    elsif params[:tp] == "album"
      album = AlbumBook.find(params[:id])
      AlbumBook.update_all "like_count = like_count + 1", "id = #{params[:id]}"
      claps_count = album.like_count

      render :text => claps_count + 1
    else
      render :text=>"ok"
    end    
  end

  # ==对一条微博信息进行评论
  #   [路径]： statuses/comment
  #   [HTTP请求方式]:  POST
  #   [URL]: http://your.api.domain/statuses/comment.json
  #   [是否需要登录]: true
  #
  # ====参数
  # - source: 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。 (必选)
  # - :id:  要评论的微博消息ID (必选)
  # - comment:  评论内容。必须做URLEncode,信息内容不超过140个汉字。 (必选)
  # - is_copy_post: 是否同时发表到微博 0为不发布， 1为发布
  # - tp : tp为article则向article发表评论
  # ====示例
  #
  #   curl -u "username:password" -d "id=111904&comment=wahaha"
  #   "http://your.api.domain/statuses/comment.json?source=appkey"
  #
  # ====注意
  # - 请求必须用POST方式提交
  # - 如果id不存在，将返回error
  #

  def comment
    sid = @user.sid
    sid = UserInfo.find_by_user_id(@user.id).try(:sid) if !sid
    if sid.to_s.size > 6
      if Blacksid.first(:conditions=>"sid='#{sid}'")
        render :text=>"恶意骚扰用户请离开本社区" and return
      end
    end

    render :text=>"error" and return if params[:comment].blank?
    attr = {:comment=>{:content=>URI::decode(params[:comment])}}
    attr[:is_copy_post] = params[:is_copy_post] if params[:is_copy_post].present? && params[:is_copy_post] != "undefined"
    attr[:from] = params[:from]
    if params[:tp] == 'article'
      comment = ArticleComment.create_article_comment(attr,@user,Article.find(params[:id]))
      render :json=>comment
    elsif params[:tp] == "album"
      comment = AlbumComment.new
      comment.user_id = @user.id
      comment.book_id = params[:id]
      comment.content = URI::decode(params[:comment])
      comment.save
      render :json=>comment
    else
      post = Post.find(params[:id])

      #不是记录原作者
      if @user.id != post.user_id
        comments = Comment.find(:all, :conditions=>"post_id = #{post.id}", :order=>"id desc", :limit=>3);
        #这条记录的最近3条评论出自同一个人，则不让评论
        if comments.size == 3 && comments[0].user_id == @user.id && comments[1].user_id == @user.id && comments[2].user_id == @user.id
          special = UserSpecial.new
          special.tp = "评论刷屏，连刷3条"
          special.user_id = @user.id
          special.user_name    = @user.name
          special.save
          render :text=>"请不要刷屏，还妈妈晒一片宁静" and return
        end

        #上一次评论不超过10秒
        if comments.size > 0 && Time.now - comments[0].created_at < 10.seconds && comments[0].user_id == @user.id
          special = UserSpecial.new
          special.tp = "评论刷屏，10秒连发"
          special.user_id = @user.id
          special.user_name    = @user.name
          special.save
          render :text=>"请不要刷屏" and return
        end
      end

      

      render :text=>"无法评论，因为记录已被删除" and return if post.is_hide
      render :text=>"本记录不接受评论" and return if post.is_private && @user.id != post.user_id


      blocks = Blockcomment.all
      for b in blocks
        render :json=>Comment.new(:content=>"无法评论") and return if [@user.id, post.user_id].sort == [b.user_id1, b.user_id2].sort
      end

      comment = Comment.find(:first, :conditions=>["post_id = ? and content=? and user_id = ?", post.id, URI::decode(params[:comment]), @user.id])
      comment = Comment.create_comment(attr,@user,post) if !comment
      if params[:reply_all] == 'true' && @user.id == post.user_id  #回复全部
        comments = Comment.all(:conditions=>["post_id = ? and user_id <> ?", post.id, @user.id], :group=>"user_id")
        for c in comments
          CommentAtRemind.create(:comment_id=>comment.id, :user_id=>c.user_id) rescue nil
          MamashaiTools::ToolUtil.push_aps(c.user_id, "#{@user.name}回复了评论：#{comment.content}", {"t"=>"comment"})
        end
      end
      render :json=>comment
    end
  end

  # ==回复评论。请求必须用POST方式提交。
  #   [路径]： statuses/reply
  #   [HTTP请求方式]:  POST
  #   [URL]: http://your.api.domain/statuses/reply.json
  #   [是否需要登录]: true
  #
  # ====参数
  # - source: 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。 (必选)
  # - :id:  要评论的微博消息ID (必选)
  # - comment:  评论内容。必须做URLEncode,信息内容不超过140个汉字。必须包含“回复@用户名:” (必选)
  # - is_copy_post: 是否同时发表到微博 0为不发布， 1为发布
  #
  # ====示例
  #
  #   curl -u "username:password" -d "id=111904&comment=wahaha"
  #   "http://your.api.domain/statuses/comment.json?source=appkey"
  #
  # ====注意
  # - 请求必须用POST方式提交
  # - 如果id不存在，将返回400错误
  # - comment参数必须包含“回复@用户名:”
  #
  def reply
    render :text=>"error" and return if params[:comment].blank?
    post = Post.find(params[:id])
    attr = {:comment=>{:content=>URI::decode(params[:comment])}}
    attr[:is_copy_post] = params[:is_copy_post] if params[:is_copy_post].present?
    comment = Comment.create_comment(attr,@user,post)
    render :json=>comment
  end

  # ==删除评论
  #
  #   [路径]：statuses/comment_destroy/:id
  #   [HTTP请求方式]: POST/DELETE
  #   [URL]: http://your.api.domain/statuses/statuses/comment_destroy/:id.json
  #   [是否需要登录]: true
  #
  # ====参数
  # - source： 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。 (必选)
  # - :id： 欲删除的评论ID (必选)
  #
  # ====示例
  #
  #   curl -u "username:password" -X DELETE
  #   "http://your.api.domain/statuses/comment_destroy/1122333.json?source=appkey"
  #
  # ====注意
  # - 如果传入的评论ID不在登录用户的comments_by_me列表中，则返回400错误
  # - 只能删除登录用户自己发布的评论，不可以删除其他人的评论。
  #
  def comment_destroy
    Comment.delete_post_comment(params[:id],@user)
    render :text=>"ok"
  end

  # ==返回最新n条提到登录用户的微博消息（即包含@username的微博消息）
  #
  #   [路径]：statuses/mentions
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/statuses/mentions.json?source=appkey&count=5&page=2
  #   [是否需要登录]: true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - count  指定每页返回的记录条数。默认值10
  # - page  页码,默认是1。
  # - post_tp  微博类型，空为全部，original原创，groups群组, picture图片，video视频，blog博客. 返回指定类型的微博信息内容。
  # - post_age_id 年龄段, 1:没有孩子, 2:孕期, 3:0-1岁, 4:1-2岁, 5:2-3岁, 6:3-5岁, 7:5-7岁, 8:7-9岁, 9:9-12岁, 10:12-15岁, 11:15-18岁, 12:18岁以上
  #
  # ====示例
  #
  #   curl -u "username:password"
  #   "http://your.api.domain/statuses/mentions.json?source=appkey&count=5&page=2"
  #
  def mentions
    params[:per_page] = params[:count]||20
    #params[:no_page] = true
    posts = Post.find_about_me_posts(@user,params)
    render :text=>"null" and return if posts.size == 0
    render :json=>posts
  end

  # ==获取当前用户发送及收到的评论列表
  #
  #   [路径]：statuses/comments_timeline
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/statuses/comments_timeline.json?source=appkey&count=5&page=2
  #   [是否需要登录]: true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - count  指定每页返回的记录条数。默认值10
  # - page  页码,默认是1。
  #
  # ====示例
  #
  #   curl -u "username:password"
  #   "http://your.api.domain/statuses/comments_timeline.json?source=appkey&count=5&page=2"
  #
  def comments_timeline
    params[:per_page] = params[:count]||10
    comments = Comment.find_user_comments(@user,params)
    render :json=>comments
  end

  # ==获取当前用户发出的评论
  #
  #   [路径]：statuses/comments_by_me
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/statuses/comments_by_me.json?source=appkey&count=5&page=2
  #   [是否需要登录]: true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - count  指定每页返回的记录条数。默认值10
  # - page  页码,默认是1。
  #
  # ====示例
  #
  #   curl -u "username:password"
  #   "http://your.api.domain/statuses/comments_by_me.json?source=appkey&count=5&page=2"
  #
  def comments_by_me
    params[:per_page] = params[:count]||10
    comments = Comment.find_user_comments(@user,params)
    render :json=>comments
  end

  # ==获取当前用户发出的评论
  #
  #   [路径]：statuses/comments_to_me
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/statuses/comments_to_me.json?source=appkey&count=5&page=2
  #   [是否需要登录]: true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - count  指定每页返回的记录条数。默认值10
  # - page  页码,默认是1。
  #
  # ====示例
  #
  #   curl -u "username:password"
  #   "http://your.api.domain/statuses/comments_to_me.json?source=appkey&count=5&page=2"
  #
  def comments_to_me
    params[:per_page] = params[:count]||10
    comments = Comment.find_user_posts_comments(@user,params, false)
    render :text=>"null" and return if comments.size == 0
    render :json=>comments
  end

  # ==根据微博消息ID返回某条微博消息的评论列表
  #
  #   [路径]：statuses/comments
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/statuses/comments.json?source=appkey&count=5&page=2
  #   [是否需要登录]: true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - :id:   指定要获取的评论列表所属的微博消息ID  (必选)
  # - count  指定每页返回的记录条数。默认值10
  # - page  页码,默认是1。
  #
  # ====示例
  #   curl -u "username:password"
  #   "http://your.api.domain/statuses/comments.json?source=appkey&count=5&page=2&id=11212"
  #
  # ====注意
  # - 如果ID对应的微博不存在，返回null错误
  def comments
    params[:per_page] = params[:count]||40
    if params[:tp] == 'article'
      comments = ArticleComment.paginate :page=>params[:page], :per_page=>params[:per_page], :conditions=>"article_id = #{params[:id]}", :order=>"id"
      render :json=>comments.to_json
    elsif params[:tp] == 'album'
      comments = AlbumComment.paginate :page=>params[:page], :per_page=>params[:per_page], :conditions=>"book_id = #{params[:id]}", :order=>"id"
      render :json=>comments
    else
      post = Post.find(params[:id])
      comments = Comment.all(:conditions=>['comments.post_id=?',post.id], :include=>[:user],:order => "comments.id")
      #comments = Comment.find_post_comments(post,params)
      render :json=>comments.to_json
    end
  end

  def comments_and_like
    #params[:per_page] = params[:count]||10 if !params[:per_page]
    params[:per_page] = 10
    if params[:tp] == 'article'
      comments = ArticleComment.paginate :page=>params[:page], :per_page=>params[:per_page], :conditions=>"article_id = #{params[:id]}", :order=>"id"
    elsif params[:tp] == 'album'
      comments = AlbumComment.paginate :page=>params[:page], :per_page=>params[:per_page], :conditions=>"book_id = #{params[:id]}", :order=>"id"
    else
      post = Post.find(params[:id])
      comments = Comment.paginate(:per_page=>params[:per_page], :page=>params[:page], :conditions=>['comments.post_id=?',post.id], :include=>[:user],:order => "comments.id")
    end

    if params[:page].to_i > 1
      claps = []
    else
      claps = Clap.all(:conditions=>"tp_id=#{params[:id]} and tp='#{params[:tp]||'post'}'", :group=>"user_id", :order=>"id desc", :limit=>20).reverse
    end

    claps.delete_if{|c| !c.user }

    result = {:claps=>claps, :comments=>comments, :total_entries=>comments.total_entries}
    if comments.total_pages > params[:page].to_i
      result[:has_more] = true
    end
    
    render :json=> result
  end

  def comments_and_like2
    #params[:per_page] = params[:count]||10 if !params[:per_page]
    params[:per_page] = 16
    if params[:tp] == 'article'
      comments = ArticleComment.paginate :page=>params[:page], :per_page=>params[:per_page], :conditions=>"article_id = #{params[:id]}", :order=>"id"
    elsif params[:tp] == 'album'
      comments = AlbumComment.paginate :page=>params[:page], :per_page=>params[:per_page], :conditions=>"book_id = #{params[:id]}", :order=>"id"
    else
      post = Post.find(params[:id])
      comments = Comment.paginate(:per_page=>params[:per_page], :page=>params[:page], :conditions=>['comments.post_id=?',post.id], :include=>[:user],:order => "comments.id")
    end

    if params[:page].to_i > 1
      claps = []
    else
      claps = Clap.all(:conditions=>"tp_id=#{params[:id]} and tp='#{params[:tp]||'post'}'", :group=>"user_id", :order=>"id desc", :limit=>20).reverse
    end

    claps.delete_if{|c| !c.user }

    result = {:claps=>claps, :comments=>comments, :total_entries=>comments.total_entries}
    if comments.total_pages > params[:page].to_i
      result[:has_more] = true
    end
    
    render :json=> result
  end

  # ==批量获取n条微博消息的评论数和转发数。一次请求最多可以获取100条微博消息的评论数和转发数
  #
  #   [路径]：statuses/counts
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/statuses/counts.json
  #   [是否需要登录]: true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - ids:   要获取评论数和转发数的微博消息ID列表，用逗号隔开 (必选)
  #
  # ====示例
  #   curl -u "username:password"
  #   "http://your.api.domain/statuses/counts.json?source=appkey&ids=32817222,32817223"
  def counts

  end

  # ==返回一条原创微博的最新n条转发微博信息
  def repost_timeline

  end

  # ==返回用户转发的最新n条微博信息
  def repost_by_me

  end

  # ==获取用户关注列表及每个关注用户的最新一条微博，返回结果按关注时间倒序排列，最新关注的用户排在最前面。
  #
  #   [路径]：statuses/friends
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/statuses/friends.json
  #   [是否需要登录]: true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - :id:   用户ID，为空则返回当前登录用户
  # - count  指定每页返回的记录条数。默认值10
  # - page  页码,默认是1。
  #
  # ====示例
  #   curl -u "username:password"
  #   "http://your.api.domain/statuses/friends.json?source=appkey&count=5&page=2&id=203"
  #
  # ====注意
  # - 如果ID对应的用户不存在，取当前登录用户
  def friends
    @user = User.find(params[:id]) if params[:id].present?
    params[:per_page] = params[:count]||10
    users = @user.follows.paginate(:page=>params[:page]||1,:include=>[:province,:city,:last_post], :order=>"follow_users.id desc",:per_page=>params[:per_page]||25, :total_entries=>1000)
    render :json=>users.to_json(:methods=>User.json_methods, :include=>{:last_post=>{:only=>Post.json_attrs, :methods=>Post.json_methods}, :user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}})
  end

  # ==获取用户粉丝列表及每个粉丝的最新一条微博，返回结果按关注时间倒序排列，最新关注的粉丝排在最前面。
  #
  #   [路径]：statuses/followers
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/statuses/followers.json
  #   [是否需要登录]: true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - :id:   用户ID，为空则返回当前登录用户
  # - count  指定每页返回的记录条数。默认值10
  # - page  页码,默认是1。
  #
  # ====示例
  #   curl -u "username:password"
  #   "http://your.api.domain/statuses/followers.json?source=appkey&count=5&page=2&id=203"
  #
  # ====注意
  # - 如果ID对应的用户不存在，取当前登录用户
  def followers
    MamashaiTools::ToolUtil.clear_unread_infos(@user,:unread_fans_count)
    @user = User.find(params[:id]) if params[:id].present?
    params[:per_page] = params[:count]||10
    users = @user.fans.paginate(:page=>params[:page]||1,:include=>[:province,:city,:last_post],:order=>"follow_users.id desc",:per_page=>params[:per_page]||25, :total_entries=>1000)
    render :json=>users.to_json(:methods=>User.json_methods, :include=>{:last_post=>{:only=>Post.json_attrs, :methods=>Post.json_methods}, :user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}})
  end
  
  #返回宝典类别
  #没加id，返回顶级类别
  #加id，返回子类别
  def article_category
    if params[:id]
      @categories = ArticleCategory.find(:all, :conditions=>"parent_id = #{params['id']} and tp = 0 and id <> 51")
    else
      @categories = ArticleCategory.find(:all, :conditions=>"parent_id is null and tp = 0")
    end
    
    render :json=>@categories.to_json
  end
  
  #返回某个类别的宝典
  def articles
    articles = Article.paginate :select=>"id, title", :page=>params[:page], :per_page=>30, :conditions=>"article_category_id = #{params[:id]}", :total_entries=>1000
    render :json=>articles.to_json
  end
  
  def column_categories
    render :json=>ColumnCategory.find(:all, :order=>"id").to_json
  end
  
  def column_authors
    conditions = ["chapters > 1"]
    if params[:category_id]
      conditions << "category like '%#{params[:category_id]}%'"
    end
    authors = ColumnAuthor.find(:all, :order=>"chapters desc", :conditions=>conditions.join(' and '), :include=>[:user]).sort{|a, b| b.count_of("visits") <=> a.count_of("visits")}
    render :json=>authors.to_json
  end
  
  def column_books
    books = ColumnBook.find(:all, :conditions=>"user_id=#{params['id']}", :order=>'id desc')
    render :json=>books.to_json
  end
  
  def column_chapters
    conditions = ["1=1"]
    conditions << "book_id = #{params[:id]}" if params[:id]
    conditions << params[:cond] if params[:cond]
    limit = params[:count] || 15
    limit = 100 if params[:id]
    chapters = ColumnChapter.find(:all, 
      :select=>"column_chapters.id, column_chapters.title, column_chapters.user_id, column_chapters.book_id, column_chapters.updated_at, visited_times, posts.id as post_id, column_chapters.created_at", 
      :joins=>"left join posts on posts.`from` = 'column' and posts.from_id = column_chapters.id",  
      :conditions=>conditions.join(' and '), 
      :limit => limit,
      :order=>'id desc')
    render :json=>chapters.to_json(:methods=>[:user, :post_id, :book_name, :refer_time])
  end
  
  def column_chapter
    chapter = ColumnChapter.find_by_id(params['id'])
    chapter.column_book.visits += 1
    chapter.column_book.save
      
    chapter.visited_times += 1
    chapter.save
    
    if params[:uid].to_s.size > 0
      visit = ColumnVisit.new(:author_id => chapter.user_id , :book_id => chapter.book_id, :chapter_id=>chapter.id, :visitor_id=>params[:uid])
      visit.save
    end
      
    render :json=>chapter.to_json(:methods=>[:user, :post_id, :book_name, :refer_time])
  end
  
  def lama_posts
    per_page = params[:per_page] || 10
    page = params[:page] || 1
    per_page = per_page.to_i
    page = page.to_i
    conditions = ["posts.logo is not null and `from` like 'lama_%'"]
    conditions << "user_id = #{params[:user_id]}" if params[:user_id]
    
    if params[:has_location]
    	posts = Post.not_hide.find(:all, :conditions=>conditions.join(" and "), :select=>"posts.*, post_locations.latitude, post_locations.longitude", :joins=>"right join post_locations on posts.id = post_locations.post_id", :order=>"id desc", :limit=>per_page, :offset=>(page-1)*per_page)
    else
    	posts = Post.not_hide.find(:all, :conditions=>conditions.join(" and "), :order=>"id desc", :limit=>per_page, :offset=>(page-1)*per_page)
    end
    render :json=>posts
  end
  
  #获得辣妈之星，一周之内的
  def lama_stars
    now = Time.new
    posts = Post.find(:all, :conditions=>"logo is not null and `from` like 'lama_%' and created_at > '#{now.ago(4.days).to_s(:db)}' and created_at < '#{now.to_s(:db)}'", :order=>"forward_posts_count*3 + comments_count*2 + claps_count desc", :limit=>8)
    render :json=>posts
    #render :text=>posts.to_json(:methods=>[:lamadiary])
  end
  
  #辣妈装备
  def lama_advs
    conditions = ["tp=4 and hide=0 "]
    conditions << params[:cond] if params[:cond]
    advs = Adv.find(:all, :conditions=>conditions.join(' and '), :order=>"id desc", :limit=>params[:count]||10)
    render :json=> advs
  end
  
  #获得热门话题
  def hot_topic
    per_page = params[:per_page] || 10
    page = params[:page] || 1
    per_page = per_page.to_i
    page = page.to_i
    if params[:id] && Age.find(:first, :conditions=>"id in (#{params[:id]})")
      tags = AgeTag.find(:all, :conditions=>"logo is not null and age_id in (#{params[:id]})", :order=>"updated_at desc", :limit=>per_page, :offset=>(page-1)*per_page)
      render :json=> tags
    elsif params[:per_page].to_i == 1
      return the_hot_topic
    else
      tags = AgeTag.find(:all, :conditions=>"logo is not null", :order=>"id desc", :limit=>per_page, :offset=>(page-1)*per_page)
      render :json=> tags
    end
  end

  #获得本周热点话题
  def the_hot_topic
      limit = 16
      week_tags = WeekTag.normal.paginate(:page=>params[:page], :per_page=>limit, :order=>"current desc, created_at desc", :total_entries=>1000)
      render :json=>week_tags
  end
  
  def bbrl_version
    if params[:code]
      version = BbrlVersion.find(:all, :limit=>1, :conditions=>"code='#{params[:code]}'", :order=>"id desc")
    else
      version = BbrlVersion.find(:all, :limit=>1, :conditions=>"code is null", :order=>"id desc")
    end
    render :json=>version
  end
  
  #列出所有礼品
  def gifts
    gifts = Gift.find(:all, :order=>"id", :conditions=>"id > 42")
    render :json=>gifts
  end
  
  #送礼物
  def send_gift
    gift_params = {}
    gift_params[:gift_get] = {}
    gift_params[:gift_get][:gift_id] = params[:gift_id]
    gift_params[:gift_get][:content] = URI.decode(params[:content]||'')
    user = User.find_by_id(params[:id])
    gift_params[:gift_get][:user_name] = user.name
    @gift_get = GiftGet.create_user_gift_gets(@user, gift_params)
    render :text=>"ok"
  end
  
  #我收到的礼物
  def gifts_to_me
    gift_gets = GiftGet.find_user_gift_gets(@user,params)
    render :json=>gift_gets
  end
  
  #显示还在进行的豆豆换
  def ddh
    conditions = ["(hide is null or hide=0) and  remain > 0 and end_at >= '#{Date.today.to_s()}' and begin_at<='#{Date.today.to_s()}'"]
    conditions << params[:cond] if params[:cond]
    ddhs = Ddh.duihuan.paginate(:page=>params[:page], :per_page=>20, :conditions=>conditions.join(' and '), :order=>"order_num desc, status asc, id desc", :total_entries=>1000)
    render :json=>ddhs
  end

  #已开始的倒序排列
  def ddh_list
    page = params[:page] || 1
    ddhs = Ddh.duihuan.paginate(:order=>"order_num desc, status asc, id desc", :conditions=>"tp = 1 and (hide is null or hide=0)", :page=>page, :per_page=>10, :total_entries=>1000)
    
    render :json=>ddhs
  end

  #包括兑换和试用
  def ddh_list_v2
    cond = ["(hide is null or hide=0) and tp = 1"]
    cond << params[:cond] if params[:cond]
    page = params[:page] || 1
    if params[:user_id]
      cond << "ddh_orders.user_id = #{params[:user_id]}"
      ddhs = Ddh.paginate(:order=>"order_num desc, status asc, id desc", :joins=>"left join ddh_orders on ddh_orders.ddh_id = ddhs.id", :conditions=>cond.join(" and "), :page=>page, :per_page=>10, :total_entries=>1000)
    else
      ddhs = Ddh.paginate(:order=>"order_num desc, status asc, id desc", :conditions=>cond.join(" and "), :page=>page, :per_page=>10, :total_entries=>1000)
    end
    render :json=>ddhs
  end

  #包括兑换，试用，红包
  def ddh_list_v3
    cond = ["(hide is null or hide=0)"]
    cond << params[:cond] if params[:cond]
    page = params[:page] || 1
    if params[:user_id]
      cond << "ddh_orders.user_id = #{params[:user_id]}"
      ddhs = Ddh.paginate(:order=>"order_num desc, status asc, id desc", :joins=>"left join ddh_orders on ddh_orders.ddh_id = ddhs.id", :conditions=>cond.join(" and "), :page=>page, :per_page=>10, :total_entries=>1000)
    else
      ddhs = Ddh.paginate(:order=>"order_num desc, status asc, id desc", :conditions=>cond.join(" and "), :page=>page, :per_page=>10, :total_entries=>1000)
    end
    render :json=>ddhs
  end

  #查看一个豆豆换的申请人
  def ddh_users
    page = params[:page] || 1
    cond = ["ddh_id = #{params[:id]}"]
    cond << "(status='等待发货' or status='已发货' or status='已通过审核')" if params[:status] == "success"
    users = User.all(:offset=>(page.to_i-1)*12, :limit=>12, :joins=>"left join ddh_orders on ddh_orders.user_id = users.id", :conditions=>cond.join(' and '), :order=>"ddh_orders.created_at desc")
    render :json=>users
  end

  def ddh_order
    orders = DdhOrder.find(:all, :order=>"id desc", :conditions=>"user_id=#{@user.id}")
    render :json=>orders
  end

  def ddh_visit
    ddh = Ddh.find_by_id(params[:id])
    if ddh
      ddh.visit += 1
      ddh.save

      visit = DdhVisit.new
      visit.ddh_id = ddh.id
      visit.ip = request.ip
      visit.save
    end
    render :text=>"ok"
  end
  
  #兑换一个礼品
  def ddh_get
    #if request.env['HTTP_USER_AGENT'].to_s.downcase.include?('iphone') || request.env['HTTP_USER_AGENT'].to_s.downcase.include?('ipad')
    #  if params[:osname] == 'iphone' || params[:osname] == 'ipad'
    #    if !%w(2.9.16 3.0.16 4.4.16 2.9.17 3.0.17 4.4.17 3.0.1 3.1.1 4.5.1).include?(params[:version])
    #      render :text=>"亲，更新最新版本才能提交哦！" and return;
    #    end
    #  else
    #    render :text=>"亲，更新最新版本才能提交哦！" and return;
    #  end
    #end

    ddh = Ddh.find_by_id(params[:id])
    if !ddh 
      render :text=>"对不起，礼物已下架！" and return;
    end

    if ddh.require_posts_count>0 && @user.posts_count < ddh.require_posts_count
      render :text=>"对不起，您至少需要有#{ddh.require_posts_count}条记录才可以#{ddh.score > 0 ? '兑换' : '申请'}此礼物，现在只有#{@user.posts_count}条记录" and return;
    end

    if ddh.require_level>0 && @user.mms_level < ddh.require_level
      render :text=>"对不起，您的用户等级需要达到#{ddh.require_level}级才可以#{ddh.score > 0 ? '兑换' : '申请'}此礼物" and return;
    end

    if ddh.require_comments_count>0 && Comment.count(:conditions=>"user_id=#{@user.id}") < ddh.require_comments_count
      render :text=>"对不起，您需要评论其他用户#{ddh.require_comments_count}次才可以#{ddh.score > 0 ? '兑换' : '申请'}此礼物" and return;
    end

    if Time.now.to_s(:db) < ddh.begin_at.to_s
      render :text=>"对不起，还没到开抢时间呢！" and return;
    end

    #检查是否有没有提交的体验报告
    ddh_orders = DdhOrder.find(:all, :joins=>"left join ddhs on ddhs.id = ddh_orders.ddh_id", :conditions=>"(hide is null or hide = 0) and user_id = #{@user.id} and ddh_orders.created_at > '2014-11-06' and ddh_orders.created_at < '#{Time.new.ago(15.days).to_date.to_s}' and  (ddh_orders.status='已发货' or ddh_orders.status='已通过审核')")
    for order in ddh_orders
      post = Post.find(:first, :conditions=>"user_id = #{@user.id} and `from`='ddh_report' and from_id=#{order.ddh_id}")
      if !post
        render :text=>"亲，您兑换的#{order.ddh.title}还未填写体验报告，无法申请新的试用"
        return
      end
    end

    #兑换
    if ddh.score > 5   
      ddh_orders = DdhOrder.find(:all, :joins=>"left join ddhs on ddhs.id = ddh_orders.ddh_id", :conditions=>"(hide is null or hide = 0) and user_id = #{@user.id} and ddhs.score > 5 and ddh_orders.created_at > '#{Time.new.ago(48.hours).to_s(:db)}'")
      if ddh_orders.size > 0
        render :text=>"亲，您已经兑换了#{ddh_orders[0].ddh.title}每周只能兑换一次哦"
        return
      end
    end

    if DdhOrder.find(:first, :conditions=>"user_id = #{@user.id} and ddh_id = #{ddh.id}")
        render :text=>"repeat" and return
    end

    if @user.score < ddh.score
      render :text=>"对不起，您的晒豆数不够" and return;
    end

    if 1307 == ddh.id
      start_date = '2016-1-1'
      end_date = '2016-12-31'
      consist_date = 199
      if @user.score_events.exists?(['created_at >= ? and created_at <= ? and event = ?', start_date, end_date, 'delete_post'])
        render :text=>"对不起，您在2016年度存在违规行为，不能兑换该项礼物" and return
      end
      date_array = @user.posts.where(['created_at >= ? and created_at <= ?', start_date, end_date]).where(is_private: false).where(is_hide: false).where('logo is not null').reorder(:id).pluck(:created_at)
      is_ok = false
      date_array = date_array.map(&:to_date).uniq.reverse
      hash = {}
      date_array.each_with_index do |date, index|
        if index == 0 || (date_array[index-1] - date).to_i != 1
          hash[date] ||= 1
        else
          hash[hash.keys.last] += 1
        end
      end
      is_ok = true if hash.values.any? {|num| num >= consist_date}
      unless is_ok
        interval_date = if hash.values.first
                          if date_array.first.in? [Time.now.to_date, 1.days.ago.to_date]
                            consist_date-hash.values.first
                          else
                            consist_date
                          end
                        else
                          consist_date
                        end
        render :text=>"对不起，您的连续活跃天数不足#{consist_date}天，目前还差#{interval_date}天" and return
      end
    end
    
    ddh.reload
    if ddh.remain > 0
      if ddh.score > 5
        ddh.remain    -= 1
        ddh.save
      end

      order = DdhOrder.new
      order.name    = URI.decode(params[:name].to_s)
      order.mobile  = URI.decode(params[:mobile].to_s)
      order.address = URI.decode(params[:address].to_s)
      order.code    = URI.decode(params[:code].to_s)
      order.remark  = URI.decode(params[:remark].to_s)
      order.ddh_id  = params[:id]
      order.user_id = @user.id
      order.save
      
      if params[:make_post] == "1"
        post = Post.new
        post.content = "我参加了妈妈晒的豆豆换，兑换了#{ddh.title}，大家都来看看吧。"
        post.user_id = @user.id
        post.logo = ddh.logo
        post.save
      end

      if ddh.score > 0
        Mms::Score.trigger_event(:make_ddh, "进行豆豆换积分兑换", 1, 1, {:user => @user,:cost=>0-ddh.score,:description=>"兑换：#{ddh.title}"})
      end
      
      render :text=>"ok"
    else
      render :text=>"empty"
    end
  end
  
  def ddh_history
    events = ScoreEvent.paginate(:page=>params[:page], :per_page=>30, :conditions=>"user_id = #{@user.id}", :order=>"id desc", :total_entries=>1000)
    render :json=>events
  end

  #根据传入的经纬度进行纠偏和获得地址
  def poi_get_offset_and_address
    token = Weibotoken.get('sina', "baby_calendar")
    user_weibo = UserWeibo.find(:first, :conditions=>"tp=#{token.tp} and expire_at > #{Time.new.to_i}", :order=>"id desc")
    text = `curl 'https://api.weibo.com/2/location/geo/gps_to_offset.json?source=#{token.token}&access_token=#{user_weibo.access_token}&coordinate=#{params[:long]}%2C#{params[:lat]}'`
    json = JSON.parse(text)
    lon = json['geos'][0]['longitude']
    lat = json['geos'][0]['latitude']

    logger.info "curl 'https://api.weibo.com/2/location/geo/geo_to_address.json?source=#{token.token}&access_token=#{user_weibo.access_token}&coordinate=#{lon}%2C#{lat}'"
    text = `curl 'https://api.weibo.com/2/location/geo/geo_to_address.json?source=#{token.token}&access_token=#{user_weibo.access_token}&coordinate=#{lon}%2C#{lat}'`
    json2 = JSON.parse(text)

    city_name = ''
    address = '' 
    name = ''
    if json2['geos'] && json2['geos'].size > 0
      city_name = json2['geos'][0]['city_name']
      address = json2['geos'][0]['address']
      name = json2['geos'][0]['name']
    end

    result = {:lon => lon.to_f, :lat => lat.to_f, :city_name=>city_name, :address=>address, :name=>name}

    render :json=>result
  end

  def poi
    token = Weibotoken.get('sina', "baby_calendar")
    user_weibo = UserWeibo.find(:first, :conditions=>"tp=#{token.tp} and expire_at > #{Time.new.to_i}", :order=>"id desc")
    text = `curl 'https://api.weibo.com/2/place/nearby/pois.json?source=#{token.token}&access_token=#{user_weibo.access_token}&lat=#{params[:lat]}&long=#{params[:long]}&range=500&count=50&sort=1'`
    render :text=>text
  end

  #获得半屏广告
  def calendar_advs
    if request.env['HTTP_USER_AGENT'] && (request.env['HTTP_USER_AGENT'].downcase.include?('iphone') || request.env['HTTP_USER_AGENT'].downcase.include?('ipad'))
      if params[:tp] == "development"
        advs = CalendarAdv.all(:order=>"position, id desc", :conditions=>"(only = '' or only = 'iphone') and (status='test' or status='online')")
        render :json=>advs
        return
      end
      advs = CalendarAdv.normal.all(:conditions=>"only = '' or only is null or only = 'iphone'")
      render :json=>advs
    else
      if params[:tp] == "development"
        advs = CalendarAdv.all(:order=>"position, id desc", :conditions=>"(only = '' or only = 'android') and (status='test' or status='online')")
        render :json=>advs
        return
      end
      render :json=>advs
    end
  end

  #获得半屏广告，新版
  def half_screen_advs
    advs = nil
    topic = WeekTag.first(:conditions=>"current = 1")
    if request.env['HTTP_USER_AGENT'] && (request.env['HTTP_USER_AGENT'].downcase.include?('iphone') || request.env['HTTP_USER_AGENT'].downcase.include?('ipad'))
      if params[:tp] == "test"
        advs = CalendarAdv.all(:order=>"position, id desc", :conditions=>"(only = '' or only = 'iphone') and (status='test' or status='online')")
        render :json => {:advs=>advs, :topic=>topic} and return
      else
        render :json => Rails.cache.fetch("half_screen_advs_ios", :expires_in=>1.days){
          advs = CalendarAdv.normal.all(:conditions=>"only = '' or only is null or only = 'iphone'")
          topic = WeekTag.first(:conditions=>"current = 1")
          {:advs=>advs, :topic=>topic}.as_json
        }
        #advs = CalendarAdv.normal.all(:conditions=>"only = '' or only is null or only = 'iphone'")
      end
    else
      if params[:tp] == "test"
        advs = CalendarAdv.all(:order=>"position, id desc", :conditions=>"(only = '' or only = 'android') and (status='test' or status='online')")
        render :json => {:advs=>advs, :topic=>topic} and return
      else
        render :json => Rails.cache.fetch("half_screen_advs_android", :expires_in=>1.days){
          advs = CalendarAdv.normal.all(:conditions=>"only = '' or only is null or only = 'android'")
          topic = WeekTag.first(:conditions=>"current = 1")
          {:advs=>advs, :topic=>topic}.as_json
        }

        #advs = CalendarAdv.normal.all(:conditions=>"only = '' or only is null or only = 'android'")
      end
    end

    return;

    topic = WeekTag.first(:conditions=>"current = 1")

    result = {:advs=>advs, :topic=>topic}
    render :json=>result
  end

  #获得指南页的直投广告
  def calendar_tip_adv
    if request.env['HTTP_USER_AGENT'] && (request.env['HTTP_USER_AGENT'].downcase.include?('iphone') || request.env['HTTP_USER_AGENT'].downcase.include?('ipad'))
      adv = CalendarTipAdv.find(:first, :conditions=>["code=? and status = ? and (only = '' or only is null or only = 'iphone')", params[:code], 'online'], :order=>"rand()")
      render :json=>adv
    else
      adv = CalendarTipAdv.find(:first, :conditions=>["code=? and status = ? and (only = '' or only is null or only = 'android')", params[:code], 'online'], :order=>"rand()")
      render :json=>adv
    end
  end

  #获得指南页的直投广告列表
  def calendar_tip_adv_list
    if request.env['HTTP_USER_AGENT'] && (request.env['HTTP_USER_AGENT'].downcase.include?('iphone') || request.env['HTTP_USER_AGENT'].downcase.include?('ipad'))
      advs = CalendarTipAdv.find(:all, :conditions=>["code=? and status = ? and (only = '' or only is null or only = 'iphone')", params[:code], 'online'], :limit=>5, :order=>"id desc")
    else
      advs = CalendarTipAdv.find(:all, :conditions=>["code=? and status = ? and (only = '' or only is null or only = 'android')", params[:code], 'online'], :limit=>5, :order=>"id desc")
    end
    render :json=>advs
  end

  def calendar_tip_adv_list2
    #render :text=>'{"tp": "baidu"}' and return;

    if request.env['HTTP_USER_AGENT'] && (request.env['HTTP_USER_AGENT'].downcase.include?('iphone') || request.env['HTTP_USER_AGENT'].downcase.include?('ipad'))
      advs = CalendarTipAdv.find(:all, :conditions=>["code=? and status = ? and (only = '' or only is null or only = 'iphone')", params[:code], 'online'], :limit=>5, :order=>"id desc")
    else
      advs = CalendarTipAdv.find(:all, :conditions=>["code=? and status = ? and (only = '' or only is null or only = 'android')", params[:code], 'online'], :limit=>5, :order=>"id desc")
    end
    render :json=>advs
  end

  def apple_comment
    comment = AppleComment.find(:first, :conditions=>["name=? and created_at > ?", params[:name], Time.new.ago(7.days)])
    if comment
      render :text=>"duplicate" and return
    end

    comment = AppleComment.new
    comment.name = URI.decode(params[:name])
    comment.user_id = @user.id
    comment.save

    render :text=>"ok"
  end

  def make_weixin_score
    if ScoreEvent.count(:conditions=>"event='make_weixin_score' and user_id = #{@user.id} and created_day = '#{Time.new.to_date.to_s}'") < 2
      Mms::Score.trigger_event(:make_weixin_score, params[:text]||"同步内容到微信", 1, 1, {:user => @user})
    end 
    render :text=>"ok"
  end

  def make_weixin_album_book
     if ScoreEvent.count(:conditions=>"event='make_weixin_score' and user_id = #{@user.id} and created_day = '#{Time.new.to_date.to_s}'") < 2
      Mms::Score.trigger_event(:make_weixin_score, params[:text]||"同步内容到微信", 1, 1, {:user => @user})
    end 
    #if ScoreEvent.count(:conditions=>"event='make_weixin_album_book' and user_id = #{@user.id} and created_day = '#{Time.new.to_date.to_s}'") < 1
    #  Mms::Score.trigger_event(:make_weixin_album_book, params[:text]||"分享照片书到微信", 1, 1, {:user => @user})
    #end 
    render :text=>"ok"
  end

  def make_weixin_invite
    #if ScoreEvent.count(:conditions=>"user_id = #{@user.id} and event = 'make_weixin_invite' and created_at > '#{Time.now.beginning_of_week.to_s(:db)}'") < 2
    #    Mms::Score.trigger_event(:make_weixin_invite, "用微信邀请好友", 1, 1, {:cond => :by_per_day, :user => @user})
    #else
    #    Mms::Score.trigger_event(:invite_from_weibo2, "微信邀请每周只给2次豆", 0, 0, {:cond => :by_per_day, :user => @user})
    #end


    #Mms::Score.trigger_event(:make_weixin_invite, params[:text]||"用微信邀请好友", 1, 1, {:cond => :by_per_day, :user => @user})
    render :text=>"ok"
  end

  def find_users
    render :json=>User.__elasticsearch__.search("name:#{URI.decode(params[:text])}").per_page(20).page(params[:page]).records.to_json


    #users = User.search URI.decode(params[:text]), :page=>params[:page], :per_page=>20
    #render :json=>users
  end

  def find_posts
      key = "gt"
      value = 0
      if params[:cond]
        m = params[:cond].scan(/posts.id ([<>])(\d+)/)
        if m.size == 1 && m[0].size == 2
          if m[0][0] == '>'
            key = "gt"
            value  = m[0][1].to_i
          elsif m[0][0] == '<'
            key = "lt"
            value = m[0][1].to_i
          end
        end
      end
      

      opt1 = {
          "query" => {
            "filtered"=> {
              "query"=> { "match_phrase"=> {"content"=> URI.decode(params[:text])} },
              "filter"=> {
                "and"=> [{
                  "range"=> {
                    "id"=> {
                      key=> value
                    }
                  }
                },
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

      if params[:user_id]
        opt1["query"]["filtered"]["filter"]["and"][1]["bool"]["must"] << {"term"=>{"user_id"=>params[:user_id]}}
      end

      logger.info opt1.to_json
      response = Post.__elasticsearch__.search(opt1).per_page(params[:count]||15).page(1)
      ids = response.results.map{|r| r.id}
      ids << -1
      posts = Post.all(:conditions=>"id in (#{ids.join(',')})", :order=>"id desc", :include=>%w(user post_logos))
      render :json=>posts
      return

      #以下代码废除
      options = {:limit=>params[:count]||15, :order=>"id desc", :with=>{ :is_private=>false, :is_hide=>false}}
      if params[:cond]
        m = params[:cond].scan(/posts.id ([<>])(\d+)/)
        if m.size == 1 && m[0].size == 2
          if m[0][0] == '>'
            options[:with][:sphinx_internal_id] = (m[0][1].to_i + 1)..100000000000
          elsif m[0][0] == '<'
            options[:with][:sphinx_internal_id] = 0..(m[0][1].to_i - 1)
          end
        end
      end
      if params[:user_id]
        options[:with][:user_id] = params[:user_id]
      end
      posts = Post.search URI.decode(params[:text]), options
      render :json=>posts
      return
  end

  def find_products
    cond = ["(MATCH(tao_products.name_) AGAINST('#{RMMSeg.segment(URI.decode(params[:text])).collect{|t| "+" + t}.join(' ')}' in boolean mode))"]
    cond << params[:cond] if params[:cond]
    products = TaoProduct.normal.paginate(
      :per_page=>params[:count] || 30,
      :page=>params[:page] || 1,
      :conditions=>cond.join(" and "),
      :total_entries=>20,
      :order=>"id desc"
    )
    render :json=>products
  end

  def find_articles
    render :json=>Article.__elasticsearch__.search("title:#{URI.decode(params[:text])}").per_page(params[:count] || 30).page(params[:page]).records.to_json


    #articles = Article.search URI.decode(params[:text]), :page=>params[:page], :per_page=>params[:count] || 30, :order=>"id desc"
    #render :json=>articles
  end

  def bse_get
    if BseApply.find_by_user_id(@user.id)
      render :text=>"请不要重复提交" and return
    end
    apply = BseApply.new
    apply.user_id = @user.id
    apply.name    = params[:name]
    apply.mobile  = params[:mobile]
    apply.age     = params[:age]
    apply.address = params[:address]
    apply.save
    render :text=>"ok"
  end

  def album_book_count
    if params[:all]
      render :text=>AlbumBook.count(:conditions=>["user_id = ?", params[:id]])
    else
      render :text=>AlbumBook.count(:conditions=>["user_id = ? and recommand = 1", params[:id]])
    end
  end

  def ddh_rules
    file = File.open(Rails.root.to_s + '/public/bbrl_code/ddh_rule.txt')
    txt = file.read()
    file.close()
    render :text=>txt


    #render :file=> Rails.root.to_s + '/public/ddh_rule.txt'
  end

  def ddh_rules2
    render :file=> Rails.root.to_s + '/public/ddh_rule2.txt'
  end

  def about
    file = File.open(Rails.root.to_s + '/public/about.txt')
    txt = file.read()
    file.close()
    render :text=>txt
  end

  def version_check
    #render :layout=>false
    file = File.open(Rails.root.to_s + '/public/bbrl_code/version_check.txt')
    txt = file.read()
    file.close()
    render :text=>txt
  end

  def tiantian_tejia
    render :layout=>false
  end

  def ddh_code
    file = File.open(Rails.root.to_s + '/public/ddh.txt')
    txt = file.read()
    file.close()
    render :text=>txt
  end

  def qinzi
    file = File.open(Rails.root.to_s + '/public/qinzi.txt')
    txt = file.read()
    file.close()
    render :text=>txt
    #render :file=> Rails.root.to_s + '/public/qinzi.txt'
  end

  def qinzi_detail
    file = File.open(Rails.root.to_s + '/public/qinzi_detail.txt')
    txt = file.read()
    file.close()
    render :text=>txt
    #render :file=> Rails.root.to_s + '/public/qinzi.txt'
  end

  def gou_pinzhi
    file = File.open(Rails.root.to_s + '/public/bbrl_code/gou_pinzhi.txt')
    txt = file.read()
    file.close()
    render :text=>txt
    #render :file=> Rails.root.to_s + '/public/qinzi.txt'
  end
  #邀请好友界面
  def invite_user
    file = File.open(Rails.root.to_s + '/public/invite_user.txt')
    txt = file.read()
    file.close

    render :text=>txt and return
    render :file=> Rails.root.to_s + '/public/invite_user.txt'
  end

  #自动获得省市位置
  def get_city_from_gps
    @user_weibo = UserWeibo.first(:order=>"id desc")

    render :layout=>false
  end

  #获得某个人的邀请名单
  def invite_list
    count = User.count(:conditions=>"invite_user_id = #{@user.id}")
    users = User.all(:conditions=>"invite_user_id = #{@user.id}", :order=>"id desc")
    result = {:count=>count, :users=>users}
    render :json=>result
  end

  #设置邀请人
  def set_invite
    user = User.find(params[:id])
    if @user.invite_user_id
      u = User.find(@user.invite_user_id)
      render :text=>"error:亲，您已经设置过 #{u.name} 为介绍人了" and return;
    end

    if @user.id == user.id
      render :text=>"error:亲，不能设置自己为介绍人" and return;
    end

    if params[:sid] && User.find(:first, :conditions=>"id <> #{@user.id} and sid = '#{params[:sid]}'", :order=>"id desc")
      render :text=>"error:亲，反复注册的行为是不给豆的哦" and return;
    end

    @user.invite_user_id = user.id
    @user.save(:validate=>false)

    FollowUser.create_follow_user(user, @user)
    CommentAtRemind.create(:tp=>"follow", :user_id=>user.id, :author_id=>@user.id, :comment_id=>@user.id) rescue nil

    FollowUser.create_follow_user(@user, user)
    CommentAtRemind.create(:tp=>"follow", :user_id=>@user.id, :author_id=>user.id, :comment_id=>user.id) rescue nil


    # if params[:sid] && params[:sid].to_s.size < 30
    #   #安卓就不用刚检查了
    # else
    #   users = User.find(:all, :limit=>3, :conditions=>"invite_user_id = #{user.id} and last_login_ip = '#{request.env["HTTP_X_REAL_IP"]||request.remote_ip}' and created_at > '#{Time.new.ago(10.days).to_s(:db)}'")
    #   if users.size == 3
    #     render :text=>"error:设置成功" and return;
    #   end
    # end

    Mms::Score.trigger_event(:invite_succeed, "成功邀请新用户", 30, 1, {:user => user})
    
    render :text=>"30"
  end

  #点评店铺
  def share_poi
    params[:json] = params[:json].gsub('\n', '')
    poi = ActiveSupport::JSON.decode(params[:json])
    place = Place.find_by_business_id(poi["business_id"])
    if !place
      place = Place.create(:json=>params[:json])
    end

    if PlaceComment.find(:first, :conditions=>["user_id = ? and business_id = ?", @user.id, place.business_id])
      render :text=>"请不要重复点评" and return
    end

    comment         = PlaceComment.new(:user_id => @user.id)
    comment.business_id = place.business_id
    comment.qx      = params[:qx]
    comment.shiyi   = params[:shiyi]
    comment.qinzi   = params[:qinzi]
    comment.rate    = params[:rate] || 5
    comment.content = params[:content]
    comment.save

    attr = {:post=>{:content=>URI::decode(params[:content]), :from=>"dianping", :from_id=>comment.id}}
    attr[:post][:sina_weibo_id] = params[:sina_weibo_id] if params[:sina_weibo_id] && params[:sina_weibo_id].to_i != 0
    attr[:post][:tencent_weibo_id] = params[:tencent_weibo_id] if params[:tencent_weibo_id] && params[:tencent_weibo_id].to_i != 0
    
    attr[:poi] = {:lon => place.longitude, :lat=>place.latitude, :title=>place.city + " " +place.name}

    #自动赋予logo
    file_name = "tmp/#{Time.new.to_i}#{rand(10000000)}.jpg"
    logger.info "wget -T 10 -q -T40 -O #{file_name} '#{place.logo_large}'"
    `wget -T 10 -q -T40 -O #{file_name} '#{place.logo_large}'`
    file = File.open(file_name)
    attr[:post][:logo] = file

    post = Post.create_post(attr,@user)

    file.close()

    render :text=>"OK"
  end

  #获得宝宝日历用户对商户的评论
  def get_bbrl_poi_comments
    comments = PlaceComment.all(:conditions=>"business_id = #{params[:business_id]}", :order=>"id desc")
    render :json=>comments
  end

  def tao_ages
    ages = TaoAge.all(:conditions=>"tp=1",  :order=>"id")
    render :json=>ages
  end

  #保存用户的快递地址信息
  def ddh_address
    address = UserAddress.new
    address.user_id = @user.id
    address.name = params[:name]
    address.mobile = params[:mobile]
    address.address = params[:address]
    address.post_code = params[:code]
    address.save
    render :text=>"保存地址成功"
  end

  #设置ios推送静音
  def set_silent
    device = ApnDevice.find_by_device_token(params[:token])
    device.silent = params[:value] == "true"
    device.save
    render :text=>"ok"
  end

  #查看ios设备是否静音
  def get_silent
    device = ApnDevice.find_by_device_token(params[:token])
    render :json=>{'silent' => device.silent}
  end
end
