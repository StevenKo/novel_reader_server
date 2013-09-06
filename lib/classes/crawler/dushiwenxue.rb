# encoding: utf-8
class Crawler::Dushiwenxue
  include Crawler

  def crawl_articles novel_id
    url = @page_url.sub("index.html","")
    nodes = @page_html.css(".ccss a")
    nodes.each do |node|
      article = Article.find_by_link(url + node[:href])
      next if isArticleTextOK(article)

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node[:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        /(\d*)/ =~ node[:href]
        article.num = $1.to_i
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
  end

  def crawl_article article
    node = @page_html.css("#content")
    node.css("div[style='float:right;']").remove
    node.css("center").remove
    text = change_node_br_to_newline(node)
    article.text = ZhConv.convert("zh-tw", text.strip)
    if text.length < 100
      imgs = @page_html.css("#content .divimage img")
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