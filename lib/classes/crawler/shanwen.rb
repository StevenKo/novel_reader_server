# encoding: utf-8
class Crawler::Shanwen
  include Crawler

  def crawl_articles novel_id
    url = @page_url.gsub("index.html","")
    nodes = @page_html.css("div.bookdetail a")
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
    @page_html.css("#content")
    @page_html.css("#content center").remove
    text = ZhConv.convert("zh-tw",@page_html.css("#content").text.strip)
    if text.length < 100
      imgs = @page_html.css(".divimage img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版"
      article.text = text_img
    else
      article.text = ZhConv.convert("zh-tw", text)
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end