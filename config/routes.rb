Mamashai::Application.routes.draw do
  get "soso/test"

  get "soso/index"

  resources :users, :only => [:show] do
    resources :follows, :only => [:show, :index] do
        collection do
            get :search
            get :group_by_kid_age
            get :group_by_group
        end
        member do
            get :edit_nick_name
            post :update_nick_name
            get :edit_group
            post :update_group
        end
    
    end

    resources :fans, :only => [:show, :index] do
        collection do
            get :search
            get :group_by_kid_age
            get :group_by_group
        end
            member do
            get :edit_nick_name
            post :update_nick_name
            get :edit_group
            post :update_group
        end
    end

    resources :gifts, :only => [:show, :index] do
        collection do
            get :sent
            post :create_gift_get
            get :hide_gift_sent
        end
    end
  end

  match '/' => 'p#index'
  
  #namespace :mms do
  #  match "/" => "login#main"
    #resource :login
  #  resource :menu

    
    #mms.resources :apn_devices
    #mms.resources :categories, :members=>{:index=>:get, :update_price=>:get, :products=>:get}, :collection=>{:index=>:get, :update_price=>:get, :products=>:get}
    #mms.resources :tao_categories, :members=>{:index=>:get, :update_price=>:get, :products=>:get}, :collection=>{:index=>:get, :update_price=>:get, :products=>:get}
    #mms.resources :column, :member=>{:authors=>:get}, :collection => {:last_columns => :get}
    #mms.resources :suppliers, :collection => {:index => :get, :search => :any}
    #mms.resources :users, :member => {:destroy => :delete,:user_certificate=>:any, :set_certificate=>:any, :hide_user=>:any,:user_wing=>:any}, :collection => {:index => :get,:list_user_signups=>:get,:list_orgs=>:get,:list_users=>:get}
    #mms.resources :orders, :member=>{:update => :post}, :collection => {:index => :get}
    #mms.resources :products, :member=>{:update => :post, :destroy => :delete, :return_new=>:any}, :collection => {:index => :get, :new => :any}
    #mms.resources :events, :member=>{:update => :post, :destroy => :delete}, :collection => {:index => :get, :new => :any}
    #mms.resources :award_users, :member => {:update => :put, :destroy => :delete,:create=>:any}, :collection => {:index => :get, :new => :any,:search=>:any}
    #mms.resources :tools, :member=>{:update => :any, :destroy => :delete,:create=>:post}, :collection => {:index => :get, :new => :any}
    #mms.resources :tool_categories, :member=>{:update => :any, :destroy => :delete,:create=>:post}, :collection => {:index => :get, :new => :any}
    #mms.resources :tuan_orders, :member=>{:update => :post}, :collection => {:index => :get,:expired=>:get}
    #mms.resources :coupons, :member=>{:update => :post}, :collection => {:index => :get, :coupons_generate => :get,:users=>:get,:categories=>:get,:category_new=>:get,:category_edit=>:get}
    #mms.resources :scores, :member=>{:update => :post}, :collection => {:index => :get, :coupons_generate => :get,:users=>:get}
  #end

  namespace :mms do 
    match "/" => "login#main"
    resources :calendar_advs, only: [] do
      get :list, on: :collection
    end

    resources :calendar_advs do
      resources :pks, only: [:new, :edit, :update, :create, :destroy]
    end
  end

  namespace :cal_end do 
    match "/" => "tips#list"
  end

  namespace :api do
      
      match 'account/callback/:rtoken/:rsecret/:id.:format' => 'account#callback'
  end

  namespace :api do
      resources :mbook do
        collection do
            post :album_delete
            get :auto_books
            post :upload_page
            post :album_upload_page
            post :album_change_name
            get :album_templates
            post :upload
            get :check_discount_code
            get :album_template
            get :album_list
            get :make_order
            get :list
            get :album_list2
            post :delete
            get :album_my_order
            post :album_upload
            get :album_book
        end
    end
  end

  match 'u/:id' => 'space#user_domain'
  match 'user/:id' => 'space#user'
  match 'post/:id' => 'space#post'
  match 'article/:id' => 'articles#article'
  match 'picture/:id' => 'albums#show_picture'
  match 'blog/:id' => 'space#blog_post'
  match 'groups' => 'subjects#my'
  match 'g/:id' => 'index#index'
  match 'plink/:id' => 'index#index', :id => /\d+/
  match 'book/:id' => 'baby_books#show', :id => /\d+/
  match 'babybook/:id.xml' => 'baby_books#show_xml', :constraints => { :id => /\d+/ }
  match 'signup/:id' => 'account#signup'
  match 'brand/:id' => 'gou#brand', :id => /\d+/
  match 'topic/create_post' => 'topic#create_post'
  match 'bbrl/bb_invite' => 'bbrl#bb_invite'
  match 'topic/:id' => 'hot_topic#show'
  match 'pub/posts' => 'index#posts'
  match 'pub/columns/:id' => 'column#show'
  match 'pub/article/:id' => 'articles#article'
  match 'index/bang' => 'bang#index'
  match 'vkid' => 'index#index'
  match 'sunuo' => 'index#index'
  match 'tonghua' => 'index#index'
  match 'ipad_anni' => 'iphone_anni#index'
  match 'ipad_yun' => 'iphone_yun#index'
  match 'before_and_after' => 'xqxh#index'
  match 'yushu' => 'index#index'
  match 'sub/:id' => 'index#index', :id => /\d+/
  match 'subject/:id' => 'index#index'
  match '/:controller(/:action(/:id))'
  #match '/mms/:controller(/:action(/:id))'
  match ':controller(/:action(/:id))', controller: /mms\/[^\/]+/
  match ':controller(/:action(/:id))', controller: /cal_end\/[^\/]+/
  match ':controller(/:action(/:id))', controller: /api\/[^\/]+/
  match ':controller/:action.:format' => '#index'
  match ':controller.:format' => '#index'
end
