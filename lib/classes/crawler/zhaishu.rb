# encoding: utf-8
class Crawler::Zhaishu
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("#BookText a")
    nodes.each do |node|
      article = Article.find_by_link(@page_url + node[:href])
      next if isArticleTextOK(article)

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
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
  end

  def crawl_article article
    node = @page_html.css("#texts")
    node.css("script,a,h2").remove
    text = change_node_br_to_newline(node).strip
    text = text.gsub("完结穿越小说推荐：","")
    text = text.gsub("\r\n","")
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end