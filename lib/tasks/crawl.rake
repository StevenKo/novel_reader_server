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

  # task :crawl_novel_detail_and_articles => :environment do
  #   Novel.select("id").find_in_batches do |novels|
  #     novels.each do |novel|
  #       CrawlWorker.perform_async(novel.id)
  #       # begin
  #       #   crawler = NovelCrawler.new
  #       #   crawler.fetch novel.link
  #       #   crawler.crawl_novel_detail novel.id
  #       #   # crawler.crawl_articles novel.id
  #       #   novel.crawl_times = novel.crawl_times + 1
  #       #   novel.save
  #       #   puts novel.id
  #       # rescue
  #       #   puts "errors: #{novel.name}   #{novel.link}"
  #       # end
  #     end
  #   end
  # end

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

  task :crawl_specific_novel => :environment do
    
    novel_id = 15470
    url_mother = "http://www.shu88.net/files/article/html/0/969/"
    url = "http://www.shu88.net/files/article/html/0/969/index.html"
    # novel.name = 總裁，殘情毒愛
    c = NovelCrawler.new
    c.fetch_other_site url
    novel = Novel.find(novel_id)
    # Article.where( :novel_id => novel_id).each do |a| a.delete end
    current_size = Article.where( :novel_id => novel_id).size()

    total_num = c.page_html.css('ol li').size()
    i = 0
    while i < total_num do
      text = c.page_html.css('ol li')[i].text.strip
      title =  ZhConv.convert("zh-tw", text)
      puts title
      Article.create(:novel_id => novel_id, :title => title , :num => i + current_size +1, :subject => novel.name, :link => url_mother + c.page_html.css('ol li')[i].child[:href])
      i = i+1
    end


    # crawl article content
    j = 1 + current_size
    while j < total_num + current_size do
      puts "article"+j.to_s
      article = Article.where(:novel_id => novel_id)[j - 1]
      c2 = NovelCrawler.new
      c2.fetch_other_site article.link
      text = c2.page_html.css(".contentbox").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
      j = j + 1
    end

  end

  # test now
  task :crawl_new_novel => :environment do
    
    novel = Novel.create(:name => "test")
    novel_id = novel.id
    
    url_mother = "http://www.shu88.net/files/article/html/0/969/"
    url = "http://www.shu88.net/files/article/html/0/969/index.html"

    c = NovelCrawler.new
    c.fetch_other_site url

    total_num = c.page_html.css('ol li').size()
    i = 0
    while i < total_num do
      text = c.page_html.css('ol li')[i].text.strip
      title =  ZhConv.convert("zh-tw", text)
      puts title
      Article.create(:novel_id => novel_id, :title => title , :num => i+1, :subject => novel.name, :link => url_mother + c.page_html.css('ol li')[i].child[:href])
      i = i+1
    end

    j = 1
    while j < total_num do
      puts "article"+j.to_s
      article = Article.where(:novel_id => novel_id)[j - 1]
      c2 = NovelCrawler.new
      c2.fetch_other_site article.link
      text = c2.page_html.css(".contentbox").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
      j = j + 1
    end

  end

  task :send_notification => :environment do
    gcm = GCM.new("AIzaSyBSeIzNxqXm2Rr4UnThWTBDXiDchjINbrc")
    u = User.find(2)
    registration_ids= [u.registration_id]
    options = {data: {
                  activity: 4, 
                  title: "好久沒看小說王囉", 
                  big_text: "繼續看個小說吧！", 
                  content: "我是 content", 
                  is_resent: true, 
                  category_name: "test", 
                  category_id: 1,
                  novel_name: "novel_name",
                  novel_author: "novel_author",
                  novel_description: "novel_description",
                  novel_update: "20000",
                  novel_pic_url: "http",
                  novel_article_num: "2222",
                  novel_id: 133
                  }, collapse_key: "updated_score"}
    response = gcm.send_notification(registration_ids, options)
  end

end