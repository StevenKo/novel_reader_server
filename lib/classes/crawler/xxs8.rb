# encoding: utf-8
class Crawler::Xxs8
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".bookdetail a")
    nodes.each do |node|
      article = Article.find_by_link(node[:href])
      next if isSkipCrawlArticle(article)

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = node[:href]
        article.title = node.text.strip
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        article.num = novel.num + 1
        novel.num = novel.num + 1
        novel.save
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
  end

  def crawl_article article
    node = @page_html.css("#mmpage")
    text = node.text.strip
    article.text = ZhConv.convert("zh-tw", text.strip)
    article.save
  end

end