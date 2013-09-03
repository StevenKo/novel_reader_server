# encoding: utf-8
class ArticleWorker
  include Sidekiq::Worker
  sidekiq_options queue: "novel"
  
  def perform(article_id)
    article = Article.select("id, text, link").find(article_id)
    crawler = CrawlerAdapter.get_instance article.link
    if (article.link.index('bestory'))
      crawler.fetch article.link
      crawler.crawl_article article
    else
      crawler.fetch_other_site article.link
      crawler.crawl_text_onther_site article
    end
  end
end