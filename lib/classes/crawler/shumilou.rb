# encoding: utf-8
class Crawler::Shumilou
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".zl a")
    nodes.each do |node|
      article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(node[:href])
      next if isArticleTextOK(article,article.text) if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = node[:href]
        article.title = node.text.strip
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
    @page_html.css("#content span").remove
    @page_html.css("#content b").remove
    @page_html.css("#content .title").remove
    @page_html.css("#content script").remove
    text = @page_html.css("#content").text.strip
    article_text = ZhConv.convert("zh-tw",text)
    article.text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    article.save
  end

end