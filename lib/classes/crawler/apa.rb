# encoding: utf-8
class Crawler::Apa
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("a[target=_self]")
    nodes.each do |node|
      next unless node[:href].index("page")
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
    node = @page_html.css(".smalltext")[0].parent
    node.css("font").remove
    node.css("p.smalltext").remove
    node.css("p[style='border:5px solid #fed2fe; color:#FF00FF; background-color:#fed2fe;']").remove
    text = change_node_br_to_newline(node).strip
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end