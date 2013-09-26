# encoding: utf-8
class Crawler::Sfacg
  include Crawler

  def crawl_articles novel_id
    @page_html.css("div.list_menu_title .Download_box").remove
    @page_html.css("div.list_menu_title a").remove
    subjects = @page_html.css("div.list_menu_title")
    subject_titles = []

    subjects.each do |subject|
      text = subject.text
      text = text.gsub("【】","")
      text = text.gsub("下载本卷","")
      subject_titles << ZhConv.convert("zh-tw",text.strip)
    end

    num = @page_html.css(".list_Content").size()
    index = 0
    while index < num do
      nodes = @page_html.css(".list_Content")[index].css("a")
      nodes.each do |node|
          next unless node[:href]
          article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link("http://book.sfacg.com" + node[:href])
          if (article != nil)
            article.subject = subject_titles[index]
            article.save
          end
          next if isArticleTextOK(article,article.text) if article

          unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = "http://book.sfacg.com" + node[:href]
            article.title = ZhConv.convert("zh-tw",node.text.strip)
            novel = Novel.select("id,num,name").find(novel_id)
            article.subject = subject_titles[index]
            article.num = novel.num + 1
            novel.num = novel.num + 1
            novel.save
              # puts node.text
            article.save
          end
          ArticleWorker.perform_async(article.id)
        end
      index = index +1        
    end
  end

  def crawl_article article
    node = @page_html.css("#ChapterBody")
    text = change_node_br_to_newline(node)
    if text.length < 50
      url = "http://book.sfacg.com"
      imgs = @page_html.css("#ChapterBody img")
      text_img = ""
      imgs.each do |img|
        if img[:src].index("sfacg.com")
          text_img = text_img + img[:src] + "*&&$$*"
        else
          text_img = text_img + url + img[:src] + "*&&$$*"
        end
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版"
      article.text = text_img
    else
      article.text = ZhConv.convert("zh-tw", text)
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    article.save
  end

end