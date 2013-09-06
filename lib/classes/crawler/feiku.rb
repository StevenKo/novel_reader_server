# encoding: utf-8
class Crawler::Feiku
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".clearfix ul li[itemprop='itemListElement'] a")
    nodes.each do |node|
      article = Article.find_by_link(node[:href])
      next if isArticleTextOK(article)

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
    node = @page_html.css(".art_wrap.mt15")
    node.css("a").remove
    node.css("script").remove
    text = change_node_br_to_newline(node)
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end