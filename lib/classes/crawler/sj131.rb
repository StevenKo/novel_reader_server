# encoding: utf-8
class Crawler::Sj131
  include Crawler

  def crawl_articles novel_id
    url = @page_url
    subject = ""
    nodes = @page_html.css(".booklist dl").children
    nodes.each do |node|
      if node.name == "dt"
        subject = ZhConv.convert("zh-tw",node.text.strip)
      elsif (node.name == "dd" && node.css("a").present?)
        article = Article.find_by_link(url + node.children[0][:href])
        next if isSkipCrawlArticle(article)

        unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node.children[0][:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip)
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

  def crawl_article article
    if @page_html.css("#content").text != ""
      @page_html.css("#content a").remove
      article_text = ZhConv.convert("zh-tw",@page_html.css("#content").text.strip)
      article_text = article_text.gsub("如果您喜歡這個章節","")
      article_text = article_text.gsub("精品小說推薦","")
      article.text = article_text
      article.save
    elsif @page_html.css(".contentbox").text != ""
      @page_html.css(".contentbox a").remove
      article_text = ZhConv.convert("zh-tw",@page_html.css(".contentbox").text.strip)
      article_text = article_text.gsub("如果您喜歡這個章節","")
      article_text = article_text.gsub("精品小說推薦","")
      article.text = article_text
      article.save
    else
      @page_html.css("#table_container a").remove
      @page_html.css("#table_container span").remove
      article_text = ZhConv.convert("zh-tw",@page_html.css("#table_container").text.strip)
      article_text = article_text.gsub("如果您喜歡這個章節","")
      article_text = article_text.gsub("精品小說推薦","")
      article.text = article_text
      article.save
    end
    if (article.text.length < 150 )
      imgs = @page_html.css("img.imagecontent")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      article.text = text_img
      article.save
    end
  end

end