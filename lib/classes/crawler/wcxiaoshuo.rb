# encoding: utf-8
class Crawler::Wcxiaoshuo
  include Crawler
  
  def crawl_article article
    @page_html.css("#htmlContent a").remove
    @page_html.css("#htmlContent img").remove
    text = @page_html.css("#htmlContent").text.strip
    text = text.gsub("由【无*错】【小-说-网】会员手打，更多章节请到网址：www.wcxiaoshuo.com","")
    article_text = ZhConv.convert("zh-tw",text)
    article.text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end