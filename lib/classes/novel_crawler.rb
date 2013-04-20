# encoding: utf-8
class NovelCrawler
  include Crawler

  def crawl_from_old_db

  end

  def crawl_novels category_id
    # puts @page_url
    nodes = @page_html.css("#ItemContent_dl")
    nodes = nodes.children
    
    puts "error" if nodes.size == 0

    nodes.each do |novel_row|
      novels = novel_row.children
      
      begin 
        (1..3).each do |i|
          novel_html = novels[i-1]
          link = "http://www.bestory.com" + novel_html.css("a")[0][:href]
          novel = Novel.find_by_link link
          unless novel
            novel = Novel.new
            novel.link = link
            novel.category_id = category_id
            novel.save
          end
          CrawlWorker.perform_async(novel.id)
        end
      rescue
      end 
    end

    # page_nodes = @page_html.css("#ItemContent_pager")
    # next_link = page_nodes.css("font")[0].parent.next.css("a")
    
    # if next_link.present?
    #   next_page_link = "http://www.bestory.com/category/" + next_link[0][:href]
    #   puts next_page_link
    #   crawler = NovelCrawler.new
    #   crawler.fetch next_page_link
    #   crawler.crawl_novels category_id
    # end
  end
  

  def crawl_novel_detail novel_id
    novel = Novel.find(novel_id)

    nodes = @page_html.css("table")
    node = nodes[4].css("table")[3]

    img_link = "http://www.bestory.com" + node.css("img")[1][:src]
    name = node.css("font")[0].text
    is_serializing = true
    is_serializing = false if node.css("font")[0].next.text.index("全本")
    article_num = node.css("font")[1].text
    author = node.css("font")[3].text
    last_update = node.css("font")[4].text
    description = change_node_br_to_newline(node.css("table")[0].children.children[0].children.children.children[2].children.children[2]).strip

    novel.author = author
    novel.description = description
    novel.pic = img_link
    novel.is_serializing = is_serializing
    novel.article_num = article_num
    novel.last_update = last_update
    novel.name = name
    novel.crawl_times = novel.crawl_times + 1
    novel.save
  end

  def crawl_cat_rank category_id
    nodes = @page_html.css("table")
    this_week_nodes = nodes[5].children[1].children[2].children[1].children
    
    this_week_nodes.each do |node|
      link = "http://www.bestory.com" + node.css("a")[0][:href] if node.css("a")[0]
      puts link
      if (link && novel = Novel.find_by_link(link))
        novel.is_category_this_week_hot = true 
        novel.save
        puts "tes"
      end
    end

    hot_nodes = @page_html.xpath("//td[@bgcolor='#29ABCE']")[0].parent.parent.parent.parent.parent.children[1].children[2].children[1].children
    hot_nodes.each do |node|
      link = "http://www.bestory.com" + node.css("a")[0][:href] if node.css("a")[0]
      puts link
      if (link && novel = Novel.find_by_link(link))
        novel.is_category_hot = true 
        novel.save
        puts "tes"
      end
    end

    recommend_nodes = @page_html.xpath("//td[@bgcolor='#FFFFFF' and @colspan='2']")[0].children[3].children
    return if recommend_nodes.text.strip.blank?
    recommend_nodes.each do |node|
      novel_node = node.children[0]
      link = "http://www.bestory.com" + novel_node.css("a")[0][:href]
      puts link
      if (link && novel = Novel.find_by_link(link))
        novel.is_category_recommend = true 
        novel.save
        puts "tes"
      end
    end
  end

  def crawl_articles novel_id
    nodes = @page_html.css("a")
    nodes.each do |node|
      if (node[:href].index("/novel/") || node[:href].index("/view/"))
        article = Article.find_by_link("http://www.bestory.com" + node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = "http://www.bestory.com" + node[:href]
          article.title = node.text.strip
          article.subject = node.parent.parent.parent.parent.parent.previous.previous.previous.text.strip
          novel = Novel.select("id,num").find(novel_id)
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

  def crawl_article article
    nodes = @page_html.css(".content")
    nodes = nodes[0].children
    text = ""
    nodes.each do |node|
      next if node.text.nil?
      if node.text.index("bookview")
        node.css("script").remove
      end
      text = text + change_node_br_to_newline(node)
    end
    text = text.gsub("◎ 精品文學網 Bestory.com  ◎", "")
    text = text.gsub("※ 精 品 文 學 網 B e s t o r y  .c o m  ※", "")
    text = text.gsub("精品文學網  歡迎廣大書友光臨閱讀", "")
    text = text.gsub("手 機 用 戶 請 登 陸  隨 時 隨 地 看 小 說!","")
    article.text = text
    article.save
    puts "#{@page_url}  article_id : #{article.id}"
  end

  def crawl_rank
    nodes = @page_html.xpath("//font[@color='#0099CC']")
    ships = ["ThisWeekHotShip", "ThisMonthHotShip", "HotShip"]

    (0..2).each do |i|
      novel_nodes = nodes[i].parent.parent.parent.parent.css("a")
      novel_nodes.each do |node|
        ship = eval "#{ships[i]}.new"
        link = "http://www.bestory.com" + node[:href]
        novel = Novel.find_by_link link
        if novel
          ship.novel = novel
          ship.save
        end
      end
    end
  end

  def change_node_br_to_newline node
    content = node.to_html
    content = content.gsub("<br>","\n")
    n = Nokogiri::HTML(content)
    n.text
  end
end
