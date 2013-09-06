# encoding: utf-8
class Crawler::Dawenxue
  include Crawler

  def crawl_articles novel_id
    url = @page_url.gsub("index.html","")
    nodes = @page_html.css(".ccss a")
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
    text = @page_html.css("#clickeye_content").text.strip
    text1 = text.gsub("大文学", "")
    text2 = text1.gsub("www.dawenxue.net", "")
    text2 = text2.gsub("()", "")
    text2 = text2.gsub("www.Sxiaoshuo.com", "")
    text2 = text2.gsub("最快的小说搜索网", "")
    text2 = text2.gsub("/////", "")    
    if text2.length < 100
      imgs = @page_html.css(".divimage img")
      text_img = ""
      imgs.each do |img|
        text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版"
      article.text = text_img
    else
      article_text = ZhConv.convert("zh-tw",text2)
      article.text = article_text
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end