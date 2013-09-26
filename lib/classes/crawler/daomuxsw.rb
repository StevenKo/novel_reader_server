# encoding: utf-8
class Crawler::Daomuxsw
  include Crawler

  def crawl_articles novel_id
    subject = ""
    nodes = @page_html.css(".mainbody td")
    url = @page_url.gsub("index.html","")
    nodes.each do |node|
      if node[:class] == "vcss"
        subject = ZhConv.convert("zh-tw",node.text.strip)
      else
        a_nodes = node.css("a")
        a_nodes.each do |a_node|
          next if a_node.nil?
          article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(url + a_node[:href])
          next if isArticleTextOK(article,article.text) if article
          unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = url + a_node[:href]
            article.title = ZhConv.convert("zh-tw",a_node.text.strip)
            novel = Novel.select("id,num,name").find(novel_id)
            article.subject = subject
            /(\d*)\.html/ =~ a_node[:href]
            next unless $1
            article.num = $1.to_i
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
    node = @page_html.css("#content")
    text = node.text.strip
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    article.save
  end

end