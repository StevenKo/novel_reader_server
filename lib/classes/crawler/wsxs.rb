# encoding: utf-8
class Crawler::Wsxs
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".acss tr a")
    nodes.each do |node|
      article = Article.find_by_link(node[:href])
      next if isSkipCrawlArticle(article)

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = node[:href]
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
    node = @page_html.css("#content")
    text = node.text
    text = text.gsub("☺文山小说网编辑整理，谢谢观赏！☺","")
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
    article.save
  end

end