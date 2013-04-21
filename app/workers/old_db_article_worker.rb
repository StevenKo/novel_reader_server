# encoding: utf-8
class OldDbArticleWorker
  include Sidekiq::Worker
  sidekiq_options queue: "novel"
  
  def perform(article_id)
    crawler = NovelCrawler.new
    crawler.fetch_db_json "http://106.187.103.131/api/v1/articles/#{article_id}.json"
    crawler.parse_old_db_article_detail article_id
  end
end