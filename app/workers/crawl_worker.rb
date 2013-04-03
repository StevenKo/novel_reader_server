# encoding: utf-8
class CrawlWorker
  include Sidekiq::Worker
  sidekiq_options queue: "novel"
  
  def perform(novel_id)
    novel = Novel.select("id, link").find(novel_id)
    crawler = NovelCrawler.new
    crawler.fetch novel.link
    crawler.crawl_novel_detail novel.id
    crawler.crawl_articles novel.id
    puts novel.id
  end
end