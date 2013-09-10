# encoding: utf-8
class Crawler::Buk52
  include Crawler
  
  def crawl_article article
    text = @page_html.css(".novelcon").text.strip
    article_text = ZhConv.convert("zh-tw",text)
    article.text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end