# encoding: utf-8
class Crawler::Dwxs
  include Crawler
  
  def crawl_article article
    node = @page_html.css("#content")
    node.css("font,script").remove
    text = change_node_br_to_newline(node).strip
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    article.save
  end

end