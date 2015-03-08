# encoding: utf-8
class Crawler::Shumilou
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".zl a")
    nodes.each do |node|
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(node[:href])
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = node[:href]
        article.title = node.text.strip
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        article.num = novel.num + 1
        novel.num = novel.num + 1
        novel.save
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    @page_html.css("#content span").remove
    @page_html.css("#content b").remove
    @page_html.css("#content .title").remove
    @page_html.css("#content script").remove
    @page_html.css("#content a").remove
    @page_html.css("div[style='color:#FF0000']").remove
    @page_html.css("center[style='font-size:15px']").remove
    text = @page_html.css("#content").text.strip
    article_text = ZhConv.convert("zh-tw",text)
    text = article_text

    if text.size < 100
      imgs = @page_html.css("#content img")
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