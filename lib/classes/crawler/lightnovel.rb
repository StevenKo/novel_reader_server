# encoding: utf-8
class Crawler::Lightnovel
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("dd.mg-15")
    nodes.each do |node|
      subject = ZhConv.convert("zh-tw",node.css(".ft-24").text.gsub("\n","").gsub("\r","").gsub("\t",""))
      a_nodes = node.css(".inline a")
      a_nodes.each do |a_node|
        article = Article.find_by_link(a_node[:href])
        next if isArticleTextOK(article)

        unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = a_node[:href]
        article.title = ZhConv.convert("zh-tw",a_node.text.strip)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = subject
        article.num = novel.num + 1
        novel.num = novel.num + 1
        novel.save
        # puts node.text
        article.save
        end
        ArticleWorker.perform_async(article.id)    
      end
    end
  end

  def crawl_article article
    node = @page_html.css("#J_view")
    text = change_node_br_to_newline(node)
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end