require 'mamashai_tools/taobao_util'
include MamashaiTools

class TaobaoProduct < ActiveRecord::Base
  has_many :comments, :class_name=>"TaobaoComment", :foreign_key=>"product_id", :order=>"created_at desc"
  belongs_to :category, :class_name=>"TaobaoCategory"
  
  def claps_count
    Clap.count(:conditions=>"tp_id = #{self.id} and tp='taobao'")
  end
  
  def get_comments
        `wget http://detail.tmall.com/item.htm?id=#{self.iid} -T 20 -O tmp/a.txt`
        file = File.open('tmp/a.txt', 'r')
        text = file.read()
        file.close
        `rm tmp/a.txt`
        text.scan(/"valReviewsApi":"([\S]+)"/)
        return if !$1
        url = $1.gsub('\\', '')
        text = `curl -m 20 '#{url}'`
        text = text.to_utf8.gsub("\r\n", '')
        
        text.gsub(/"displayUserNick":"([\S]+)","displayUserNumId":([\d]+),"displayUserRateLink"([\S]+),"rateContent":"([\S]+)","rateDate":"([\d\.: ]+)","rateResult"/){
          comment = TaobaoComment.new
          comment.user_id = $2
          comment.user_name = $1
          comment.product_id = self.id
          comment.content = $4
          comment.created_at = $5.gsub(".", "-")
          comment.user_logo = rand(47) 
          begin
            comment.save
          rescue Exception=>err
            p err
          end
        }
  end
  
  def update_price
   return if self.iid.to_i == 0
   access_params = { "num_iid" => self.iid.to_s, 
                    "fields"=>"detail_url,num_iid,title,nick,type,cid,seller_cids,props,input_pids,input_str,pic_url,num,valid_thru,list_time,delist_time,stuff_status,location,price,post_fee,express_fee,ems_fee,has_discount,freight_payer,has_invoice,has_warranty,has_showcase,modified,increment,approve_status,postage_id,product_id,auction_point,property_alias,item_img,prop_img,sku,video,outer_id,is_virtual",
    }
    
    json = MamashaiTools.taobao_call("taobao.item.get", access_params)
    return if !json['item_get_response'] || !json['item_get_response']['item'] 
    price = json['item_get_response']['item']['price']
    onsale = json['item_get_response']['item']['approve_status']
    self.price = price
    self.cancel = true if onsale != "onsale"
    self.save
 end
end
