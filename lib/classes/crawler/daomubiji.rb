# encoding: utf-8
class Crawler::Daomubiji
  include Crawler

  def crawl_articles novel_id
    subject = ""
    nodes = @page_html.css(".bg .mulu")
    nodes.each do |node|

      child_nodes = node.css("td")
      child_nodes.each_with_index do |c_node,i|
        if i==0
          subject = ZhConv.convert("zh-tw",c_node.text.strip)
        else
          a_node = c_node.css("a")[0]
          next if a_node.nil?
          article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(a_node[:href])
          next if isArticleTextOK(article,article.text) if article
          unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = a_node[:href]
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
  end

  def crawl_article article
    node = @page_html.css(".content")
    node.css("a").remove
    node.css(".shangxia").remove
    node.css(".cmt").remove
    node.css("script").remove
    node.css("span").remove
    text = node.text
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    article.save
  end

end