# encoding: utf-8
class Crawler::Wenku8
  include Crawler

  def crawl_articles novel_id
    subject = ""
    nodes = @page_html.css(".acss tr td")
    url = @page_url.gsub("index.htm","")
    nodes.each do |node|
      if node[:class] == "vcss"
        subject = ZhConv.convert("zh-tw",node.text.strip)
      else
        a_node = node.css("a")[0]
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
    node.css("#contentdp").remove
    text = node.text
    article.text = ZhConv.convert("zh-tw", text.strip)
    if text.length < 100
      imgs = @page_html.css("#content .divimage img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      article.text = text_img
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    article.save
  end

end