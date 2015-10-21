class HotTopicController < ApplicationController
  #before_filter :need_login_user,:need_login_name_user
  before_filter :get_login_user
  before_filter :get_follow_user_ids
  
  layout "main"

  def index
    @ages = Age.find(:all)
    
    #@age_tag = AgeTag.find(:first, :order=>"id desc")
    #@age_tag = AgeTag.find(:first, :conditions=>"week_hot = 1")

    @age_tag = WeekTag.find(:first, :conditions=>"current = 1")

    opt1 = {
          "query" => {
            "filtered"=> {
              "query"=> { "match_phrase"=> {"content"=> @age_tag.short_tag_name} },
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

      response = Post.__elasticsearch__.search(opt1).per_page(20).page(1)
      ids = response.results.map{|r| r.id}
      ids << -1
      @relate_posts = Post.all(:conditions=>"id in (#{ids.join(',')})", :order=>"id desc", :include=>%w(user post_logos))
      
    #@relate_posts = Post.search @age_tag.short_tag_name, :order=>"id desc", :limit=>20, :with=>{:is_private=>false, :is_hide=>false}
  
    @hot_topics = AgeTag.find(:all, :order=> "week_count desc", :limit => 5, :conditions => "age_tags.tp = 0 and short_tag_name is not null")
    
    @latest_topics = WeekTag.normal.all(:limit=>6, :order=>"created_at desc", :conditions=>"current = 0")
  end
  
  def show
    redirect_to :controller => :hot_topic and return if !params[:id]
    
    #@title = URI.decode(params[:id]).to_utf8
    begin
      @title = URI.decode(params[:id])
    rescue
      redirect_to :controller=>"index", :action=>"index" and return
    end

    begin
      @age_tag = AgeTag.find(:first, :conditions=>["short_tag_name = ? and tp = ?", @title, 0], :order=>"updated_at desc")
      @age_tag = WeekTag.find(:first, :conditions=>["short_tag_name = ?", @title]) if !@age_tag
    rescue
      redirect_to "/hot_topic" and return
    end
    params[:content] = @title
    params[:include_forward] = true


    opt1 = {
          "query" => {
            "filtered"=> {
              "query"=> { "match_phrase"=> {"content"=> @title} },
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

      response = Post.__elasticsearch__.search(opt1).per_page(25).page(params[:page])
      ids = response.results.map{|r| r.id}
      ids << -1
      @posts = Post.__elasticsearch__.search(opt1).per_page(25).page(params[:page]).records
      
    #@posts = Post.search @title, :per_page => params[:per_page]||25, :page => params[:page], :order=>"id desc", :with=>{:is_private=>false, :is_hide=>false}
                
    @week_topics = AgeTag.all(:order=>"updated_at desc", :limit=>6)
  end

  def create_post
    return render_404 if params[:post].blank?
    @post = Post.create_post(params,@user)
    if !@post.errors.empty?
      errors = []
      @post.errors.each do |attribute, errors_array|
        errors << errors_array
      end
      flash[:error] = errors.join(",")
      redirect_to :action=>'index',:error=>true and return false
    end
    redirect_to :action=>'index'
  end
end
