# encoding: utf-8
class Crawler::Ranhen
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("dd a")
    nodes.each do |node|
      article = Article.find_by_link(@page_url + node[:href])
      next if isSkipCrawlArticle(article)

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = @page_url + node[:href]
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
    text = @page_html.css("#content p").text
    text2 = text.gsub('小技巧：按 Ctrl+D 快速保存当前章节页面至浏览器收藏夹；按 回车[Enter]键 返回章节目录，按 ←键 回到上一章，按 →键 进入下一章。','')
    article_text = ZhConv.convert("zh-tw",text2)
    article.text = article_text
    article.save
  end

end