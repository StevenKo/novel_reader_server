# encoding: utf-8
class Crawler::Hh23
  include Crawler

  def crawl_articles novel_id
    url = @page_url
    nodes = @page_html.css("td a")
    nodes.each do |node|
      article = Article.find_by_link(url + node[:href])
      next if isSkipCrawlArticle(article)

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
    text = change_node_br_to_newline(@page_html.css("#contents"))
    if text.length < 100
      imgs = @page_html.css("#contents .divimage img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版"
      article.text = text_img
    else
      text = text.gsub("http://","")
      article.text = ZhConv.convert("zh-tw", text)
    end
    article.save
  end

end