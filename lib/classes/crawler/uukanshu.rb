# encoding: utf-8
class Crawler::Uukanshu
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("#chapterList a")
    do_not_crawl = true
    nodes.reverse_each do |node|
      if novel_id == 23463
        do_not_crawl = false if node[:href] == '/b/30530/119958.html'
        next if do_not_crawl
      end
      if novel_id == 22801
        do_not_crawl = false if node[:href] == '/b/30981/119690.html'
        next if do_not_crawl
      end
      if novel_id == 23515
        do_not_crawl = false if node[:href] == '/b/11360/129550.html'
        next if do_not_crawl
      end
      if novel_id == 23271
        do_not_crawl = false if node[:href] == '/b/29508/125824.html'
        next if do_not_crawl
      end
      if novel_id == 22521
        do_not_crawl = false if node[:href] == '/b/29932/125794.html'
        next if do_not_crawl
      end
      if novel_id == 23221
        do_not_crawl = false if node[:href] == '/b/29753/125062.html'
        next if do_not_crawl
      end
      if novel_id == 22061
        do_not_crawl = false if node[:href] == '/b/27371/154754.html'
        next if do_not_crawl
      end
      if novel_id == 23391
        do_not_crawl = false if node[:href] == '/b/31700/116484.html'
        next if do_not_crawl
      end
      if novel_id == 23141
        do_not_crawl = false if node[:href] == '/b/29098/139854.html'
        next if do_not_crawl
      end
      if novel_id == 22373
        do_not_crawl = false if node[:href] == '/b/26608/157272.html'
        next if do_not_crawl
      end
      if novel_id == 23319
        do_not_crawl = false if node[:href] == '/b/30660/120951.html'
        next if do_not_crawl
      end
      if novel_id == 22691
        do_not_crawl = false if node[:href] == '/b/29909/126149.html'
        next if do_not_crawl
      end
      if novel_id == 21685
        do_not_crawl = false if node[:href] == '/b/10053/94848.html'
        next if do_not_crawl
      end
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(node[:href]))
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = get_article_url(node[:href])
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
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