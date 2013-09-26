# encoding: utf-8
class Crawler::Xiaoshuozhe
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".list dl").children
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name

    nodes.each do |node|
      if (node.name == "dt")
        subject = node.text
      elsif node.name == "dd"
        node = node.css("a")[0]
        url = @page_url + node[:href]
        article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(url)
        next if isArticleTextOK(article,article.text) if article

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url
          article.title = ZhConv.convert("zh-tw",node.text.strip)
          article.subject = ZhConv.convert("zh-tw",subject)
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
    node = @page_html.css("#BookText")
    node.css("#ad_right").remove
    node.css("font").remove
    text = node.text.strip
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    article.save
  end

end