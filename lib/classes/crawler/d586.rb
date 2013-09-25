# encoding: utf-8
class Crawler::D586
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".xiaoshou_list ul a")
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name
    nodes.each do |node|
      article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link("http://www.d586.com" + node[:href])
      next if isArticleTextOK(article)

      unless article 
      article = Article.new
      article.novel_id = novel_id
      article.link = "http://www.d586.com" + node[:href]
      article.title = ZhConv.convert("zh-tw",node.text.strip)
      article.subject = subject
      /\/(\d+)\// =~ node[:href]
      next if $1.nil?
      article.num = $1.to_i
      # puts node.text
      article.save
      end
      # novel.num = article.num + 1
      # novel.save
      ArticleWorker.perform_async(article.id)
    end
  end

  def crawl_article article
    node = @page_html.css(".content")
    node.css("a").remove
    node.css("script").remove
    text = change_node_br_to_newline(node)
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end