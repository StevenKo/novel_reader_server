# encoding: utf-8
class Crawler::D5wx
  include Crawler

  def crawl_articles novel_id
    url = @page_url
    nodes = @page_html.css("tr.ccss a")
    nodes.each do |node|
      article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(url + node[:href])
      next if isArticleTextOK(article)

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node[:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        s = node[:href]
        /(\d*)\.shtml/ =~ s
        /cid=(\d*)/ =~ s if($1.nil?)
        article.num = $1.to_i
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
  end

  def crawl_article article
    text = @page_html.css("td#contenthtzw").text.strip
    article.text = ZhConv.convert("zh-tw", text)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end