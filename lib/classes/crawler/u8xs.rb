# encoding: utf-8
class Crawler::U8xs
  include Crawler
  
  def crawl_article article
    text = change_node_br_to_newline(@page_html.css("#content"))
    article_text = ZhConv.convert("zh-tw",text)
    text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end