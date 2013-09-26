# encoding: utf-8
class Crawler::Duyidu
  include Crawler

  def crawl_articles novel_id
    url = @page_url
    nodes = @page_html.css("a.listA")
    nodes.each do |node|
      article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(url + node[:href])
      if article
        article.is_show = true
        article.save
      end
      next if isArticleTextOK(article,article.text) if article

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
    text = @page_html.css("div#content").text.strip
    if text.length < 100
      text = @page_html.css("div#content2").text.strip
    end
    article.text = ZhConv.convert("zh-tw", text)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    article.save
  end

end