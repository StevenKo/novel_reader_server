# encoding: utf-8
class Crawler::U8xs
  include Crawler
  
  def crawl_article article
    text = change_node_br_to_newline(@page_html.css("#content"))
    article_text = ZhConv.convert("zh-tw",text)
    text = article_text
    
    if text.length < 100
      imgs = @page_html.css(".divimage img")
      imgs = @page_html.css("#content_text img") unless imgs.present?
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      text = text_img
    end

    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end