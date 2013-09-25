# encoding: utf-8
class Crawler::Bsxsw
  include Crawler

  def crawl_articles novel_id
    url = "http://www.bsxsw.com"
    nodes = @page_html.css(".chapterlist a")
    nodes.each do |node|
      article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(url + node[:href])
      next if isArticleTextOK(article)

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node[:href]
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
    text = @page_html.css(".ReadContents").text
    text = text.gsub("上一章  |  万事如易目录  |  下一章","")
    text = text.gsub("=波=斯=小=说=网= bsxsw.com","")
    text = text.gsub("sodu,,返回首页","")
    text = text.gsub("sodu","")
    text = text.gsub("zybook,返回首页","")
    text = text.gsub("zybook","")
    text = text.gsub("三月果)","")
    text = text.gsub("三月果","")
    text = text.gsub("处理SSI文件时出错","")
    text = text.gsub("收费章节(12点)","")
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end