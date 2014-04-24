# encoding: utf-8
class Crawler::Piaotian
  include Crawler
  include Capybara::DSL

  def crawl_articles novel_id
    nodes = @page_html.css(".centent a")
    nodes.each do |node|
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(@page_url + node[:href])
      next if article
      next if @page_url.index('javascript:window')

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
      CapybaraArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    link = article.link
    Capybara.current_driver = :selenium
    Capybara.app_host = "http://www.piaotian.net/"
    page.visit(link.gsub("http://www.piaotian.net",""))

    content = page.find("#content").native.text
    node = Nokogiri::HTML(content)
    node.css("table,a,#thumb,#Commenddiv,#tips,#tags,#feit2").remove
    text = change_node_br_to_newline(node).strip
    article_text = ZhConv.convert("zh-tw",text)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end