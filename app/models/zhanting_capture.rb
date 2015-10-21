class ZhantingCapture < ActiveRecord::Base
  # attr_accessible :title, :body
  upload_column :logo
  belongs_to :user
end
