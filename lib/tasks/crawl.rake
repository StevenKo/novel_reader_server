# encoding: utf-8
namespace :crawl do
  task :crawl_novel_link => :environment do
    categories = Category.all
    
    categories.each do |category|

      (1..100).each do |i|
        begin
          crawler = NovelCrawler.new
          crawler.fetch "http://www.bestory.com/category/#{category.id}-#{i}.html"
          crawler.crawl_novels category.id
        rescue
          puts category.name + ":  http://www.bestory.com/category/#{category.id}-#{i}.html"
        end
      end
    end
  end

  task :crawl_novel_detail => :environment do
    Novel.find_in_batches do |novels|
      novels.each do |novel|
        begin
          if (novel.name.nil?)
            crawler = NovelCrawler.new
            crawler.fetch novel.link
            crawler.crawl_novel_detail
          end
        rescue
          puts "errors: #{novel.name   novel.link}"
        end
      end
    end
  end

  task :crawl_cat_ranks　=> :environment do
    Novel.update_all({:is_category_recommend => false , :is_category_hot => false, :is_category_this_week_hot => false})
    categories = Category.all
    
    categories.each do |category|
      crawler = NovelCrawler.new
      crawler.fetch category.cat_link
      crawler.crawl_cat_rank category.id
    end
  end

  task :crawl_articles => :environment do
    Novel.find_in_batches do |novels|
      novels.each do |novel|
        crawler = NovelCrawler.new
        crawler.fetch novel.link
        crawler.crawl_articles novel.id
      end
    end
  end

  task :crawl_article_text => :environment do
    Article.find_in_batches do |articles|
      articles.each do |article|
        crawler = NovelCrawler.new
        crawler.fetch article.link
        crawler.crawl_article article
      end
    end
  end

  task :crawl_rank => :environment do
    ThisWeekHotShip.delete_all
    ThisMonthHotShip.delete_all
    HotShip.delete_all
    url = "http://www.bestory.com/html/r-1.html"
    crawler = NovelCrawler.new
    crawler.fetch url
    crawler.crawl_rank
  end
end