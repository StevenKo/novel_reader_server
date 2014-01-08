# encoding: utf-8
class Crawler::Dushi800
  include Crawler
  include Capybara::DSL

  def crawl_articles novel_id

    url = @page_url
    nodes = @page_html.css(".booklist span a")
    nodes.each do |node|
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + "**" +node[:onclick])
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + "**" +node[:onclick]
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
  end

  def crawl_article article
    Capybara.current_driver = :selenium
    Capybara.app_host = "http://www.dushi800.com/"
    
    link = article.link.split("**")[0]
    onclick = article.link.split("**")[1]
    page.visit(link.gsub("http://www.dushi800.com",""))
    node = page.find("a[onclick='#{onclick}']")
    node.click

    text = page.find('.bookcontent').native.text
    text = ZhConv.convert("zh-tw", text)
    
    if text.size < 100
      imgs = page.all('.divimage img')
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      text = text_img
    end

    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end