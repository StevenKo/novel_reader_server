# encoding: utf-8
class Crawler::Xuanhutang
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".acss tr a")
    nodes.each do |node|
      article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(@page_url + node[:href])
      next if isArticleTextOK(article,article.text) if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = @page_url + node[:href]
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

  def crawl_article article
    @page_html.xpath("//div[@align='center']").remove
    @page_html.xpath("//div[@style='padding:6px 12px;line-height:20px;']").remove
    @page_html.css("#content a").remove
    text = @page_html.css("#content").text.strip
    text = text.gsub("看校园小说到-玄葫堂","")
    article_text = ZhConv.convert("zh-tw",text)

    if (article_text.length < 250)
      imgs = @page_html.css(".divimage img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      article_text = text_img
    end
    article.text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    article.save
  end

end