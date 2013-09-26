# encoding: utf-8
class Crawler::Gosky
  include Crawler

  def crawl_articles novel_id
    url = @page_url.sub("index.html","")
    nodes = @page_html.css("table")[3].css("a")
    nodes.each do |node|
      article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(url + node[:href])
      next if isArticleTextOK(article,article.text) if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node[:href]
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
    @page_html.css("#zw a").remove
    @page_html.css("#zw font").remove
    @page_html.css("#zw u").remove
    text = @page_html.css("#zw").text.strip
    text = text.gsub("wap.gosky.net", "")
    text = text.gsub("()", "")
    if text.length < 40
      text = @page_html.css("#c1c").text.strip
      text = text.gsub("wap.gosky.net", "")
      text = text.gsub("()", "")
    end
    article_text = ZhConv.convert("zh-tw",text)
    text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end