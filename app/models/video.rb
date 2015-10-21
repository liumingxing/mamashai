class Video < ActiveRecord::Base
	upload_column :path, :store_dir=>proc{|video, file| "video/#{video.created_at.strftime("%Y-%m-%d")}/#{video.id}/path"}
end
