# encoding: utf-8
class Crawler::Xiaoshuokan
  include Crawler

  def crawl_articles novel_id
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name
    nodes = @page_html.css(".booklist span")
    nodes.each do |node|
      if(node[:class]=="v")
        subject = ZhConv.convert("zh-tw",node.text.strip.gsub(".",""))
      else
        a_node = node.css("a")[0]
        url = "http://tw.xiaoshuokan.com" + a_node[:href]
        article = Article.find_by_link(url)
        next if isArticleTextOK(article)
        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url
          article.title = ZhConv.convert("zh-tw",a_node.text.strip) 
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
    node = @page_html.css(".bookcontent")
    text = change_node_br_to_newline(node).strip
    text = text.gsub(/&(.*)WWW.3Zcn.net/,"")
    text = text.gsub(/&(.*)WWW.3Zcn.net/,"")
    text = text.gsub("三藏中文","")
    text = text.gsub("bsp","")
    text = text.gsub("Www.Xiaoshuokan.com","")
    text = text.gsub("好看小說網","")
    text = text.gsub("(本章免費)","")
    text = text.gsub("&n8","")
    text = text.gsub("ｏ","")
    text = text.gsub("&nWww.xiaoｓhuoｋａn.Com","")
    text = text.gsub("WWW.ｘｉａｏｓｈｕｏｋａｎ.ｃｏｍ","")
    article.text = text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end