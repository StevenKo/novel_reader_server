# encoding: utf-8
class Crawler::Dzxsw
  include Crawler

  def crawl_articles novel_id
    url = "http://www.dzxsw.net"
    subject = ""
    nodes = @page_html.css(".list").children
    nodes.each do |node|
      if node[:class] == "book"
        subject = ZhConv.convert("zh-tw",node.text.strip)
      elsif node[:class] == nil
        inside_nodes = node.css("a")
        inside_nodes.each do |in_node|
          article = Article.find_by_link(url + in_node[:href])
          next if isSkipCrawlArticle(article)

          unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = url + in_node[:href]
            article.title = ZhConv.convert("zh-tw",in_node.text.strip)
            novel = Novel.select("id,num,name").find(novel_id)
            article.subject = subject
            article.num = novel.num + 1
            novel.num = novel.num + 1
            novel.save
            # puts node.text
            article.save
          end
          ArticleWorker.perform_async(article.id)
        end
      end
    end
  end

  def crawl_article article
    text = @page_html.css("#content").text
    text = text.gsub(/\/\d*/,"")
    text = text.gsub("'>","")
    text = text.gsub(".+?","")
    article_text = ZhConv.convert("zh-tw",text)
    article.text = article_text
    article.save
  end

end