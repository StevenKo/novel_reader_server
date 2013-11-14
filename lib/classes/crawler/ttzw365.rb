# encoding: utf-8
class Crawler::Ttzw365
  include Crawler

  def crawl_article article
    node = @page_html.css("#contents")
    node.css("a").remove
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end