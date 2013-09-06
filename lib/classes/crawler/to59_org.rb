# encoding: utf-8
class Crawler::To59Org
  include Crawler

  def crawl_articles novel_id
    url = "http://tw.59to.org"
    @page_html.css(".booklist a").last.remove
    @page_html.css(".booklist a").last.remove
    @page_html.css(".booklist a").last.remove
    @page_html.css(".booklist a").last.remove
    @page_html.css(".booklist a").last.remove
    nodes = @page_html.css(".booklist a")
    nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if isArticleTextOK(article)

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
    @page_html.css(".bookcontent div").remove
    text = @page_html.css(".bookcontent").text.strip
    article_text  = ZhConv.convert("zh-tw",text)
    article.text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end