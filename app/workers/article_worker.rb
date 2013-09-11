# encoding: utf-8
class ArticleWorker
  include Sidekiq::Worker
  sidekiq_options queue: "novel", :retry => 2
  
  def perform(article_id)
    article = Article.select("id, text, link, is_show").find(article_id)
    crawler = CrawlerAdapter.get_instance article.link
    crawler.fetch article.link
    crawler.crawl_article article
  end
end