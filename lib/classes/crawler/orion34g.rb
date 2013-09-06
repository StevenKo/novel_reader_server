# encoding: utf-8
class Crawler::Orion34g
  include Crawler

  def crawl_articles novel_id
    url = @page_url
    nodes = @page_html.css(".novel_list a")
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
    @page_html.css(".novel_content div").remove
    text = @page_html.css(".novel_content").text.strip
    if text.length < 100
      begin
        text = @page_html.css(".divimage img")[0][:src]
        article.text = text + "*&&$$*" + "如果看不到圖片, 請更新至新版"
      rescue Exception => e      
      end
    else
      article.text = ZhConv.convert("zh-tw", text)
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save  
  end

end