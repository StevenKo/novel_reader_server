# encoding: utf-8
class Crawler::Yqxw
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".contents_body_nr_02 a")
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
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
  end

  def crawl_article article
    nodes = @page_html.css(".readpage_body_nr_02")
    nodes.css("a").remove
    text  = change_node_br_to_newline(nodes).strip
    article.text = text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end