# encoding: utf-8
class Crawler::Cc5800
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".TabCss a")
    nodes.each do |node|
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(@page_url+ node[:href])
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = @page_url+ node[:href]
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
    @page_html.css("#content a").remove
    text = @page_html.css("#content").text.strip
    text = text.gsub("*** 即刻参加58小说，和广大书友共享阅读乐趣！58小说永久地址：www.5800.cc ***","")
    text = ZhConv.convert("zh-tw", text)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end