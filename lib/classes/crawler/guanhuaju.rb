# encoding: utf-8
class Crawler::Guanhuaju
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("#db_4_3_1 a")
    nodes.each do |node|
      article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link("http://www.guanhuaju.com" + node[:href])
      next if isArticleTextOK(article,article.text) if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = "http://www.guanhuaju.com" + node[:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        article.num = novel.num + 1
        novel.num = novel.num + 1
        novel.save
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
  end

  def crawl_article article
    text = @page_html.css("div#content_text").text.strip
    article.text = ZhConv.convert("zh-tw", text)
    if text.length < 100
      imgs = @page_html.css(".divimage img")
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