# encoding: utf-8
class Crawler::Ranwenba
  include Crawler
  
  def crawl_article article
    node = @page_html.css("#booktext")
    node.css("script").remove
    text = change_node_br_to_newline(node)
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end