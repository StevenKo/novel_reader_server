# encoding: utf-8
class Crawler::K6uk
  include Crawler
  
  def crawl_article article
    text = @page_html.css("#content").text.strip
    article_text = ZhConv.convert("zh-tw",text)
    article.text = article_text
    article.save
  end

end