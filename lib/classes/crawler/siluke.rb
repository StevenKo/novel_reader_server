# encoding: utf-8
class Crawler::Siluke
  include Crawler

  def crawl_articles novel_id
    url = @page_url
    subject = ""
    nodes = @page_html.css("#list dl").children
    nodes.each do |node|
      if node.name == "dt"
        subject = ZhConv.convert("zh-tw",node.text.strip)
      elsif (node.name == "dd" && node.css("a").present?)
        article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(url + node.children[0][:href])
        next if isArticleTextOK(article,article.text) if article

        unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node.children[0][:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip)
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
    node = @page_html.css("#content")
    node.css("script").remove
    text = change_node_br_to_newline(node).strip
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    article.save
  end

end