# encoding: utf-8
class Crawler::Dmzj
  include Crawler
  include Capybara::DSL

  def crawl_articles novel_id
    Capybara.current_driver = :selenium
    Capybara.app_host = @url_host
    page.visit(@page_url.gsub(@url_host,""))
    
    binding.pry
    nodes = @page_html.css("#sort_div_p").childes
    do_not_crawl = true
    nodes.reverse_each do |node|
      if node[:class] == "chapname"
        subject = ZhConv.convert("zh-tw",node.css(".chapnamesub").text.strip,false)
      else
        a_nodes = node.css("a")
        a_nodes.each do |a_node|
          if novel_id == 23463
            do_not_crawl = false if a_node[:href] == '/b/30530/119958.html'
            next if do_not_crawl
          end
          article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(a_node[:href]))
          next if article

          unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = get_article_url(a_node[:href])
            article.title = ZhConv.convert("zh-tw",a_node.text.strip,false)
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
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css("#contentbox")
    node.css("script,a").remove
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end