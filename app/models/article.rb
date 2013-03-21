class Article < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :novel
  scope :by_id_desc, order('id DESC')

  scope :novel_articles, lambda { |novel_id| where('novel_id = (?)', novel_id).select('id') }

  def self.find_next_article (origin_article_id, origin_novel_id)
    articles = novel_articles(origin_novel_id)
    (0..articles.length-2).each do |i|
      if(articles[i].id == origin_article_id)
        return Article.select('id, novel_id, text, title').find(articles[i+1].id)
      end
    end
    return nil
  end

  def self.find_previous_article (origin_article_id, origin_novel_id)
    articles = novel_articles(origin_novel_id)
    (1..articles.length-1).each do |i|
      if(articles[i].id == origin_article_id)
        return Article.select('id, novel_id, text, title').find(articles[i-1].id)
      end
    end
    return nil
  end
end
