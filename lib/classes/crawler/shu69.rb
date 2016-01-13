# encoding: utf-8
class Crawler::Shu69
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".mu_contain")
    nodes = nodes[1].css(".mulu_list a")
    do_not_crawl = true
    nodes.each do |node|
      do_not_crawl = false if crawl_this_article(novel_id,node[:href])
      next if do_not_crawl
      
      if novel_id == 20703
        do_not_crawl = false if node[:href] == "/txt/15418/12091444"
        next if do_not_crawl
      end
      if novel_id == 22539
        do_not_crawl = false if node[:href] == "/txt/21093/12344684"
        next if do_not_crawl
      end
      if novel_id == 20703
        do_not_crawl = false if node[:href] == "/txt/15418/12420569"
        next if do_not_crawl
      end
      if novel_id == 16478
        do_not_crawl = false if node[:href] == "/txt/6693/12423769"
        next if do_not_crawl
      end
      if novel_id == 18000
        do_not_crawl = false if node[:href] == "/txt/3305/12421754"
        next if do_not_crawl
      end
      if novel_id == 20394
        do_not_crawl = false if node[:href] == "/txt/12418/7669461"
        next if do_not_crawl
      end
      if novel_id == 23135
        do_not_crawl = false if node[:href] == "/txt/19345/12887519"
        next if do_not_crawl
      end
      if novel_id == 18682
        do_not_crawl = false if node[:href] == "/txt/1848/12472530"
        next if do_not_crawl
      end
      if novel_id == 18784
        do_not_crawl = false if node[:href] == "/txt/8591/12429200"
        next if do_not_crawl
      end
      if novel_id == 20831
        do_not_crawl = false if node[:href] == "/txt/6134/12464123"
        next if do_not_crawl
      end
      if novel_id == 19164
        do_not_crawl = false if node[:href] == "/txt/7868/12430937"
        next if do_not_crawl
      end

      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link("http://www.69shu.com" + node[:href])
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = "http://www.69shu.com" + node[:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        if novel_id == 23135
          article.num = novel.num + 1 + 7688662
        else
          article.num = novel.num + 1
        end
        novel.num = novel.num + 1
        novel.save
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css(".yd_text2")
    node.css("a, #txtright").remove
    text = change_node_br_to_newline(node).strip
    article_text = ZhConv.convert("zh-tw",text,false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end