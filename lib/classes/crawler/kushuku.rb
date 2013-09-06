# encoding: utf-8
class Crawler::Kushuku
  include Crawler
  
  def crawl_article article
    @page_html.css("span").remove
    node = @page_html.css("#content")
    text = change_node_br_to_newline(node)
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end