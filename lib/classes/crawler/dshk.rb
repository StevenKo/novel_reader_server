# encoding: utf-8
class Crawler::Dshk
  include Crawler

  def crawl_articles novel_id
    size = @page_html.css(".pages  a").size
    if size < 20
      last_node = @page_html.css(".pages  a")[size - 2]
    else
      last_node = @page_html.css(".pages  a.last")[0]
    end
    if last_node.nil?
      article = Article.new
      article.novel_id = novel_id
      article.link = @page_url
      article.title = '全'
      novel = Novel.select("id,num,name").find(novel_id)
      article.subject = novel.name
      article.save
      ArticleWorker.perform_async(article.id)
    else
      /thread-(\d*)-(\d*)-(\d*)/ =~ last_node[:href]
      (1..$2.to_i).each do |i|
        url = "http://ds-hk.net/thread-" + $1 + "-" + i.to_s + "-" +$3 + ".html"
        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url)
        next if article
        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url
          article.title = i.to_s
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
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css(".t_msgfont")
    node.css("span,font").remove
    text = node.text.strip
    text = text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end