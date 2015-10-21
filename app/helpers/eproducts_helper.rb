module EproductsHelper
  
  def select_rate_collection
    [['力荐(10)',5],['推荐(8)',4],['还行(6)',3],['一般(4)',2],['差(2)',1]]
  end
  
  def select_price_collection
    [['0-100元','0-100'],['101-200元','101-200'],['201-500元','201-500'],['501-1000元','501-1000'],['1000元以上','1001-']]
  end
  
end
