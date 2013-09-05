# encoding: utf-8
class Crawler::Dz320
  include Crawler

  def crawl_articles novel_id
    url = ""
    nodes = @page_html.css("div.mulu a")
    nodes.each do |node|
      article = Article.find_by_link(url + node[:href])
      next if isSkipCrawlArticle(article)

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node[:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip)
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
    @page_html.css("div.cmt").remove
    text = @page_html.css("div.content").text.strip
    article.text = ZhConv.convert("zh-tw", text)
    article.save
  end

end