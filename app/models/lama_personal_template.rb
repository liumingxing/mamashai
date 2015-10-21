class LamaPersonalTemplate < ActiveRecord::Base
  belongs_to :user

  def small_pic
    "/images/lama_template/#{self.small_path}"
  end
end
