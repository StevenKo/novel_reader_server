# encoding: utf-8
class Crawler::Xs555
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("dd a")
    nodes.each do |node|
      url = @page_url + node[:href]
      article = Article.find_by_link(url)
      next if isArticleTextOK(article)

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url
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
    node = @page_html.css("body")
    node.css("script,a,.tipinfo,#breadCrumb,#shop,#thumb,#tips,#feit2,#copyRight").remove
    text = change_node_br_to_newline(node)
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end