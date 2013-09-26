# encoding: utf-8
class Crawler::Sto
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("#webPage a")
    last_node = nodes.last
    /(\d*)-(\d*)/ =~ last_node[:href]
    (1..$2.to_i).each do |i|
      article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link("http://book.sto.cc/" + $1 + "-" + i.to_s)
      next if isArticleTextOK(article,article.text) if article
      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = "http://book.sto.cc/" + $1 + "-" + i.to_s
        article.title = i.to_s
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
    node = @page_html.css("#BookContent")
    node.css("span,script").remove
    text = node.text.strip
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    article.save
  end

end