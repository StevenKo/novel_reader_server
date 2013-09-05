# encoding: utf-8
class Crawler::Fxnzw
  include Crawler

  def crawl_articles novel_id
    url = "http://tw.fxnzw.com/"
    @page_html.css("#BookText ul li").last.remove
    @page_html.css("#BookText ul li").last.remove
    @page_html.css("#BookText ul li").last.remove
    nodes = @page_html.css("#BookText ul li a")
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
    text = @page_html.css("div")[6].children[14].text.strip
    text = text.gsub("請記住:飛翔鳥中文小說網 www.fxnzw.com 沒有彈窗,更新及時 !","")
    text = text.gsub("()","")
    article.text = ZhConv.convert("zh-tw", text)
    article.save
  end

end