# encoding: utf-8
class Crawler::Qbxs8
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("ul li a")
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(node[:href]))
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = get_article_url(node[:href])
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
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
    @page_html.css("div.text a").remove
    @page_html.css("div.text h1").remove
    @page_html.css("div.text h2").remove
    @page_html.css("div.text script").remove
    text = change_node_br_to_newline(@page_html.css("div.text")).strip
    text = text.gsub("*  * 女  生 小  说  网 - http://www.qbxs8.com - 好  看  的  女  生 小  说     ★★★★★薄情锦郁★★★★★ ","")
    text = ZhConv.convert("zh-tw", text,false)
    
    if text.length < 100
      imgs = @page_html.css("div.text img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*" if img[:src].include?("qbxs8.com")
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      text = text_img
    end

    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end