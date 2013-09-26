# encoding: utf-8
class Crawler::Hjwzw
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("#tbchapterlist tr a")
    nodes.each do |node|
      article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link("http://tw.hjwzw.com" + node[:href])
      next if isArticleTextOK(article,article.text) if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = "http://tw.hjwzw.com" + node[:href]
        article.title = node.text.strip
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
    @page_html.css("#AllySite")[0].next.next
    @page_html.css("#AllySite")[0].next.next.css("a").remove
    @page_html.css("#AllySite")[0].next.next.css("b").remove
    text = @page_html.css("#AllySite")[0].next.next.text.strip
    text = text.gsub("返回書頁","")
    text = text.gsub("回車鍵","")
    text = text.gsub("快捷鍵: 上一章(\"←\"或者\"P\")","")
    text = text.gsub("下一章(\"→\"或者\"N\")","")
    text = text.gsub("在搜索引擎輸入","")
    text = text.gsub("就可以找到本書","")
    text = text.gsub("最快,最新TXT更新盡在書友天下:本文由“網”書友更新上傳我們的網址是“”如章節錯誤/舉報謝","")
    text = text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end