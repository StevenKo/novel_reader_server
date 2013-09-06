# encoding: utf-8
class Crawler::Paradise
  include Crawler

  def crawl_articles novel_id
    subject = ""
    nodes = @page_html.css(".acss tr td")
    url = @page_url.gsub("index.html","")
    nodes.each do |node|
      if node[:class] == "vcss"
        subject = ZhConv.convert("zh-tw",node.text.strip)
      else
        a_node = node.css("a")[0]
        next if a_node.nil?
        article = Article.find_by_link(url + a_node[:href])
        next if isArticleTextOK(article)
        unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + a_node[:href]
        article.title = ZhConv.convert("zh-tw",a_node.text.strip)
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

  def crawl_article article
    node = @page_html.css("#content")
    node.css("img").remove
    text = node.text
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end