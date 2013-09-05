# encoding: utf-8
class Crawler::Qbxs8
  include Crawler

  def crawl_articles novel_id
    url = @page_url.sub("index.shtml","")
    nodes = @page_html.css("ul li a")
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
    @page_html.css("div.text div").remove
    @page_html.css("div.text a").remove
    @page_html.css("div.text h1").remove
    @page_html.css("div.text h2").remove
    @page_html.css("div.text script").remove
    text = @page_html.css("div.text").text.strip
    text = text.gsub("*  * 女  生 小  说  网 - http://www.qbxs8.com - 好  看  的  女  生 小  说     ★★★★★薄情锦郁★★★★★ ","")
    article.text = ZhConv.convert("zh-tw", text)
    article.save    
  end

end