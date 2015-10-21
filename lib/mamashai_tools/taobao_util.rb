module MamashaiTools
  $PRODUCT_URL = "http://gw.api.taobao.com/router/rest"
  $APP_KEY = "12522500"
  $APP_SECRET = "28db7262ee024150ea26512b94fd5b7e"

  #$APP_KEY = "21808990"
  #$APP_SECRET = "66c5b0e05eaf17fde96ae06ad4549c85"


  #$APP_KEY = "12341355"
  #$APP_SECRET = "9eeeff4875aa5ecec3254d3bf18a1b82"

  def taobao_call(api, params)
    access_params = {  "method" => api, 
                       "timestamp" => Time.new.to_s(:db),
                       "format" => "json", 
                       "app_key" => $APP_KEY, 
                       "v" => "2.0",
                       "sign_method" => "md5"
    }
    params.each{|key, value|
      access_params[key] = value
    }
    access_params[:sign] = sign(access_params, $APP_SECRET)
    p "#{$PRODUCT_URL + "?" + params_to_str(access_params)}"
    str = `curl '#{$PRODUCT_URL + "?" + params_to_str(access_params)}' -k`
    json = ActiveSupport::JSON.decode(str)
    return json
  end
  
  
  def sign(params, secret)
      result = ""
      result << secret
      params.keys.sort.each{ |key|
        result << key << params[key]
      }
      result << secret
      Digest::MD5.hexdigest(result).upcase
  end

  def params_to_str(params)
      result = []
      params.each{|key, value|
        result << "#{key}=#{value}"
      }
      URI.escape(result.join("&"))
  end
  
end