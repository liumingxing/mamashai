module PHelper
	def post_content2(content)
    auto_link(h(content.gsub(/&.+;/, '')).gsub(/@(\w{1,20})$|@(\w{1,20})([\s\,\:\：。，\，\！\!\(\)\（\）\=\-\[\]"\'\>\<\?\*\/])|@(\w{1,20})@/i,'<a href="/friends/find_user/\\1\\2">@\\1\\2</a>\\3'),:all,:target => "_blank").gsub(/\(\:(.+?)\)/i,'<img src="/images/smiles/\\1.gif"/>').gsub(/©/,'@').gsub(/\[(.+?)\]/){|g|  File.exist?("#{::Rails.root.to_s}/public/images/face/#{$1.to_s}.png") ? "<img style='width: 20px; height: 20px;' src='/images/face/#{$1.to_s}.png' />" : "#{$1.to_s}"}.html_safe  
  end
end
