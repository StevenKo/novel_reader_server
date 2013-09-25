# encoding: utf-8
class Crawler::Luoqiu
  include Crawler

  def crawl_articles novel_id
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name
    nodes = @page_html.css(".booklist span")
    nodes.each do |node|
      if(node[:class]=="v")
        subject = ZhConv.convert("zh-tw",node.text.strip.gsub(".",""))
      else
        a_node = node.css("a")[0]
        url = @page_url.gsub("index.html","") + a_node[:href]
        article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(url)
        next if isArticleTextOK(article)
        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url
          article.title = ZhConv.convert("zh-tw",a_node.text.strip) 
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
    text = node.text
    article.text = ZhConv.convert("zh-tw", text.strip)

    if text.length < 100
      imgs = @page_html.css("#content img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      article.text = text_img
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end