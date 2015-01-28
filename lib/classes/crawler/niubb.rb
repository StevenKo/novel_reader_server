# encoding: utf-8
class Crawler::Niubb
  include Crawler

  def crawl_articles novel_id
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name
    nodes = @page_html.css(".box_con #list a")
    nodes.each_with_index do |a_node,i|
      url = @page_url + a_node[:href]
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url)
      next if article
      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url
        article.title = ZhConv.convert("zh-tw",a_node.text.strip) 
        article.subject = subject
        article.num = novel.num + 1
        novel.num = novel.num + 1
        novel.save
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css("#content")
    node.css("table,script").remove
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end