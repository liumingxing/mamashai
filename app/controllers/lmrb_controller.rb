require 'RMagick'

class LmrbController < ApplicationController
  before_filter :get_login_user
  layout "main"

  before_filter :to_main

  def to_main
    redirect_to :controller=>"index"
  end
  
  $picModelArea = [
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>13, 'tp'=>'ty'},
                    {'x'=>3, 'y'=>76, 'width'=>338, 'height'=>400, 'index'=>11, 'tp'=>'ty'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>12, 'tp'=>'ty'},
                    {'x'=>3, 'y'=>78, 'width'=>340, 'height'=>228, 'index'=>14, 'tp'=>'ty'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>23, 'tp'=>'star'},
                    {'x'=>0, 'y'=>56, 'width'=>346, 'height'=>424, 'index'=>21, 'tp'=>'star'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>22, 'tp'=>'star'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>24, 'tp'=>'star'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>25, 'tp'=>'star'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>26, 'tp'=>'star'},
                    {'x'=>0, 'y'=>80, 'width'=>346, 'height'=>300, 'index'=>27, 'tp'=>'star'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>28, 'tp'=>'star'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>29, 'tp'=>'star'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>30, 'tp'=>'star'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>3, 'tp'=>'author'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>4, 'tp'=>'author'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>5, 'tp'=>'author'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>6, 'tp'=>'author'},
                    {'x'=>1, 'y'=>96, 'width'=>344, 'height'=>294, 'index'=>7, 'tp'=>'author'},
                    {'x'=>1, 'y'=>1, 'width'=>344, 'height'=>395, 'index'=>8, 'tp'=>'author'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>9, 'tp'=>'author'},
                    {'x'=>0, 'y'=>0, 'width'=>346, 'height'=>480, 'index'=>10, 'tp'=>'author'}
                  ]
  
  def index
    @posts = Post.lmrb.paginate(:page=>params[:page], :per_page=>24, :total_entries=>1200, :order=>"created_at desc")
    now = Time.new
    @star_posts = Post.find(:all, :conditions=>"logo is not null and `from` like 'lama_%' and created_at > '#{now.ago(4.days).to_s(:db)}' and created_at < '#{now.to_s(:db)}'", :order=>"forward_posts_count*3 + comments_count*2 + claps_count desc", :limit=>3)
    @recent_posts = Post.lmrb.find(:all, :conditions=>"posts.logo is not null", :select=>"distinct(user_id), id, created_at", :order=>"created_at desc", :limit=>2)
  end
  
  def upload
    #if params[:myfile].class != File && params[:myfile].class != Tempfile        #上传失败
    #  render :text=>"<script>parent.upload_callback('A0004', '');</script>" and return;
    #end
  
    begin
      Magick::ImageList.new(params[:myfile].path)
    rescue Exception => err
      render :text=>"<script>parent.upload_callback('A0002', '#{params[:myfile].path}');</script>" and return;
    end
  
    if params[:myfile].size > 4*1024*1024
      render :text=>"<script>parent.upload_callback('A0003', '#{params[:myfile].path}');</script>" and return;
    end
  
    lama_upload = LamaUpload.new
    lama_upload.logo = params[:myfile]
    lama_upload.user_id = session[:uid]
    lama_upload.save

    `mkdir '#{::Rails.root.to_s}/public/lama/pic/#{Time.new.strftime('%Y-%m-%d')}'`
    desFileName = "/lama/pic/#{Time.new.strftime('%Y-%m-%d')}/#{Time.new.strftime('%m-%d-%H-%I-%S')}#{rand(10000)}.jpeg"
    localFileName = "#{::Rails.root.to_s}/public#{desFileName}"
    `mv #{params[:myfile].path} '#{localFileName}'`
    `convert #{localFileName} -resize 800x600 #{localFileName}`
    session[:pic] = desFileName
    src = Magick::Image::read(File.join(::Rails.root.to_s, 'public', session[:pic])).first
    session[:pic_height] = src.rows*230/src.columns

    render :text=>"<script>parent.upload_callback('A0001', '#{desFileName}');</script>" and return;
  end
  
  def step1
    redirect_to "/account/signup?origin_url=/lmrb/step1" if !@user
  end
  
  def step3
    session[:weather] = params[:weather]
    session[:mood] = params[:mood]
    session[:state] = params[:state]
  end
  
  def step4
    @model_areas = $picModelArea.dup
    @model_areas = @model_areas.delete_if{|area|
      area["from_url"].to_s != session[:from_url].to_s
    } if session[:from_url] && !%W(sntp tonghua).include?(session[:from_url])
  
    if %W(sntp tonghua).include?(session[:from_url])
      @model_areas = @model_areas.delete_if{|area|
        area["from_url"].to_s.size > 0
      }
    end
  end
  
  def preview
    #lama = Lama.find_by_uid(session[:uid])
    #babyNick = lama.babynick
    #lamaNick = lama.lamanick
    #babybirth = lama.babybirth
    #babyYear = detail_age_for_birthday2(lama.babybirth) 
    #specificDay = detail_age_for_birthday1(lama.babybirth) 
    
    babyNick = @user.first_kid ? @user.first_kid.name.to_s : ""
    lamaNick = @user.name
    babyYear = @user.first_kid ? detail_age_for_birthday2(@user.first_kid.birthday) : ""
    specificDay = @user.first_kid ? detail_age_for_birthday1(@user.first_kid.birthday) : ""
    
    
    
    ym = Time.new.strftime("%Y年%m月")
    d = Time.new.strftime("%d日")
    da = Time.new.strftime("%d")
    wordModel = [
       [  {'text'=>babyNick + "   "  + babyYear + specificDay,'font'=>'/font/yahei.TTF','x'=>'20','y'=>'130','size'=>'12','color'=>'black'},
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'18','y'=>'274','size'=>'15','color'=>'black'},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'18','y'=>'310','size'=>'17','color'=>'black'},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'18','y'=>'340','size'=>'16','color'=>'black'},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'18','y'=>'375','size'=>'15','color'=>'black'},
          {'text'=>Time.new.strftime("%Y.%m.%d"),'x'=>'278','y'=>'80','size'=>'9','color'=>'white'}
        ],      #1
        [
          {'text'=>babyNick + "   "  + babyYear + specificDay,'font'=>'/font/yahei.TTF','x'=>'20','y'=>'130','size'=>'12','color'=>'black'},
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'136','size'=>'16','color'=>'black', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'10','y'=>'104','size'=>'18','color'=>'black', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'10','y'=>'78','size'=>'16','color'=>'black', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'10','y'=>'45','size'=>'16','color'=>'black', 'gravity' => Magick::SouthEastGravity},
          {'text'=>Time.new.strftime("%Y.%m.%d"),'x'=>'278','y'=>'80','size'=>'9','color'=>'white'}
        ],      #2
        [
          {'text'=>babyNick + babyYear + specificDay,'font'=>'/font/yahei.TTF','x'=>'13','y'=>'260','size'=>'12','color'=>'black'},
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'294','size'=>'19','color'=>'#ED008C'},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'330','size'=>'16','color'=>'#89723D'},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'360','size'=>'13','color'=>'black'},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'395','size'=>'13','color'=>'black'},
          {'text'=>ym,'font'=>'/font/yaheijiacu.TTF','x'=>'257','y'=>'380','size'=>'12','color'=>'white'},
          {'text'=>d,'font'=>'/font/yaheijiacu.TTF','x'=>'276','y'=>'410','size'=>'17','color'=>'white'}
        ],      #3
        [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'305','size'=>'18','color'=>'#9F2780'},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'342','size'=>'19','color'=>'#FFCC00'},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'13','y'=>'375','size'=>'13','color'=>'white'},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'13','y'=>'411','size'=>'13','color'=>'white'},
          {'text'=>babyNick  + babyYear + specificDay,'font'=>'/font/yahei.TTF','x'=>'13','y'=>'265','size'=>'12','color'=>'black'},
          {'text'=>ym,'font'=>'/font/yahei.TTF','x'=>'252','y'=>'92','size'=>'13','color'=>'orange'},
          {'text'=>da,'font'=>'/font/yahei.TTF','x'=>'272','y'=>'129','size'=>'30','color'=>'orange'}
        ],      #4
        [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'310','size'=>'20','color'=>'#EF4C2C'},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'13','y'=>'342','size'=>'18','color'=>'white'},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'13','y'=>'375','size'=>'13','color'=>'#E6EF9B'},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'411','size'=>'14','color'=>'#AD904C'},
          {'text'=>babyNick  + babyYear + specificDay,'font'=>'/font/yahei.TTF','x'=>'13','y'=>'277','size'=>'12','color'=>'black'},
          {'text'=>ym,'font'=>'/font/yahei.TTF','x'=>'260','y'=>'375','size'=>'11','color'=>'orange'},
          {'text'=>da,'font'=>'/font/yahei.TTF','x'=>'275','y'=>'415','size'=>'32','color'=>'orange'}
        ],      #5
        [
          {'text'=>babyNick + babyYear + specificDay,'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'187','size'=>'12','color'=>'#AD904C'},
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'215','size'=>'17','color'=>'black'},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'242','size'=>'14','color'=>'black'},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'270','size'=>'13','color'=>'#AD904C'},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'300','size'=>'16','color'=>'#AD904C'},
          {'text'=>ym,'font'=>'/font/yahei.TTF','x'=>'285','y'=>'20','size'=>'8','color'=>'white'},
          {'text'=>da,'font'=>'/font/yahei.TTF','x'=>'306','y'=>'49','size'=>'23','color'=>'yellow'}
        ],      #6
        [
          {'text'=>params[:kaixin],'font'=>'/font/heiti.ttf','x'=>'15','y'=>'370','size'=>'21','color'=>'#ED008C'},
          {'text'=>params[:guanxin],'font'=>'/font/heiti.ttf','x'=>'15','y'=>'410','size'=>'17','color'=>'black'},
          {'text'=>params[:naoxin],'font'=>'/font/heiti.ttf','x'=>'15','y'=>'435','size'=>'15','color'=>'white'},
          {'text'=>params[:qushi],'font'=>'/font/heiti.ttf','x'=>'13','y'=>'465','size'=>'19','color'=>'black'},
          {'text'=>babyNick + babyYear + specificDay,'font'=>'/font/heiti.ttf','x'=>'22','y'=>'287','size'=>'12','color'=>'#ED008C'},
          {'text'=>ym,'font'=>'/font/heiti.ttf','x'=>'255','y'=>'156','size'=>'13','color'=>'#ED008C'},
          {'text'=>d,'font'=>'/font/heiti.ttf','x'=>'270','y'=>'135','size'=>'25','color'=>'#ED008C'}
        ],      #7
        [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'238','size'=>'21','color'=>'black'},
          {'text'=>params[:guanxin],'font'=>'/font/heiti.ttf','x'=>'13','y'=>'271','size'=>'17','color'=>'#827042'},
          {'text'=>params[:naoxin],'font'=>'/font/heiti.ttf','x'=>'13','y'=>'302','size'=>'15','color'=>'black'},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'335','size'=>'19','color'=>'#827042'},
          {'text'=>babyNick + babyYear+specificDay,'font'=>'/font/heiti.ttf','x'=>'13','y'=>'206','size'=>'12','color'=>'#827042'},
        ],      #8
        [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'310','size'=>'21','color'=>'#EF4C2C'},
          {'text'=>params[:guanxin],'font'=>'/font/heiti.ttf','x'=>'13','y'=>'342','size'=>'17','color'=>'#333333'},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'375','size'=>'20','color'=>'#EF4C2C'},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'411','size'=>'18','color'=>'#333333'},
          {'text'=>babyNick + ' ' + babyYear+specificDay,'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'277','size'=>'13','color'=>'#333333'},
          {'text'=>ym,'font'=>'/font/heiti.ttf','x'=>'258','y'=>'380','size'=>'13','color'=>'#EF4C2C'},
          {'text'=>da,'font'=>'/font/heiti.ttf','x'=>'260','y'=>'415','size'=>'30','color'=>'#EF4C2C'}
        ],      #9
        [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'310','size'=>'21','color'=>'#EF4C2C'},
          {'text'=>params[:guanxin],'font'=>'/font/heiti.ttf','x'=>'13','y'=>'342','size'=>'17','color'=>'#333333'},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'375','size'=>'20','color'=>'#EF4C2C'},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'411','size'=>'18','color'=>'#333333'},
          {'text'=>babyNick + ' ' + babyYear+specificDay,'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'277','size'=>'12','color'=>'#333333'},
          {'text'=>ym,'font'=>'/font/songti.TTC','x'=>'13','y'=>'100','size'=>'13','color'=>'#EF4C2C'},
          {'text'=>da,'font'=>'/font/yaheijiacu.TTF','x'=>'30','y'=>'130','size'=>'30','color'=>'#EF4C2C'}
        ],      #10
        [
          {'text'=>params[:kaixin],'font'=>'/font/youyuan.TTF','x'=>'23','y'=>'260','size'=>'14','color'=>'black'},
          {'text'=>params[:guanxin],'font'=>'/font/heiti.ttf','x'=>'22','y'=>'295','size'=>'18.34','color'=>'black'},
          {'text'=>params[:naoxin],'font'=>'/font/youyuan.TTF','x'=>'23','y'=>'322','size'=>'15','color'=>'black'},
          {'text'=>params[:qushi],'font'=>'/font/heiti.ttf','x'=>'23','y'=>'365','size'=>'22','color'=>'black'},
          {'text'=>'宝贝：' + babyNick,'font'=>'/font/heiti.ttf','x'=>'25','y'=>'145','size'=>'8','color'=>'black'},
          {'text'=>'辣妈：' + lamaNick,'font'=>'/font/heiti.ttf','x'=>'25','y'=>'165','size'=>'8','color'=>'black'},
          {'text'=>ym,'font'=>'/font/songti.TTC','x'=>'250','y'=>'20','size'=>'12','color'=>'red'},
          {'text'=>d,'font'=>'/font/heiti.ttf','x'=>'270','y'=>'42','size'=>'18','color'=>'red'},
          {'text'=>babyNick + babyYear,'font'=>'/font/songti.TTC','x'=>'250','y'=>'58','size'=>'10','color'=>'red'},
          {'text'=>specificDay,'font'=>'/font/songti.TTC','x'=>'250','y'=>'75','size'=>'10','color'=>'red'}
        ],        #11
        [
          {'text'=>params[:kaixin],'font'=>'/font/heiti.ttf','x'=>'16','y'=>'195','size'=>'16','color'=>'black'},
          {'text'=>params[:guanxin],'font'=>'/font/songti.TTC','x'=>'15','y'=>'225','size'=>'18','color'=>'#FF66FF'},
          {'text'=>params[:naoxin],'font'=>'/font/youyuan.TTF','x'=>'17','y'=>'250','size'=>'15','color'=>'black'},
          {'text'=>params[:qushi],'font'=>'/font/heiti.ttf','x'=>'15','y'=>'290','size'=>'20','color'=>'black'},
          {'text'=>'宝贝：' + babyNick,'font'=>'/font/youyuan.TTF','x'=>'5','y'=>'355','size'=>'13','color'=>'black','angle'=>'-12'},
          {'text'=>'辣妈：' + lamaNick,'font'=>'/font/youyuan.TTF','x'=>'5','y'=>'385','size'=>'13','color'=>'black','angle'=>'-12'},
          {'text'=>ym,'font'=>'/font/heiti.ttf','x'=>'240','y'=>'86','size'=>'13','color'=>'#FF66FF'},
          {'text'=>d,'font'=>'/font/heiti.ttf','x'=>'260','y'=>'115','size'=>'22','color'=>'#FF66FF'},
          {'text'=>babyNick + babyYear,'font'=>'/font/heiti.ttf','x'=>'248','y'=>'135','size'=>'11','color'=>'#FF66FF'},
          {'text'=>specificDay,'font'=>'/font/heiti.ttf','x'=>'240','y'=>'155','size'=>'11','color'=>'#FF66FF'}
        ],        #12
        [
          {'text'=>params[:kaixin],'font'=>'/font/songti.TTC','x'=>'10','y'=>'215','size'=>'16','color'=>'black'},
          {'text'=>params[:guanxin],'font'=>'/font/songti.TTC','x'=>'7','y'=>'250','size'=>'18.34','color'=>'#E01B88'},
          {'text'=>params[:naoxin],'font'=>'/font/youyuan.TTF','x'=>'7','y'=>'277','size'=>'14','color'=>'black'},
          {'text'=>params[:qushi],'font'=>'/font/heiti.ttf','x'=>'6','y'=>'320','size'=>'18','color'=>'#E01B88'},
          {'text'=>'宝贝：'+babyNick,'font'=>'/font/heiti.ttf','x'=>'10','y'=>'350','size'=>'12','color'=>'black'},
          {'text'=>'辣妈：'+lamaNick,'font'=>'/font/heiti.ttf','x'=>'10','y'=>'380','size'=>'12','color'=>'black'},
          {'text'=>ym,'font'=>'/font/songti.TTC','x'=>'250','y'=>'25','size'=>'11','color'=>'#E01B88'},
          {'text'=>d,'font'=>'/font/heiti.ttf','x'=>'270','y'=>'50','size'=>'20','color'=>'#E01B88'},
          {'text'=>babyNick + babyYear,'font'=>'/font/songti.TTC','x'=>'250','y'=>'73','size'=>'10','color'=>'#E01B88'},
          {'text'=>specificDay,'font'=>'/font/songti.TTC','x'=>'243','y'=>'93','size'=>'10','color'=>'#E01B88'}
        ],        #13
        [
          {'text'=>params[:kaixin],'font'=>'/font/songti.TTC','x'=>'16','y'=>'330','size'=>'18','color'=>'white'},
          {'text'=>params[:guanxin],'font'=>'/font/songti.TTC','x'=>'16','y'=>'405','size'=>'17','color'=>'black'},
          {'text'=>params[:naoxin],'font'=>'/font/youyuan.TTF','x'=>'16','y'=>'435','size'=>'20','color'=>'white'},
          {'text'=>params[:qushi],'font'=>'/font/heiti.ttf','x'=>'16','y'=>'465','size'=>'19','color'=>'black'},
          {'text'=>'宝贝：'+babyNick,'font'=>'/font/heiti.ttf','x'=>'20','y'=>'110','size'=>'12','color'=>'white'},
          {'text'=>'辣妈：'+lamaNick,'font'=>'/font/heiti.ttf','x'=>'20','y'=>'134','size'=>'12','color'=>'white'},
          {'text'=>ym,'font'=>'/font/heiti.ttf','x'=>'235','y'=>'15','size'=>'9','color'=>'white'},
          {'text'=>d,'font'=>'/font/heiti.ttf','x'=>'245','y'=>'40','size'=>'18','color'=>'white'},
          {'text'=>babyNick + babyYear,'font'=>'/font/heiti.ttf','x'=>'235','y'=>'56','size'=>'9','color'=>'white'},
          {'text'=>specificDay,'font'=>'/font/heiti.ttf','x'=>'235','y'=>'73','size'=>'9','color'=>'white'}
        ],        #14
        [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'24','y'=>'330','size'=>'26','color'=>'#81682D'},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'24','y'=>'360','size'=>'11','color'=>'#81682D'},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'24','y'=>'380','size'=>'11','color'=>'#81682D'},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'24','y'=>'400','size'=>'11','color'=>'#81682D'},
          {'text'=>Time.new.year.to_s,'font'=>'/font/yahei.TTF','x'=>'14','y'=>'74','size'=>'14','color'=>'#81682D'},
          {'text'=>Time.new.strftime("%m.%d"),'font'=>'/font/yahei.TTF','x'=>'60','y'=>'74','size'=>'14','color'=>'#81682D'},
          {'text'=>babyNick,'font'=>'/font/yaheijiacu.TTF','x'=>'24','y'=>'123','size'=>'16','color'=>'black'},
          {'text'=>babyYear + specificDay,'font'=>'/font/yahei.TTF','x'=>'24','y'=>'150','size'=>'9','color'=>'black'}
        ],        #15
        [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'20','y'=>'160','size'=>'26','color'=>'#cd2028', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'20','y'=>'126','size'=>'10','color'=>'#cd2028', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'20','y'=>'110','size'=>'10','color'=>'#cd2028', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'20','y'=>'94','size'=>'10','color'=>'#cd2028', 'gravity' => Magick::SouthEastGravity},
          {'text'=>Time.new.year.to_s,'font'=>'/font/yahei.TTF','x'=>'268','y'=>'40','size'=>'17','color'=>'#81682D', 'no_strike'=>true},
          {'text'=>Time.new.strftime("%m.%d"),'font'=>'/font/yahei.TTF','x'=>'270','y'=>'64','size'=>'17','color'=>'#81682D', 'no_strike'=>true}
        ],        #16
        [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'24','y'=>'280','size'=>'28','color'=>'black'},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'24','y'=>'310','size'=>'11','color'=>'black'},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'24','y'=>'330','size'=>'11','color'=>'black'},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'24','y'=>'350','size'=>'11','color'=>'black'},
          {'text'=>Time.new.year.to_s,'font'=>'/font/yahei.TTF','x'=>'268','y'=>'40','size'=>'17','color'=>'#81682D', 'no_strike'=>true},
          {'text'=>Time.new.strftime("%m.%d"),'font'=>'/font/yahei.TTF','x'=>'270','y'=>'64','size'=>'17','color'=>'#81682D', 'no_strike'=>true}
        ],        #17
        [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'24','y'=>'330','size'=>'26','color'=>'black'},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'24','y'=>'360','size'=>'11','color'=>'black'},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'24','y'=>'380','size'=>'11','color'=>'black'},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'24','y'=>'400','size'=>'11','color'=>'black'},
          {'text'=>Time.new.year.to_s,'font'=>'/font/yahei.TTF','x'=>'225','y'=>'105','size'=>'14','color'=>'white'},
          {'text'=>Time.new.strftime("%m.%d"),'font'=>'/font/yahei.TTF','x'=>'270','y'=>'105','size'=>'14','color'=>'white'},  
          {'text'=>babyNick,'font'=>'/font/yaheijiacu.TTF','x'=>'24','y'=>'190','size'=>'16','color'=>'black', 'no_strike'=>true},
        ],        #18
        [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'36','y'=>'160','size'=>'26','color'=>'#81682D', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'36','y'=>'126','size'=>'10','color'=>'#81682D', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'36','y'=>'110','size'=>'10','color'=>'#81682D', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'36','y'=>'94','size'=>'10','color'=>'#81682D', 'gravity' => Magick::SouthEastGravity},
          {'text'=>Time.new.year.to_s,'font'=>'/font/yahei.TTF','x'=>'2','y'=>'105','size'=>'16','color'=>'white', 'no_strike'=>true},
          {'text'=>Time.new.strftime("%m.%d"),'font'=>'/font/yahei.TTF','x'=>'50','y'=>'105','size'=>'16','color'=>'white', 'no_strike'=>true},
          {'text'=>babyNick,'font'=>'/font/heiti.ttf','x'=>'36','y'=>'200','size'=>'16','color'=>'#81682D', 'gravity' => Magick::SouthEastGravity, 'no_strike'=>true}
        ],        #19
        [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'350','size'=>'26','color'=>'white', 'no_strike'=>true},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'30','y'=>'374','size'=>'10','color'=>'#E0DACE'},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'30','y'=>'394','size'=>'10','color'=>'#E0DACE'},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'30','y'=>'414','size'=>'10','color'=>'#E0DACE'},
          {'text'=>Time.new.year.to_s,'font'=>'/font/yahei.TTF','x'=>'264','y'=>'40','size'=>'17','color'=>'white', 'no_strike'=>true},
          {'text'=>Time.new.strftime("%m.%d"),'font'=>'/font/yahei.TTF','x'=>'266','y'=>'64','size'=>'17','color'=>'white', 'no_strike'=>true},
          {'text'=>babyNick,'font'=>'/font/heiti.ttf','x'=>'220','y'=>'400','size'=>'16','color'=>'white'},
         ],       #20
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'4','y'=>'380','size'=>'20','color'=>'white', 'no_strike'=>true},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'8','y'=>'410','size'=>'14','color'=>'#E0DACE'},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'4','y'=>'442','size'=>'20','color'=>'#E0DACE'},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'8','y'=>'470','size'=>'13','color'=>'#E0DACE'},
          {'text'=>babyNick + " "  + babyYear + specificDay,'font'=>'/font/heiti.ttf','x'=>'4','y'=>'352','size'=>'12','color'=>'white'}
         ],       #21
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'17','y'=>'366','size'=>'15','color'=>'#EF4C2C'},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'17','y'=>'395','size'=>'16','color'=>'#EF4C2C'},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'17','y'=>'426','size'=>'17','color'=>'#EF4C2C'},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'17','y'=>'454','size'=>'15','color'=>'#EF4C2C'},
          {'text'=>Time.new.strftime("%d"),'font'=>'/font/yaheijiacu.TTF','x'=>'26','y'=>'100','size'=>'18','color'=>'white', 'no_strike'=>true},
          {'text'=>Time.new.strftime("%y年") + "#{Time.new.mon}月",'font'=>'/font/yahei.TTF','x'=>'13','y'=>'117','size'=>'9','color'=>'white', 'no_strike'=>true}
         ],       #22
         [
          {'text'=>params[:kaixin],'font'=>'/font/heiti.ttf','x'=>'15','y'=>'324','size'=>'13','color'=>'white'},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'15','y'=>'351','size'=>'16','color'=>'#EF4C2C'},
          {'text'=>params[:naoxin],'font'=>'/font/heiti.ttf','x'=>'15','y'=>'384','size'=>'13','color'=>'white'},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'15','y'=>'409','size'=>'16','color'=>'#EF4C2C'},
          {'text'=>ym,'font'=>'/font/heiti.ttf','x'=>'9','y'=>'97','size'=>'11','color'=>'#EF4C2C'},
          {'text'=>Time.new.strftime("%d"),'font'=>'/font/yaheijiacu.TTF','x'=>'15','y'=>'120','size'=>'26','color'=>'#EF4C2C', 'no_strike'=>true}
         ],       #23
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'413','size'=>'18','color'=>'black'},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'13','y'=>'381','size'=>'20','color'=>'#EF4C2C'},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'13','y'=>'348','size'=>'18','color'=>'black'},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'13','y'=>'318','size'=>'20','color'=>'#EF4C2C'},
          {'text'=>Time.new.strftime("%m年") + Time.new.day.to_s + "月",'font'=>'/font/heiti.ttf','x'=>'16','y'=>'145','size'=>'9','color'=>'white'},
          {'text'=>Time.new.strftime("%d"),'font'=>'/font/yaheijiacu.TTF','x'=>'20','y'=>'128','size'=>'24','color'=>'white', 'no_strike'=>true},
          {'text'=>babyNick +  babyYear + specificDay,'font'=>'/font/heiti.ttf','x'=>'13','y'=>'290','size'=>'13','color'=>'black'}
         ],       #24
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'170','size'=>'20','color'=>'#EAA82E', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'140','size'=>'20','color'=>'#EAA82E', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'10','y'=>'110','size'=>'20','color'=>'#EAA82E', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'80','size'=>'20','color'=>'#EAA82E', 'gravity' => Magick::SouthEastGravity},
          {'text'=>ym,'font'=>'/font/heiti.ttf','x'=>'12','y'=>'119','size'=>'13','color'=>'white'},
          {'text'=>Time.new.strftime("%d"),'font'=>'/font/yaheijiacu.TTF','x'=>'24','y'=>'143','size'=>'26','color'=>'white', 'no_strike'=>true}
         ],       #25
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'12','y'=>'310','size'=>'20','color'=>'#EF4C2C'},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'12','y'=>'342','size'=>'20','color'=>'#FFCC00'},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'12','y'=>'372','size'=>'20','color'=>'#EF4C2C'},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'12','y'=>'401','size'=>'20','color'=>'#FFCC00'},
          {'text'=>ym,'font'=>'/font/heiti.ttf','x'=>'12','y'=>'84','size'=>'13','color'=>'white'},
          {'text'=>Time.new.strftime("%d"),'font'=>'/font/yaheijiacu.TTF','x'=>'24','y'=>'108','size'=>'26','color'=>'white', 'no_strike'=>true}
         ],       #26
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'14','y'=>'380','size'=>'18','color'=>'white', 'no_strike'=>true},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'14','y'=>'408','size'=>'16','color'=>'white'},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'14','y'=>'435','size'=>'18','color'=>'white'},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'14','y'=>'460','size'=>'18','color'=>'white'},
          {'text'=>ym,'font'=>'/font/heiti.ttf','x'=>'12','y'=>'108','size'=>'13','color'=>'white'},
          {'text'=>Time.new.strftime("%d"),'font'=>'/font/yaheijiacu.TTF','x'=>'24','y'=>'132','size'=>'26','color'=>'white', 'no_strike'=>true},
          {'text'=>babyNick +  babyYear + specificDay,'font'=>'/font/heiti.ttf','x'=>'18','y'=>'352','size'=>'13','color'=>'black'}
         ],       #27
         [
          {'text'=>params[:kaixin],'font'=>'/font/heiti.ttf','x'=>'10','y'=>'269','size'=>'18','color'=>'black'},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'304','size'=>'22','color'=>'#EF4C2C'},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'10','y'=>'337','size'=>'17','color'=>'white'},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'364','size'=>'18','color'=>'#EF4C2C'},
          {'text'=>'宝贝：'+babyNick,'font'=>'/font/heiti.ttf','x'=>'10','y'=>'389','size'=>'12','color'=>'black'},
          {'text'=>'辣妈：'+lamaNick,'font'=>'/font/heiti.ttf','x'=>'10','y'=>'411','size'=>'12','color'=>'black'},
          {'text'=>ym,'font'=>'/font/heiti.ttf','x'=>'12','y'=>'118','size'=>'13','color'=>'black'},
          {'text'=>Time.new.strftime("%d"),'font'=>'/font/yaheijiacu.TTF','x'=>'24','y'=>'142','size'=>'26','color'=>'black', 'no_strike'=>true}
         ],       #28
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'11','y'=>'374','size'=>'17','color'=>'#666666'},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'11','y'=>'401','size'=>'15','color'=>'#666666'},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'11','y'=>'432','size'=>'17','color'=>'#666666'},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'11','y'=>'460','size'=>'15','color'=>'#666666'},
          {'text'=>Time.new.year.to_s,'font'=>'/font/yahei.TTF','x'=>'264','y'=>'40','size'=>'17','color'=>'white', 'no_strike'=>true},
          {'text'=>Time.new.strftime("%m.%d"),'font'=>'/font/yahei.TTF','x'=>'266','y'=>'64','size'=>'17','color'=>'white', 'no_strike'=>true},
          {'text'=>"宝贝："+ babyNick,'font'=>'/font/heiti.ttf','x'=>'11','y'=>'347','size'=>'12','color'=>'#C19258'}
         ],       #29
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'280','size'=>'16','color'=>'white', 'no_strike'=>true},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'306','size'=>'14','color'=>'white', 'no_strike'=>true},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'332','size'=>'16','color'=>'white', 'no_strike'=>true},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'358','size'=>'16','color'=>'white', 'no_strike'=>true},
          {'text'=>Time.new.strftime("%d"),'font'=>'/font/yaheijiacu.TTF','x'=>'7','y'=>'46','size'=>'30','color'=>'yellow', 'no_strike'=>true,'gravity' => Magick::SouthEastGravity},
          {'text'=>Time.new.strftime("%Y年") + Time.new.mon.to_s + "月",'font'=>'/font/heiti.TTF','x'=>'4','y'=>'16','size'=>'10','color'=>'white', 'gravity' => Magick::SouthEastGravity},
          {'text'=>babyNick +  babyYear + specificDay,'font'=>'/font/heiti.ttf','x'=>'10','y'=>'260','size'=>'13','color'=>'white'}
         ],       #30
         [
          {'text'=>params[:kaixin],'font'=>'/font/yahei.TTF','x'=>'10','y'=>'120','size'=>'13','color'=>'black', 'no_strike'=>true, 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'10','y'=>'100','size'=>'13','color'=>'black', 'no_strike'=>true, 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'10','y'=>'80','size'=>'13','color'=>'black', 'no_strike'=>true, 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'10','y'=>'60','size'=>'13','color'=>'black', 'no_strike'=>true, 'gravity' => Magick::SouthEastGravity}
         ],       #31
         [
          {'text'=>params[:kaixin],'font'=>'/font/yahei.TTF','x'=>'42','y'=>'178','size'=>'13','color'=>'#DD37E1'},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'42','y'=>'204','size'=>'13','color'=>'#DD37E1'},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'42','y'=>'228','size'=>'13','color'=>'#DD37E1'},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'42','y'=>'251','size'=>'13','color'=>'#DD37E1'}
         ],         #32
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'352','size'=>'13','color'=>'black'},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'10','y'=>'384','size'=>'13','color'=>'white'},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'416','size'=>'13','color'=>'#5B5B5B'},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'10','y'=>'450','size'=>'13','color'=>'white'},
          {'text'=>babyNick +  babyYear + specificDay,'font'=>'/font/heiti.ttf','x'=>'150','y'=>'45','size'=>'13','color'=>'white'}
         ],         #33
         [
          {'text'=>params[:kaixin],'font'=>'/font/yahei.TTF','x'=>'40','y'=>'382','size'=>'13','color'=>'white'},
          {'text'=>params[:guanxin],'font'=>'/font/yahei.TTF','x'=>'40','y'=>'412','size'=>'13','color'=>'white'},
          {'text'=>params[:naoxin],'font'=>'/font/yahei.TTF','x'=>'40','y'=>'441','size'=>'13','color'=>'white'},
          {'text'=>params[:qushi],'font'=>'/font/yahei.TTF','x'=>'40','y'=>'468','size'=>'13','color'=>'white'},
          {'text'=>"今日",'font'=>'/font/heiti.ttf','x'=>'15','y'=>'354','size'=>'25','color'=>'white'},
          {'text'=>da,'font'=>'/font/heiti.ttf','x'=>'277','y'=>'450','size'=>'33','color'=>'white'},
          {'text'=>ym,'font'=>'/font/heiti.ttf','x'=>'257','y'=>'468','size'=>'12','color'=>'white'}
         ],         #34
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'15','y'=>'310','size'=>'15','color'=>'black'},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'15','y'=>'342','size'=>'20','color'=>'#FF0080'},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'15','y'=>'374','size'=>'20','color'=>'black'},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'15','y'=>'402','size'=>'15','color'=>'#FF0080'},
          {'text'=>"今日记录",'font'=>'/font/heiti.ttf','x'=>'10','y'=>'290','size'=>'28','color'=>'#FF0080'},
          {'text'=>ym,'font'=>'/font/heiti.ttf','x'=>'262','y'=>'20','size'=>'10','color'=>'#FF0080'},
          {'text'=>d,'font'=>'/font/heiti.ttf','x'=>'276','y'=>'42','size'=>'18','color'=>'#FF0080'},
          {'text'=>babyNick +  babyYear,'font'=>'/font/heiti.ttf','x'=>'274','y'=>'58','size'=>'10','color'=>'#FF0080'},
          {'text'=>specificDay,'font'=>'/font/heiti.ttf','x'=>'270','y'=>'73','size'=>'10','color'=>'#FF0080'}
         ],         #35
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'177','size'=>'18','color'=>'black', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'150','size'=>'22','color'=>'#FF2020', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'118','size'=>'25','color'=>'black', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'85','size'=>'18','color'=>'#FF2020', 'gravity' => Magick::SouthEastGravity},
          {'text'=>ym,'font'=>'/font/heiti.ttf','x'=>'13','y'=>'128','size'=>'12','color'=>'black'},
          {'text'=>da,'font'=>'/font/heitijiacu.ttf','x'=>'20','y'=>'173','size'=>'40','color'=>'black'},
          {'text'=>babyNick +  babyYear + specificDay,'font'=>'/font/heiti.ttf','x'=>'10','y'=>'201','size'=>'13','color'=>'red', 'gravity' => Magick::SouthEastGravity}
         ],         #36
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'120','size'=>'12','color'=>'white', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'91','size'=>'13','color'=>'#005AB5', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'64','size'=>'11','color'=>'white', 'gravity' => Magick::SouthEastGravity},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'36','size'=>'13','color'=>'#005AB5', 'gravity' => Magick::SouthEastGravity},
          {'text'=>babyNick +  babyYear + specificDay,'font'=>'/font/heiti.ttf','x'=>'20','y'=>'147','size'=>'13','color'=>'#004B97', 'gravity' => Magick::SouthEastGravity},
          {'text'=>da,'font'=>'/font/heiti.ttf','x'=>'33','y'=>'120','size'=>'40','color'=>'white'},
          {'text'=>ym,'font'=>'/font/yahei.TTF','x'=>'13','y'=>'130','size'=>'14','color'=>'white'}
         ],         #37
         [
          {'text'=>"开心的事："+params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'327','size'=>'13','color'=>'white'},
          {'text'=>"关心的事："+params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'404','size'=>'13','color'=>'black'},
          {'text'=>"闹心的事："+params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'15','y'=>'426','size'=>'13','color'=>'white'},
          {'text'=>"有趣的事："+params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'450','size'=>'13','color'=>'black'},
          {'text'=>ym,'font'=>'/font/yahei.TTF','x'=>'276','y'=>'14','size'=>'9','color'=>'white'},
          {'text'=>d,'font'=>'/font/heiti.ttf','x'=>'292','y'=>'42','size'=>'20','color'=>'white'},
          {'text'=>babyNick +  babyYear,'font'=>'/font/heiti.ttf','x'=>'288','y'=>'57','size'=>'11','color'=>'white'},
          {'text'=>specificDay,'font'=>'/font/heiti.ttf','x'=>'286','y'=>'76','size'=>'11','color'=>'white'}
         ],         #38
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'368','size'=>'15','color'=>'#3C3C3C'},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'395','size'=>'20','color'=>'white'},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'423','size'=>'20','color'=>'#3C3C3C'},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'450','size'=>'15','color'=>'white'},
          {'text'=>babyNick + babyYear + specificDay,'font'=>'/font/songti.TTC','x'=>'97','y'=>'86','size'=>'13','color'=>'white'}
         ],         #39
         [
          {'text'=>params[:kaixin],'font'=>'/font/yaheijiacu.TTF','x'=>'15','y'=>'378','size'=>'15','color'=>'white'},
          {'text'=>params[:guanxin],'font'=>'/font/yaheijiacu.TTF','x'=>'26','y'=>'409','size'=>'15','color'=>'white'},
          {'text'=>params[:naoxin],'font'=>'/font/yaheijiacu.TTF','x'=>'13','y'=>'438','size'=>'15','color'=>'white'},
          {'text'=>params[:qushi],'font'=>'/font/yaheijiacu.TTF','x'=>'10','y'=>'465','size'=>'15','color'=>'white'},
          {'text'=>"今日",'font'=>'/font/heiti.ttf','x'=>'15','y'=>'352','size'=>'25','color'=>'black'},
          {'text'=>da,'font'=>'/font/heiti.ttf','x'=>'280','y'=>'390','size'=>'33','color'=>'black'},
          {'text'=>ym,'font'=>'/font/heiti.ttf','x'=>'260','y'=>'408','size'=>'13','color'=>'black'}
         ]        #40
      ]
      
      picModelSmall = [
          [ {'path'=>session[:weather],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:mood],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:state],'x'=>'10000','y'=>'10000'}
          ],    #1
          [
            {'path'=>session[:weather],'x'=>'10000','y'=>'1000'},
            {'path'=>session[:mood],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:state],'x'=>'10000','y'=>'10000'}
          ],    #2
          [
            {'path'=>session[:weather],'x'=>'13','y'=>'406'},
            {'path'=>session[:mood],'x'=>'63','y'=>'406'},
            {'path'=>session[:state],'x'=>'113','y'=>'406'}
          ],      #3
          [
            {'path'=>session[:weather],'x'=>'13','y'=>'424'},
            {'path'=>session[:mood],'x'=>'63','y'=>'424'},
            {'path'=>session[:state],'x'=>'113','y'=>'424'}
          ],      #4
          [
            {'path'=>session[:weather],'x'=>'13','y'=>'429'},
            {'path'=>session[:mood],'x'=>'63','y'=>'429'},
            {'path'=>session[:state],'x'=>'113','y'=>'429'}
          ],      #5
          [
            {'path'=>session[:weather],'x'=>'193','y'=>'429'},
            {'path'=>session[:mood],'x'=>'243','y'=>'429'},
            {'path'=>session[:state],'x'=>'293','y'=>'429'}
          ],      #6
          [
            {'path'=>session[:weather],'x'=>'13','y'=>'297'},
            {'path'=>session[:mood],'x'=>'63','y'=>'297'},
            {'path'=>session[:state],'x'=>'113','y'=>'297'}
          ],      #7
          [
            {'path'=>session[:weather],'x'=>'13','y'=>'347'},
            {'path'=>session[:mood],'x'=>'63','y'=>'347'},
            {'path'=>session[:state],'x'=>'113','y'=>'347'}
          ],    #8
          [
            {'path'=>session[:weather],'x'=>'13','y'=>'429'},
            {'path'=>session[:mood],'x'=>'63','y'=>'429'},
            {'path'=>session[:state],'x'=>'113','y'=>'429'}
          ],    #9
          [
            {'path'=>session[:weather],'x'=>'13','y'=>'429'},
            {'path'=>session[:mood],'x'=>'63','y'=>'429'},
            {'path'=>session[:state],'x'=>'113','y'=>'429'}
          ],    #10
          [
            {'path'=>session[:weather],'x'=>'192','y'=>'420'},
            {'path'=>session[:mood],'x'=>'242','y'=>'420'},
            {'path'=>session[:state],'x'=>'292','y'=>'420'}
          ],      #11
          [
            {'path'=>session[:weather],'x'=>'177','y'=>'400'},
            {'path'=>session[:mood],'x'=>'227','y'=>'400'},
            {'path'=>session[:state],'x'=>'277','y'=>'400'}
          ],    #12
          [
            {'path'=>session[:weather],'x'=>'192','y'=>'420'},
            {'path'=>session[:mood],'x'=>'242','y'=>'420'},
            {'path'=>session[:state],'x'=>'292','y'=>'420'}
          ],      #13
          [
            {'path'=>session[:weather],'x'=>'87','y'=>'340'},
            {'path'=>session[:mood],'x'=>'138','y'=>'340'},
            {'path'=>session[:state],'x'=>'190','y'=>'340'}
          ],      #14   
          [ {'path'=>session[:weather],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:mood],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:state],'x'=>'10000','y'=>'10000'}
          ],      #15
          [ {'path'=>session[:weather],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:mood],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:state],'x'=>'10000','y'=>'10000'}
          ],      #16
          [ {'path'=>session[:weather],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:mood],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:state],'x'=>'10000','y'=>'10000'}
          ],    #17
          [ {'path'=>session[:weather],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:mood],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:state],'x'=>'10000','y'=>'10000'}
          ],    #18
          [ {'path'=>session[:weather],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:mood],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:state],'x'=>'10000','y'=>'10000'}
          ],    #19
          [ {'path'=>session[:weather],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:mood],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:state],'x'=>'10000','y'=>'10000'}
          ],    #20
          [
            {'path'=>session[:weather],'x'=>'9','y'=>'287'},
            {'path'=>session[:mood],'x'=>'61','y'=>'287'},
            {'path'=>session[:state],'x'=>'113','y'=>'287'}
          ],    #21
          [
            {'path'=>session[:weather],'x'=>'16','y'=>'305'},
            {'path'=>session[:mood],'x'=>'68','y'=>'305'},
            {'path'=>session[:state],'x'=>'120','y'=>'305'}
          ],    #22
          [
            {'path'=>session[:weather],'x'=>'12','y'=>'426'},
            {'path'=>session[:mood],'x'=>'67','y'=>'426'},
            {'path'=>session[:state],'x'=>'119','y'=>'426'}
          ],    #23
          [
            {'path'=>session[:weather],'x'=>'12','y'=>'430'},
            {'path'=>session[:mood],'x'=>'64','y'=>'430'},
            {'path'=>session[:state],'x'=>'116','y'=>'430'}
          ],    #24
          [
            {'path'=>session[:weather],'x'=>'12','y'=>'425'},
            {'path'=>session[:mood],'x'=>'64','y'=>'425'},
            {'path'=>session[:state],'x'=>'116','y'=>'425'}
          ],    #25
          [
            {'path'=>session[:weather],'x'=>'12','y'=>'425'},
            {'path'=>session[:mood],'x'=>'64','y'=>'425'},
            {'path'=>session[:state],'x'=>'116','y'=>'425'}
          ],      #26
          [
            {'path'=>session[:weather],'x'=>'190','y'=>'429'},
            {'path'=>session[:mood],'x'=>'242','y'=>'429'},
            {'path'=>session[:state],'x'=>'294','y'=>'429'}
          ],    #27
          [
            {'path'=>session[:weather],'x'=>'12','y'=>'425'},
            {'path'=>session[:mood],'x'=>'64','y'=>'425'},
            {'path'=>session[:state],'x'=>'116','y'=>'425'}
          ],    #28
          [
            {'path'=>session[:weather],'x'=>'12','y'=>'285'},
            {'path'=>session[:mood],'x'=>'64','y'=>'285'},
            {'path'=>session[:state],'x'=>'116','y'=>'285'}
          ],    #29
          [
            {'path'=>session[:weather],'x'=>'12','y'=>'425'},
            {'path'=>session[:mood],'x'=>'64','y'=>'425'},
            {'path'=>session[:state],'x'=>'116','y'=>'425'}
          ],     #30
          [
            {'path'=>session[:weather],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:mood],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:state],'x'=>'10000','y'=>'10000'}
          ],     #31
          [
            {'path'=>session[:weather],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:mood],'x'=>'10000','y'=>'10000'},
            {'path'=>session[:state],'x'=>'10000','y'=>'10000'}
          ],     #32
          [
            {'path'=>session[:weather],'x'=>'7','y'=>'286'},
            {'path'=>session[:mood],'x'=>'57','y'=>'286'},
            {'path'=>session[:state],'x'=>'107','y'=>'286'}
          ],     #33
          [
            {'path'=>session[:weather],'x'=>'75','y'=>'318'},
            {'path'=>session[:mood],'x'=>'128','y'=>'318'},
            {'path'=>session[:state],'x'=>'180','y'=>'318'}
          ],     #34
          [
            {'path'=>session[:weather],'x'=>'188','y'=>'430'},
            {'path'=>session[:mood],'x'=>'238','y'=>'430'},
            {'path'=>session[:state],'x'=>'288','y'=>'430'}
          ],     #35
          [
            {'path'=>session[:weather],'x'=>'192','y'=>'415'},
            {'path'=>session[:mood],'x'=>'242','y'=>'415'},
            {'path'=>session[:state],'x'=>'292','y'=>'415'}
          ],     #36
          [
            {'path'=>session[:weather],'x'=>'194','y'=>'280'},
            {'path'=>session[:mood],'x'=>'244','y'=>'280'},
            {'path'=>session[:state],'x'=>'294','y'=>'280'}
          ],     #37
          [
            {'path'=>session[:weather],'x'=>'82','y'=>'345'},
            {'path'=>session[:mood],'x'=>'132','y'=>'345'},
            {'path'=>session[:state],'x'=>'182','y'=>'345'}
          ],     #38
          [
            {'path'=>session[:weather],'x'=>'8','y'=>'306'},
            {'path'=>session[:mood],'x'=>'58','y'=>'306'},
            {'path'=>session[:state],'x'=>'108','y'=>'306'}
          ],     #39
          [
            {'path'=>session[:weather],'x'=>'75','y'=>'315'},
            {'path'=>session[:mood],'x'=>'128','y'=>'315'},
            {'path'=>session[:state],'x'=>'180','y'=>'315'}
          ]     #40
      ]
     
      
      if params[:ajax] != "true"
        #生成大白布
        img = Magick::Image.new(346, 480)  
        for area in $picModelArea
          model = area if area['index'] == params[:model].to_i
        end
      
        #先裁图
        src = Magick::Image::read(File.join(::Rails.root.to_s, 'public', session[:pic])).first 
        size = src.columns
        x1 = params[:x1].to_i * size / 221
        x2 = params[:x2].to_i * size / 221
        y1 = params[:y1].to_i * size / 221
        y2 = params[:y2].to_i * size / 221
        src.crop!(x1, y1, x2-x1, y2-y1, true)
        src = src.resize(model['width'].to_i, model['height'].to_i)
        
        #lomo效果
        if params[:lomo] == "1"
          src = src.contrast
          lomo_mask = Magick::Image::read(File.join(::Rails.root.to_s, 'public/images', "lomo_mask.png")).first
          src = src.composite(lomo_mask, Magick::NorthWestGravity, 0, 0,Magick::MultiplyCompositeOp)
        end
        
        #叠加
        img = img.composite(src, Magick::NorthWestGravity, model['x'].to_i, model['y'].to_i,Magick::OverCompositeOp)
        
        #加半透明背景图
        src = Magick::Image.read(::Rails.root.to_s + "/public/lama/pic_model/m#{params[:model]||1}.png")[0]
        img = img.composite(src, Magick::NorthWestGravity, 0, 0, Magick::OverCompositeOp)
      else
        if params[:lomo] == "1"
          lomo_mask = Magick::Image::read(File.join(::Rails.root.to_s, 'public/images', "lomo_mask.png")).first
          img = Magick::Image.read(::Rails.root.to_s + "/public/lama/pic_model/m#{params[:model]||1}.png")[0]   
          img = lomo_mask.composite(img, Magick::NorthWestGravity, 0, 0,Magick::OverCompositeOp)
        else
          img = Magick::Image.read(::Rails.root.to_s + "/public/lama/pic_model/m#{params[:model]||1}.png")[0]       
        end
        
      end  
      
      #叠加文字
      gc = Magick::Draw.new
      for text in wordModel[params[:model].to_i-1]
          gc.annotate(img, 0, 0, text['x'].to_i+1, text['y'].to_i-text['size'].to_i-1, text["text"]) do
              self.pointsize  = text['size'].to_i + 3
              self.font       = ::Rails.root.to_s + "/public" + text['font'] if text['font']
              self.font_weight= Magick::BoldWeight
              self.fill       = "white"
              self.gravity    = Magick::NorthWestGravity
              self.rotation   = text['angle'].to_i if text['angle']   #旋转
              self.gravity    = Magick::NorthWestGravity
              self.gravity    = text['gravity'] if text['gravity'] 
              self.font_stretch = text['font_stretch'] if text['font_stretch']
          end if text["text"].size > 0 && text["size"].to_i > 14 && text["color"] != "white" && !text["no_strike"]
          
          gc.annotate(img, 0, 0, text['x'].to_i, text['y'].to_i-text['size'].to_i-2, text["text"]) do
              self.pointsize  = text['size'].to_i + 3
              self.font       = ::Rails.root.to_s + "/public" + text['font'] if text['font']
              self.font_weight= Magick::BoldWeight
              self.fill       = text['color']
              self.gravity    = Magick::NorthWestGravity
              self.rotation   = text['angle'].to_i if text['angle']   #旋转
              self.gravity    = Magick::NorthWestGravity
              self.gravity    = text['gravity'] if text['gravity'] 
              self.font_stretch = text['font_stretch'] if text['font_stretch']
          end if text["text"].size > 0
          
      end
      
      #叠加小图
      small_models = picModelSmall[params[:model].to_i - 1]
      model = small_models[0]
      src = Magick::Image.read(::Rails.root.to_s + "/public/lama/pic_model/#{model['path'].to_i + 1}.png")[0]
      img = img.composite(src, Magick::NorthWestGravity, model['x'].to_i, model['y'].to_i, Magick::OverCompositeOp)
      
      model = small_models[1]
      src = Magick::Image.read(::Rails.root.to_s + "/public/lama/pic_model/#{model['path'].to_i + 5}.png")[0]
      img = img.composite(src, Magick::NorthWestGravity, model['x'].to_i, model['y'].to_i, Magick::OverCompositeOp)
      
      model = small_models[2]
      src = Magick::Image.read(::Rails.root.to_s + "/public/lama/pic_model/#{model['path'].to_i + 9}.png")[0]
      img = img.composite(src, Magick::NorthWestGravity, model['x'].to_i, model['y'].to_i, Magick::OverCompositeOp)
      
      time_str = Time.new.strftime('%Y-%m-%d')
      hour = Time.new.hour
      if params[:ajax] != "true"
        `mkdir '#{::Rails.root.to_s}/public/lama/pic_sub/#{time_str}'`
        `mkdir '#{::Rails.root.to_s}/public/lama/pic_sub/#{time_str}/#{hour}'`
        path = "/lama/pic_sub/#{time_str}/#{hour}/#{session[:uid]}_#{Time.new.strftime('%Y%m%d%H%I%S')}.jpg"
        img.write File.join(::Rails.root.to_s, 'public', path) 
        
        logo = File.open(File.join(::Rails.root.to_s, 'public', path))
        @diary = Lamadiary.new
        @diary.uid = session[:uid]
        @diary.pic_path = logo
        @diary.ctime = Time.new
        @diary.weather = [session[:weather], session[:mood], session[:state]].join(',')
        @diary.kaixin = params[:kaixin]
        @diary.guanxin = params[:guanxin]
        @diary.naoxin = params[:naoxin]
        @diary.qushi = params[:qushi]
        @diary.from  = 'lama'
        @diary.save
        logo.close
      else
        `mkdir '#{::Rails.root.to_s}/public/lama/pic_trail/#{time_str}'`
        `mkdir '#{::Rails.root.to_s}/public/lama/pic_trail/#{time_str}/#{hour}'`
        path = "/lama/pic_trail/#{time_str}/#{hour}/#{session[:uid]}_#{Time.new.strftime('%Y%m%d%H%I%S')}.png"
        img.write File.join(::Rails.root.to_s, 'public', path)
        render :text=>path and return
      end
      @pic_path = path
      
      @tip = "#辣妈日报#每天一张我的报！今天我的辣妈日报出品了！：）#{[params[:kaixin], params[:guanxin], params[:naoxin], params[:qushi]].join("，")}"
      if session[:from_url] == "vkid"
        @tip = "@摄影师辣妈 @微童星官方微博 @妈妈晒 @妈咪宝贝传媒 @酷6母婴  联手打造微博时代小明星~~~#微童星# 主角 #{lama.babynick} #{ApplicationHelper::detail_age_for_birthday(lama.babybirth)} 我为我家宝贝也报名参加《微童星》了，家长们要赶紧哦 http://vkid.mamashai.com"
      elsif session[:from_url] == "sntp"
        @tip = "#苏诺彩色精灵#我是#{lama.babynick}，我是苏诺（颜色自填）精灵，嘿嘿，给你点颜色看看！你是什么颜色的？来跟我PK吧！@苏诺童品 @妈妈晒 @辣妈日报"
      elsif session[:from_url] == "tongqu"
        @tip = "#中秋晒团圆#这是我和爸爸妈妈一起过的第n个中秋节，晒个小团圆小幸福咯！@童趣出版 @妈妈晒 @辣妈日报"
      elsif session[:from_url] == "tonghua"
        @tip = "#秋天的童话#和爸爸妈妈一起，寻找秋天最美的童话，迷失在2011年的xx(地点)"
      elsif session[:from_url] == "princess"
        i = params[:model].to_i-1
        i = 0 if i < 0
        @tip = "我参加了#国际#{['小公主', '小王子'][i]}大赛#，@国际小公主 @辣妈日报 @妈妈晒 @西玛拉亚童装 @中国国际童模库 宝宝昵称: #{lama.babynick} 宝宝年龄: #{ApplicationHelper::detail_age_for_birthday(lama.babybirth)}"
      end
  end
  
  def create_post
    diary = Lamadiary.find(params[:id])
    
    @post = Post.new
    @post.content = params[:content]
    @post.logo = diary.pic_path
    @post.user_id = @user.id
    @post.from = 'lama_web'
    @post.from_id = diary.id
    @post.sina_weibo_id = -1 if params[:sina_weibo_id] == "-1"
    @post.tencent_weibo_id = -1 if params[:tencent_weibo_id] == "-1"
    @post.save
    
    render :text=>"转晒成功"
  end
  
private
  def detail_age_for_birthday1(birthday, today=Date.today)
    return '出生' if birthday.today?
    return '出生' if birthday.year == today.year && birthday.month == today.month && birthday.day == today.day
    str = ''
    motn_days = {1=>31,2=>28,3=>31,4=>30,5=>31,6=>30,7=>31,8=>31,9=>30,10=>31,11=>30,12=>31}
    if birthday
      if today < birthday 
        pregnant_day = birthday - 280 
        birthday = pregnant_day
      end
      months = today.month - birthday.month
      years = today.year - birthday.year
      days = today.day - birthday.day
      if today >= birthday 
        if days < 0
          months -=1
          days = motn_days[today.month] + days
        end
        if months < 0
          years -=1
          months = 12 + months
        end
        
        str = ""
        str << "孕" if today < birthday
        str << "#{months}个月" if months > 0
        str << "#{days}天" if days > 0
      end
    end
    str
  end 
  
  def detail_age_for_birthday2(birthday, today=Date.today)
    return '出生' if birthday.today?
    return '出生' if birthday.year == today.year && birthday.month == today.month && birthday.day == today.day
    str = ''
    motn_days = {1=>31,2=>28,3=>31,4=>30,5=>31,6=>30,7=>31,8=>31,9=>30,10=>31,11=>30,12=>31}
    if birthday
      if today < birthday 
        pregnant_day = birthday - 280 
        birthday = pregnant_day
      end
      months = today.month - birthday.month
      years = today.year - birthday.year
      days = today.day - birthday.day
      if today >= birthday 
        if days < 0
          months -=1
          days = motn_days[today.month] + days
        end
        if months < 0
          years -=1
          months = 12 + months
        end
        
        str = ""
        str << "#{years}岁" if years > 0
      end
    end
    str
  end
end
