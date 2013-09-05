# encoding: utf-8
class Crawler::Fftxt
  include Crawler

  def crawl_articles novel_id
    url = @page_url.sub("index.html","")
    nodes = @page_html.css("#chapterlist a")
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
    text = @page_html.css(".novel_content").text.strip
    text = text.gsub("_.book.addBookhistroy;","")
    text = text.gsub("_.book.shoBookshistory;","")
    text = text.gsub("您最近阅读过：","")
    text = text.gsub("17k火热连载阅读分享世界","")
    text = text.gsub("创作改变人生","")
    text = text.gsub("一秒记住【非凡TXT下载】www.fftxt.net，为您提供精彩小说阅读。","")
    article.text = ZhConv.convert("zh-tw", text)
    article.save  
  end

end