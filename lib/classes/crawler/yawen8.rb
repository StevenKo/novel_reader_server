# encoding: utf-8
class Crawler::Yawen8
  include Crawler

  def crawl_articles novel_id
    url = @page_url
    nodes = @page_html.css(".bookUpdate a")
    nodes.each do |node|
      if (node.text.index("yawen8") ==nil)
        article = Article.find_by_link(url + node[:href])
        next if isArticleTextOK(article)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url + node[:href]
          title = node.text.strip
          title = title.gsub("www.yawen8.com","")
          title = title.gsub("雅文言情小说","")
          title = title.gsub("()","")
          article.title = ZhConv.convert("zh-tw",title)
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

  def crawl_article article
    node = @page_html.css("div.txtc")
    node.css("script").remove
    article_text = ZhConv.convert("zh-tw",node.text.strip)

    if article_text.index('本章未完')
      nodes = @page_html.css("#pagelink a")
      nodes.each do |page_node|
        c = Crawler::NovelCrawler.new
        c.fetch @page_url.sub(/\d*\.html/,"")+page_node[:href]
        text = ZhConv.convert("zh-tw",c.page_html.css("div.txtc").text.strip)
        article_text += text
      end
    end

    article_text = article_text.gsub("［本章未完，請點擊下一頁繼續閱讀！］","")
    article_text = article_text.gsub("...   ","")
    article.text = article_text

    if (article.text.length < 150 )
      imgs = @page_html.css(".piccontent img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      article.text = text_img
      article.save
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end