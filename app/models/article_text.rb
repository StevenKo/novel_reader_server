class ArticleText < ActiveRecord::Base
  attr_accessible :article_id, :text
  belongs_to :article
end
