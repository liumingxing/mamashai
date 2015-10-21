
#辣妈日报
#Weibo::Config.api_key = "2074109574"
#Weibo::Config.api_secret = "94f278f00142001a05c45de344701862"

#妈妈晒
Weibo::Config.api_key = "4083044570"
Weibo::Config.api_secret = "a8c20ceedea52a0d32fe1210915c1f84"

#$lama_key = "1162187343"
#$lama_secret = "df8119caacc6fdbc3a6f945cef855ce3"

$lama_key = "2113630478"
$lama_secret = "ad226f3cd55e7332c06fca76ef20ca75"


#CONSUMER_OPTIONS = {
#        :site => "http://openapi.qzone.qq.com",
#        :request_token_path => "/oauth/qzoneoauth_request_token",
#        :access_token_path => "/oauth/qzoneoauth_access_token",
#        :authorize_path => "/oauth/qzoneoauth_authorize",
#        :http_method => :get,
#        :scheme => :query_string,        
#        :nonce => Base64.encode64(OpenSSL::Random.random_bytes(32)).gsub(/\W/, '')[0, 32] }
#
#QQ_KEY = 205799
#QQ_SECRET = '6457e09392a01900a2384942f9bd5265'

QQ_KEY = "381d81492d84439dba93a857df2d793e"
QQ_SECRET = "95a8d44405e3e99f95fbb6492e70c936"
CONSUMER_OPTIONS = {
        :site => "https://open.t.qq.com",
        :request_token_path => "/cgi-bin/request_token",
        :access_token_path => "/cgi-bin/access_token",
        :authorize_path => "/cgi-bin/authorize",
        :http_method => :get,
        :scheme => :query_string,        
        :nonce => Base64.encode64(OpenSSL::Random.random_bytes(32)).gsub(/\W/, '')[0, 32] }