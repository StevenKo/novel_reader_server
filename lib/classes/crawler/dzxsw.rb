# encoding: utf-8
class Crawler::Dzxsw
  include Crawler

  def crawl_articles novel_id
    url = "http://www.dzxsw.net"
    subject = ""
    nodes = @page_html.css(".list").children
    if nodes.present?
      nodes.each do |node|
        if node[:class] == "book"
          subject = ZhConv.convert("zh-tw",node.text.strip)
        elsif node[:class] == nil
          inside_nodes = node.css("a")
          inside_nodes.each do |in_node|
            article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + in_node[:href])
            next if article

            unless article 
              article = Article.new
              article.novel_id = novel_id
              article.link = url + in_node[:href]
              article.title = ZhConv.convert("zh-tw",in_node.text.strip)
              novel = Novel.select("id,num,name").find(novel_id)
              article.subject = subject
              article.num = novel.num + 1
              novel.num = novel.num + 1
              novel.save
              # puts node.text
              article.save
            end
            ArticleWorker.perform_async(article.id)
          end
        end
      end
    else
      uls = @page_html.css(".List2013 ul")
      uls.each_with_index do |ul, i|
        next if i == 0
        nodes = ul.css("a")
        nodes.each do |node|
          article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link("http://www.dzxsw.net"+ node[:href])
          next if article

          unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = "http://www.dzxsw.net" + node[:href]
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
      end
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article

    node = @page_html.css("#content")
    node.css(".ad_chapter, script, .announce, .ud, .local, a").remove

    text = change_node_br_to_newline(node).strip
    text = text.gsub(/\/\d*/,"")
    text = text.gsub("'>","")
    text = text.gsub(".+?","")
    article_text = ZhConv.convert("zh-tw",text)
    text = article_text
    
    if text .length < 100
      
      if @page_html.css("#content img").present?
        imgs = @page_html.css("#content img")
      else
        imgs = @page_html.css("#contents img")
      end

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