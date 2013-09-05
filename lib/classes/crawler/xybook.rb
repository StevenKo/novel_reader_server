# encoding: utf-8
class Crawler::Xybook
  include Crawler

  def crawl_articles novel_id
    /(\d*_*\d*\.html)/ =~ @page_url   
    root_url = @page_url.sub($1,"")
    nodes = @page_html.css(".pagelist a")
    nodes.each do |node|
      next unless node[:href]
      article = nil
      if(node[:href] == "#")
        url = @page_url
      else
        url = root_url + node[:href]
      end
      article = Article.find_by_link(url)

      next if isSkipCrawlArticle(article)
      next if (node.text == "上一页")
      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url
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
    node = @page_html.css(".article-article")
    node.css("a").remove
    text = node.text.strip
    article.text = ZhConv.convert("zh-tw", text.strip)
    article.save
  end

end