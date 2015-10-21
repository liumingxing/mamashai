class ArticleTag < ActiveRecord::Base
  belongs_to :article_tag_type
end
