# encoding: utf-8
class Crawler::Biqugetw
  include Crawler

  def crawl_articles novel_id
    host = "http://www.biquge.com.tw"
    subject = ""
    nodes = @page_html.css("#list dl").children
    nodes.each do |node|
      if node.name == "dt"
        next
      elsif (node.name == "dd" && node.css("a").present?)
        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(host + node.children[0][:href])
        next if article

        unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = host + node.children[0][:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        /(\d*)\.html/ =~ node.children[0][:href]
        article.num = $1.to_i
        # puts node.text
        article.save
        end
        ArticleWorker.perform_async(article.id)          
      end
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css("#content")
    node.css("script").remove
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end