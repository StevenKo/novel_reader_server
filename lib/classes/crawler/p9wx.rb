# encoding: utf-8
class Crawler::P9wx
  include Crawler
  
  def crawl_articles novel_id
    url = @page_url
    nodes = @page_html.css(".booklist span a")
    nodes.each do |node|
      next unless node[:onclick]
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + "**" +node[:onclick])
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + "**" +node[:onclick]
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

    link = article.link.split("**")[0]
    onclick = article.link.split("**")[1]
    /gotochap\((\d*),(\d*)\)/ =~ onclick
    chpid = ($2.to_i-9)/2;
    url = "http://tw.9pwx.com/view/" + $1 + "/" + chpid.to_s + ".html"
    crawler = CrawlerAdapter.get_instance(url)
    crawler.fetch(url)

    text = ""

    crawler.page_html.css(".bookcontent #msg-bottom, #adboxhide").remove
    text = change_node_br_to_newline(crawler.page_html.css('.bookcontent')).strip
    text = ZhConv.convert("zh-tw", text)

    
    if text.size < 200
      url = "http://tw.9pwx.com"
      imgs = crawler.page_html.css('.divimage img')

      text_img = ""
      imgs.each do |img|
        if img[:src].index('9pwx')
          text_img = text_img + img[:src] + "*&&$$*"
        else
          text_img = text_img + url + img[:src] + "*&&$$*"
        end
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      text = text_img
    end

    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)   
    ArticleText.update_or_create(article_id: article.id, text: text)
    sleep(2)
  end

end