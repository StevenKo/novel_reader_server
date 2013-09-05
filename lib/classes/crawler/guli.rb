# encoding: utf-8
class Crawler::Guli
  include Crawler
  
  def crawl_article article
    text = @page_html.css("div#content").text.strip
    text = text.gsub("txtrightshow();","").strip
    article.text = ZhConv.convert("zh-tw", text)
    article.save
  end

end