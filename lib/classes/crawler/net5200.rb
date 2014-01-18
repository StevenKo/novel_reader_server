# encoding: utf-8
class Crawler::Net5200
  include Crawler

  def crawl_articles novel_id

    nodes = @page_html.css("#chapterlist a")
    nodes.each do |node|

      (node[:href].index("5200.net"))? link = node[:href] : link = "http://5200.net/" + node[:href]
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(link)
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = link
        article.title = ZhConv.convert("zh-tw",node.text.strip)
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

    @page_html.css("script,a,table,td,.header,#www5200_net_topimg,.title,#shop,head,center,.copyright,#shop1").remove
    node = @page_html
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text.strip)
    
    if text .length < 80
      imgs = @page_html.css("img")
      text_img = ""
      imgs.each do |img|
        text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版"
      text = text_img
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end