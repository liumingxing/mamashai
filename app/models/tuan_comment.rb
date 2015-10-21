class TuanComment < ActiveRecord::Base
  belongs_to :tuan, :counter_cache => true
  belongs_to :tuan_website, :counter_cache => true
  belongs_to :user
  belongs_to :gou, :counter_cache => true, :foreign_key=>"kind_id"
  #belongs_to :gou_brand, :counter_cache => true
#  belongs_to :eproduct, :counter_cache => true
 # validates_presence_of :tuan_id,:user_id,:content,:message => '不能为空'
  validates_length_of :content, :within => 1..210,:too_long=>APP_CONFIG['error_post_content_length'],:too_short=>APP_CONFIG['error_post_content_length']
  
  named_scope :gou, :conditions=>["tuan_comments.kind = 1"]
  
  def self.rate_labels
    ['很差','差','还行','好','很好']
  end
  
  def gou_brand
    @_brand || @_brand = GouBrand.find(:first, :conditions=>"name = '#{self.brand}'")
  end
  
  def self.create_comment(params,user)
    return if !user
    comment = TuanComment.new(params[:tuan_comment])
    comment.kind = 2
    comment.kind_id = comment.tuan_id
    ActiveRecord::Base.transaction do 
      comment.user = user
      comment.user_name = user.name
      return comment unless comment.save
      unless params[:is_copy_post].blank?
        params[:post]={:content=>"#{comment.content}",:tuan_id=>comment.tuan_id} if comment.kind==2
        params[:post]={:content=>"评价了【#{comment.try(:tuan_website).try(:name)}】#{'：评价'+['2分（差）','4分（一般）','6分（还行）','8分（推荐）','10分（力荐）'][comment.rate-1]+'，' unless comment.rate.blank? }#{comment.content}"} unless comment.tuan_website_id.blank?
        params[:post]={:content=>"评价了【#{comment.gou.name}】#{'：评价'+['2分（差）','4分（一般）','6分（还行）','8分（推荐）','10分（力荐）'][comment.rate-1]+'，' unless comment.rate.blank? }#{comment.content}",:gou_id=>comment.kind_id} if comment.kind == 1
        params[:post]={:content=>"评价了【#{comment.brand}】#{'：评价'+['2分（差）','4分（一般）','6分（还行）','8分（推荐）','10分（力荐）'][comment.rate-1]+'，' unless comment.rate.blank? }#{comment.content}"} unless !comment.brand || comment.brand.size == 0
        
      end
      Tuan.set_tuan_rate(comment.tuan) if comment.rate.present? and comment.tuan_id.present?
      TuanWebsite.set_average_rate(comment.tuan_website) if comment.rate.present? and comment.tuan_website_id.present?      
      Gou.set_gou_rate(comment.gou) if comment.rate.present? and comment.gou.present?   
      GouBrand.set_gou_brand_rate(comment.gou_brand) if comment.rate.present? and comment.gou_brand.present?
    end
    comment
  end
  
  def self.calculate_rate(comment)
    if comment.tuan_id.present?
      grade_labels = GouCategory.grade_labels(comment.tuan)
      return if grade_labels.blank? or TuanComment.last(:conditions=>["tuan_id = ? and rate is not NULL and user_id=?",comment.tuan_id,comment.user_id])
    end
    if comment.gou_id.present?
      grade_labels = GouCategory.grade_labels(comment.gou)
      return if grade_labels.blank? or TuanComment.last(:conditions=>["gou_id = ? and rate is not NULL and user_id=?",comment.gou_id,comment.user_id])
    end
    if comment.gou_brand_id.present?
      grade_labels = GouCategory.grade_labels(comment.gou_brand)
      return if grade_labels.blank? or TuanComment.last(:conditions=>["gou_brand_id = ? and rate is not NULL and user_id=?",comment.gou_brand_id,comment.user_id])
    end
    sum = grade_labels.select{|label| comment.send("value_#{label[0]}").present?}.sum{|label| comment.send("value_#{label[0]}")}
    rate = sum / grade_labels.size
    rate
  end
  
  def self.delete_tuan_comment(comment_id,user)
    tuan = nil
    tuan_website = nil
    gou = nil
    gou_brand = nil
    ActiveRecord::Base.transaction do 
      comment = TuanComment.find_by_id_and_user_id(comment_id,user.id)
      if comment
        tuan = comment.tuan
        if tuan
          Tuan.delete_tuan_rate(tuan,comment) if comment.rate.present?
          comment.destroy
        end
        tuan_website = comment.tuan_website
        if tuan_website
          TuanWebsite.delete_average_rate(tuan_website,comment) if comment.rate.present?
          comment.destroy
        end
        gou = comment.gou
        if gou
          Gou.delete_gou_rate(gou, comment) if comment.rate.present?
          comment.destroy
        end
        gou_brand = comment.gou_brand
        if gou_brand
          GouBrand.delete_gou_brand_rate(gou_brand, comment) if comment.rate.present?
          comment.destroy
        end
      end
    end
    return tuan unless tuan.blank?
    return tuan_website unless tuan_website.blank?
    return gou unless gou.blank?
    return gou_brand unless gou_brand.blank?
  end
  
end