# encoding: utf-8
namespace :crawl do
  task :crawl_novel_link => :environment do
    categories = Category.all
    
    categories.each do |category|

      (1..100).each do |i|
        CrawlNewNovelWorker.perform_async(category.id,i)
      end
    end
  end

  # task :fetch_old_db_novels => :environment do
  #   categories = Category.all
    
  #   categories.each do |category|
  #     c = NovelCrawler.new
  #     c.fetch_db_json "http://106.187.103.131/api/v1/novels/db_transfer_index.json?category_id=#{category.id}"
  #     c.parse_old_db_novel
  #   end
  # end

  # task :fetch_old_db_articles => :environment do
  #   Novel.select("id").find_in_batches do |novels|
  #     novels.each do |novel|
  #       OldDbArticlesWorker.perform_async(novel.id)
  #     end
  #   end
  # end

  # task :fetch_old_db_article_text => :environment do
  #   Article.select("id").where("text is null").find_in_batches do |articles|
  #     articles.each do |article|
  #       OldDbArticleWorker.perform_async(article.id)
  #     end
  #   end
  # end

  task :crawl_novel_detail_and_articles => :environment do
    Novel.select("id").find_in_batches do |novels|
      novels.each do |novel|
        CrawlWorker.perform_async(novel.id)
        # begin
        #   crawler = NovelCrawler.new
        #   crawler.fetch novel.link
        #   crawler.crawl_novel_detail novel.id
        #   # crawler.crawl_articles novel.id
        #   novel.crawl_times = novel.crawl_times + 1
        #   novel.save
        #   puts novel.id
        # rescue
        #   puts "errors: #{novel.name}   #{novel.link}"
        # end
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

  task :crawl_articles_and_update_novel => :environment do
    Novel.select("id").find_in_batches do |novels|
      novels.each do |novel|
        CrawlWorker.perform_async(novel.id)
      end
    end
  end

  task :crawl_article_text => :environment do
    Article.where("text is null and id > 2274008").select("id").find_in_batches do |articles|
      articles.each do |article|
        ArticleWorker.perform_async(article.id)
        # begin
        #   crawler = NovelCrawler.new
        #   crawler.fetch article.link
        #   crawler.crawl_article article
        # rescue
        #   puts "errors: #{article.link}"
        # end
      end
    end
  end

  task :recrawl_article_text => :environment do
    Article.select("id, text").find_in_batches do |articles|
      articles.each do |article|
        if (article.text.nil? || article.text.size < 50)
               ArticleWorker.perform_async(article.id)
               puts article.id
        end
        # ArticleWorker.perform_async(article.id)
        # begin
        #   crawler = NovelCrawler.new
        #   crawler.fetch article.link
        #   crawler.crawl_article article
        # rescue
        #   puts "errors: #{article.link}"
        # end
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