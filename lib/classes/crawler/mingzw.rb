# encoding: utf-8
class Crawler::Mingzw
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".content a")
    nodes.each do |node|
      article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link("http://tw.mingzw.com/" + node[:href])
      next if isArticleTextOK(article,article.text) if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = "http://tw.mingzw.com/" + node[:href]
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
    node = @page_html.css(".content")
    node.css("a,script").remove
    text = change_node_br_to_newline(node).strip
    text = text.gsub("如需請通過此鏈接進入沖囍下載頁面","")
    text = text.gsub("明智屋中文","")
    text = text.gsub("wWw.MinGzw.cOm","")
    text = text.gsub("沒有彈窗","")
    text = text.gsub("更新及時","")
    text = text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end