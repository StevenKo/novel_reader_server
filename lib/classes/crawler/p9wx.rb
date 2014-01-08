# encoding: utf-8
class Crawler::P9wx
  include Crawler
  include Capybara::DSL

  def crawl_articles novel_id
    url = @page_url
    nodes = @page_html.css(".booklist span a")
    nodes.each do |node|
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
      CapybaraArticleWorker.perform_async(article.id)
    end
  end

  def crawl_article article

    text = ""

    Capybara.current_driver = :selenium
    Capybara.app_host = "http://tw.9pwx.com"

    if(article.link.split("**").size == 2)
      link = article.link.split("**")[0]
      onclick = article.link.split("**")[1]
      page.visit(link.gsub("http://tw.9pwx.com",""))
      node = page.find("a[onclick='#{onclick}']")
      node.click

      text = page.find('.bookcontent').native.text
      text = ZhConv.convert("zh-tw", text)
      
      if text.size < 100
        url = "http://tw.9pwx.com"
        imgs = page.all('.divimage img')
        text_img = ""
        imgs.each do |img|
            text_img = text_img + url + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版APP"
        text = text_img
      end
    else
      @page_html.css(".bookcontent #msg-bottom").remove
      text = @page_html.css(".bookcontent").text.strip
      if text.length < 100
        begin
          url = "http://tw.9pwx.com"
          imgs = @page_html.css(".divimage img")
          text_img = ""
          imgs.each do |img|
              text_img = text_img + url + img[:src] + "*&&$$*"
          end
          text_img = text_img + "如果看不到圖片, 請更新至新版APP"
          text = text_img
        rescue Exception => e      
        end
      else
        article_text = text.gsub("鑾勾絏ュ庤鎷誨潒濯兼煉鐪磭榪惰琚氣-官家求魔殺神武動乾坤最終進化神印王座| www.9pwx.com","")
        article_text = text.gsub("鍗兼雞銇264264-官家求魔殺神武動乾坤最終進化神印王座|","")
        article_text = text.gsub("www.9pwx.com","")
        text = article_text.strip
      end
    end

    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)   
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end