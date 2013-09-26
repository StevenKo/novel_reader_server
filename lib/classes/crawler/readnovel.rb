# encoding: utf-8
class Crawler::Readnovel
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".listPanel li a")
    nodes.each do |node|
      article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(node[:href])
      next if isArticleTextOK(article,article.text) if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = node[:href]
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
    text = @page_html.css(".mainContentNew").text.strip
    text = text.gsub("温馨提示：手机小说阅读网请访问m.xs.cn，随时随地看小说！公车、地铁、睡觉前、下班后想看就看。查看详情","")
    text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end