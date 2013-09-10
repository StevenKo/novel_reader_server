# encoding: utf-8
class Crawler::Bookzx
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("#tigtag_content4 ul li a")
    nodes.each do |node|
      article = Article.find_by_link(@page_url + node[:href])
      next if isArticleTextOK(article)

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = @page_url + node[:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        article.num = novel.num + 1
        novel.num = novel.num + 1
        novel.save
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
  end

  def crawl_article article
    node = @page_html.css("#tigtag_size")
    node.css("a").remove
    node.css("script").remove
    text = change_node_br_to_newline(node)
    article.text = ZhConv.convert("zh-tw", text.strip)

    if text.length < 100
      imgs = @page_html.css("#tigtag_size img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      article.text = text_img
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end