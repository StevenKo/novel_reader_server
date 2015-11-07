# encoding: utf-8
class Crawler::Linovel
  include Crawler
  include Capybara::DSL

  def crawl_articles novel_id
    nodes = @page_html.css(".linovel-book-item")
    do_not_crawl = true
    nodes.each do |node|
      subject = ZhConv.convert("zh-tw",node.css("h3").text.gsub("\n","").gsub("\r","").gsub("\t",""),false)
      a_nodes = node.css(".linovel-chapter-list a")
      a_nodes.each do |a_node|
        next unless a_node[:href]

        if novel_id == 6874
          do_not_crawl = false if a_node[:href] == "/n/view/47537.html"
          next if do_not_crawl
        end

        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(a_node[:href]) + "?charset=big5")
        next if article

        unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = get_article_url(a_node[:href]) + "?charset=big5"
        article.title = ZhConv.convert("zh-tw",a_node.text.strip,false)
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
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    link = article.link
    Capybara.current_driver = :selenium
    Capybara.app_host = "http://www.linovel.com"
    page.visit(link.gsub("http://www.linovel.com",""))

    text = page.find(".linovel-chapter-mainContent").native.text
    text = ZhConv.convert("zh-tw", text.strip, false)

    if text.length < 100
      imgs = page.find(".linovel-chapter-mainContent img")
      text_img = ""
      imgs.each do |img|
        text_img = text_img + "http://www.linovel.com" + img["data-cover"] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      text = text_img
    end

    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end