class AlbumPicture < ActiveRecord::Base
	upload_column :path, :versions => {:thumb100 => "100x100"}, :store_dir=>proc{|picture, file| "album_picture/#{picture.created_at.strftime("%Y-%m-%d")}/#{picture.id}/path"}
end
