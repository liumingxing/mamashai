class ArticleGood < ActiveRecord::Base
  belongs_to :article, :counter_cache => true
end
