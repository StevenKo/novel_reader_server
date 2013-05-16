# encoding: utf-8
class CrawlWorker
  include Sidekiq::Worker
  sidekiq_options queue: "novel"
  
  def perform(novel_id)
    novel = Novel.select("id, link, is_show").find(novel_id)
    return if novel.is_show == false

    crawler = NovelCrawler.new
    if(novel.link.index('bestory'))
      crawler.fetch novel.link
      crawler.crawl_novel_detail novel.id
    else
      crawler.fetch_other_site novel.link
    end
    crawler.crawl_articles novel.id
    puts novel.id
  end
end