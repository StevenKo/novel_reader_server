# encoding: utf-8
class CrawlNewNovelWorker
  include Sidekiq::Worker
  sidekiq_options queue: "novel"
  
  def perform(category_id, page)
    cat_hash = { 1=>1, 2=>2, 3=>3,4=>4,5=>8,6=>5,7=>6,8=>9,9=>10,10=>11,11=>14,12=>15}
    begin
      crawler = NovelCrawler.new
      crawler.fetch "http://www.bestory.com/category/#{cat_hash[category_id]}-#{page}.html"
      crawler.crawl_novels category_id
    rescue
      puts category.name + ":  http://www.bestory.com/category/#{category_id}-#{page}.html"
    end
  end
end