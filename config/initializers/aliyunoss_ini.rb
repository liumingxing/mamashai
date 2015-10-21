require 'aliyunoss'

$connection = Aliyun::Connection.new({
      :aliyun_access_id => '5ba5stALiguGiHs0',
      :aliyun_access_key => 'wWlMYV5nYbdYSxZjNfDAeIO3EeEhOO',
      :aliyun_bucket => 'mamashai-videos',
      :aliyun_internal => true,
      :aliyun_area => 'cn-qingdao'
})

if Rails.env == "development"
  Dir.foreach("#{Rails.root}/app/models") do |model_name|
  	if model_name.include?('.rb')
	    begin
	    	require_dependency model_name unless model_name == "." || model_name == ".."
		rescue
		end
	end
  end 
end