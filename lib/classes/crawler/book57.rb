# encoding: utf-8
class Crawler::Book57
  include Crawler

  def crawl_articles novel_id
    url = "http://tw.57book.net/"
    @page_html.css(".footer").remove
    nodes = @page_html.css(".booklist span a")
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
    @page_html.css("div#msg-bottom,script").remove
    text = change_node_br_to_newline(@page_html.css("div.bookcontent")).strip
    text = text.gsub("www.57book.net","")
    text = text.gsub("無極小說~~","")
    text = text.gsub("三藏小說免費小說手打網","")
    text = text.gsub("()","")
    article.text = ZhConv.convert("zh-tw", text)
    article.save
  end

end