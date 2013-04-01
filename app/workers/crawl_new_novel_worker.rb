# encoding: utf-8
class CrawlNewNovelWorker
  include Sidekiq::Worker
  
  def perform(category_id, page)
    begin
      crawler = NovelCrawler.new
      crawler.fetch "http://www.bestory.com/category/#{category_id}-#{page}.html"
      crawler.crawl_novels category_id
    rescue
      puts category.name + ":  http://www.bestory.com/category/#{category_id}-#{page}.html"
    end
  end
end