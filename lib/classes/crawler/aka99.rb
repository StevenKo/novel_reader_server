# encoding: utf-8
class Crawler::Aka99
  include Crawler

  def crawl_articles novel_id
    node = @page_html.css(".pages a.last")[0]
    /page=(\d*)/ =~ node[:href]
    (1..$1.to_i).each do |i|
      url = @page_url.sub(/page=\d*/,"page=#{i}")
      article = Article.find_by_link(url)
      next if isSkipCrawlArticle(article)
      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url
        article.title = i.to_s
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
    node = @page_html.css(".postmessage")
    text = change_node_br_to_newline(node).strip
    article.text = ZhConv.convert("zh-tw", text.strip)
    article.save
  end

end