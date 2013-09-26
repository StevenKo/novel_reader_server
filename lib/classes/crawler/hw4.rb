# encoding: utf-8
class Crawler::Hw4
  include Crawler
  
  def crawl_article article
    @page_html.css(".art_cont .art_ad,.art_cont .fenye, .art_cont .tishi").remove
    article_text = ZhConv.convert("zh-tw",@page_html.css(".art_cont").text.strip)
    article.text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    article.save
  end

end