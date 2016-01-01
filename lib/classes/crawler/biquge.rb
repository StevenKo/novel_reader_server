# encoding: utf-8
class Crawler::Biquge
  include Crawler

  def crawl_articles novel_id
    subject = ""
    nodes = @page_html.css("#list a")
    do_not_crawl = true
    nodes.each do |node|
      if novel_id == 21894
        do_not_crawl = false if node[:href] == "/9_9375/4998433.html"
        next if do_not_crawl
      end
      if novel_id == 21431
        do_not_crawl = false if node[:href] == "/36_36005/2416840.html"
        next if do_not_crawl
      end
      if novel_id == 22539
        do_not_crawl = false if node[:href] == "/35_35371/2105274.html"
        next if do_not_crawl
      end
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(node[:href]))
      next if article

      unless article 
      article = Article.new
      article.novel_id = novel_id
      article.link = get_article_url(node[:href])
      article.title = ZhConv.convert("zh-tw",node.text.strip,false)
      novel = Novel.select("id,num,name").find(novel_id)
      article.subject = novel.name
      /(\d*)\.html/ =~ node[:href]
      article.num = $1.to_i
      article.num = $1.to_i + novel.num if novel_id == 21431
      article.num = $1.to_i + novel.num if novel_id == 22539
      # puts node.text
      article.save
      end
      ArticleWorker.perform_async(article.id)          
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css("#content")
    node.css("script").remove
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end