# encoding: utf-8
class ArticleWorker
  include Sidekiq::Worker
  sidekiq_options queue: "novel"
  
  def perform(article_id)
    article = Article.select("id, text, link").find(article_id)
    crawler = NovelCrawler.new
    crawler.fetch article.link
    crawler.crawl_article article
  end
end