class Item
  attr_accessor :baby_book_id,:tuan_id,:amount, :na_id, :tp, :obj_id, :obj
  def initialize(obj_id, amount, tp='tuan')
    @tp = tp
    @obj_id = obj_id.to_i
    if tp=="tuan"
      tuan =Tuan.mms.ready(Time.now).find(obj_id)
      @obj = tuan
      raise "团购已卖光" unless tuan.remain?
      self.tuan_id = obj_id.to_i
    elsif tp=="babybook"
      @obj = BabyBook.find(obj_id)
      self.baby_book_id = obj_id.to_i
    elsif tp == "na"
      @obj = Gou.find(obj_id)
      self.na_id = obj_id.to_i
    end
    self.amount = amount.to_i
  end

  def amount
    return @amount
  end
  
  def gou
    return @na ||= Gou.find(params[:id]) if gou_id
  end

  def baby_book
    return @baby_book ||= BabyBook.find(product_id) if product_id
  end
  
  def tuan
    return @tuan ||= Tuan.mms.ready(Time.now).find(tuan_id) if tuan_id
  end

  def tuan_sum
    return @amount.to_i * (tuan.try(:current_price)||0)
  end
  
  def baby_book_sum
#    return @amount * @baby_book.current_price
  end

  def sum
    if tp == "tuan"
      tuan_sum
    elsif tp == "na"
      0
    else
      obj.price * amount
    end
  end
  
  def weight_sum
    if tp == "tuan"
      return @obj.weight*@amount
    elsif tp == "na"
      return @obj.profile.weight*@amount
    end
  end
  
end