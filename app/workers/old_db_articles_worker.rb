# encoding: utf-8
class OldDbArticlesWorker
  include Sidekiq::Worker
  sidekiq_options queue: "novel"
  
  def perform(novel_id)
    c = NovelCrawler.new
    c.fetch_db_json "http://106.187.103.131/api/v1/articles/db_transfer_index.json?novel_id=#{novel_id}"
    c.parse_old_db_article
  end
end