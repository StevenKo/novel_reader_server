# encoding: utf-8
class NovelCrawler
  include Crawler

  def parse_old_db_novel
    j_array = JSON.parse @page_html
    j_array.each do |json|
      novel = Novel.new
      novel.id = json["id"]
      novel.link = json["link"]
      novel.is_classic_action = json["is_classic_action"]
      novel.is_classic = json["is_classic"]
      novel.save
    end
  end

  def parse_old_db_article
    j_array = JSON.parse @page_html
    j_array.each do |json|
      article = Article.new
      
      article.id = json["id"]
      article.link = json["link"]
      article.novel_id = json["novel_id"]
      article.title = json["title"]
      article.subject = json["subject"]
      
      novel = Novel.select("id,num").find(json["novel_id"])
      article.num = novel.num + 1
      novel.num = novel.num + 1
      novel.save
      article.save
    end
  end

  def parse_old_db_article_detail article_id
    json = JSON.parse @page_html
    article = Article.find(article_id)
    article.text = json["text"]
    article.save
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
            novel.is_show = false
            novel.save
          end
          # CrawlWorker.perform_async(novel.id)
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
    return if novel.name

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
      name = node.css("a").text.split("/")[0]
      puts name
      if (name && name.size > 6) 
        novel = Novel.where(["name like ?", "%#{name[0..6]}%"])[0]
      else
        novel = Novel.find_by_name name
      end

      if novel
        novel.is_category_this_week_hot = true 
        novel.save
        puts "yes"
      end
    end

    hot_nodes = @page_html.xpath("//td[@bgcolor='#29ABCE']")[0].parent.parent.parent.parent.parent.children[1].children[2].children[1].children
    hot_nodes.each do |node|
      name = node.css("a").text.split("/")[0]
      puts name
      if (name && name.size > 6)
        novel = Novel.where(["name like ?", "%#{name[0..6]}%"])[0]
      else
        novel = Novel.find_by_name name
      end

      if novel
        novel.is_category_hot = true 
        novel.save
        puts "yes"
      end
    end

    recommend_nodes = @page_html.xpath("//td[@bgcolor='#FFFFFF' and @colspan='2']")[0].children[3].children
    recommend_nodes = recommend_nodes.css("a.blue")
    return if recommend_nodes.text.strip.blank?
    recommend_nodes.each do |node|
      name = node.text
      puts name
      if (name && name.size > 6)
        novel = Novel.where(["name like ?", "%#{name[0..6]}%"])[0]
      else
        novel = Novel.find_by_name name
      end

      if novel
        novel.is_category_recommend = true 
        novel.save
        puts "yes"
      end
    end
  end

  def crawl_articles novel_id

    if(@page_url.index('www.bestory.com'))
      nodes = @page_html.css("a")
      nodes.each do |node|
        if (node[:href].index("/novel/") || node[:href].index("/view/"))
          article = Article.find_by_link("http://www.bestory.com" + node[:href])
          # article = Article.where("novel_id = #{novel_id} and title = ?",node.text.strip)[0]
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
    elsif(@page_url.index('ck101.com'))
      novel = Novel.select("id,num,name").find(novel_id)
      last_node_url = @page_html.css(".pg a").last.previous[:href]
      /thread-(\d*)-(\d*)-\d*/ =~ last_node_url
      (0..$2.to_i).each do |page|
        if (page == 0)
          url = @page_url
        elsif (page == 1)
          url = "http://ck101.com/forum.php?mod=threadlazydata&tid=" + $1
        else
          url = "http://ck101.com/" + "thread-#{$1}-#{page}-2.html"
        end
        article = Article.find_by_link(url)
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url
          article.title = "#{page}"
          article.subject = novel.name
          article.num = novel.num + 1
          novel.num = novel.num + 1
          novel.save
          # puts node.text
          article.save
        end
        ArticleWorker.perform_async(article.id)
      end
    elsif(@page_url.index('gosky.net'))    
      url = @page_url.sub("index.html","")
      nodes = @page_html.css("table")[3].css("a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('quanshu.net'))    
      url = @page_url.sub("index.html","")
      nodes = @page_html.css(".chapterNum a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('fftxt.net'))    
      url = @page_url.sub("index.html","")
      nodes = @page_html.css("#chapterlist a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('xybook.net'))
      /(\d*_*\d*\.html)/ =~ @page_url   
      root_url = @page_url.sub($1,"")
      nodes = @page_html.css(".pagelist a")
      nodes.each do |node|
          next unless node[:href]
          article = nil
          if(node[:href] == "#")
            url = @page_url
          else
            url = root_url + node[:href]
          end
          article = Article.find_by_link(url)

          next if (article != nil && article.text != nil)
          next if (node.text == "上一页")
          unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = url
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
    elsif(@page_url.index('book.sto.cc'))
      nodes = @page_html.css("#webPage a")
      last_node = nodes.last
      /(\d*)-(\d*)/ =~ last_node[:href]
      (1..$2.to_i).each do |i|
        article = Article.find_by_link("http://book.sto.cc/" + $1 + "-" + i.to_s)
        next if (article != nil && article.text != nil)
        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = "http://book.sto.cc/" + $1 + "-" + i.to_s
          article.title = i.to_s
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
    elsif(@page_url.index('yqhhy.cc'))    
      url = @page_url.sub("index.html","")
      nodes = @page_html.css("#readtext a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif (@page_url.index('qizi.cc'))
      url = @page_url.sub("index.html","")
      @page_html.css(".ListRow a").last
      @page_html.css(".ListRow a").last
      nodes = @page_html.css(".ListRow a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url + node[:href]
          article.title = ZhConv.convert("zh-tw",node.text.strip)
          novel = Novel.select("id,num,name").find(novel_id)
          article.subject = novel.name
          /(\d*)/ =~ node[:href]
          article.num = $1.to_i
          # puts node.text
          article.save
        end
        ArticleWorker.perform_async(article.id)
      end      
    elsif(@page_url.index('xxsy.net'))    
      url = @page_url.sub("default.html","")
      nodes = @page_html.css("#catalog_list a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('yqwxc.com'))    
      url = "http://www.yqwxc.com"
      @page_html.css("ul")[0..1].remove
      @page_html.css("ul").last.remove
      nodes = @page_html.css("ul a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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

    elsif(@page_url.index('77wx'))
      nodes = @page_html.css(".box_con #list dl dd a")
      nodes.each do |node|
        article = Article.find_by_link(node[:href])
        next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('wsxs.net'))
      nodes = @page_html.css(".acss tr a")
      nodes.each do |node|
        article = Article.find_by_link(node[:href])
        next if (article != nil && article.text != nil && article.text.length > 100)

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
    elsif(@page_url.index('ttshuo'))
      nodes = @page_html.css(".ChapterList_Item a")
      nodes.each do |node|
        article = Article.find_by_link("http://www.ttshuo.com" + node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = "http://www.ttshuo.com" + node[:href]
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
    elsif(@page_url.index('feiku.com'))
      nodes = @page_html.css(".clearfix ul li[itemprop='itemListElement'] a")
      nodes.each do |node|
        article = Article.find_by_link(node[:href])
        next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('xiaoshuozhe.com'))
      nodes = @page_html.css(".list dl").children
      novel = Novel.select("id,num,name").find(novel_id)
      subject = novel.name

      nodes.each do |node|
        if (node.name == "dt")
          subject = node.text
        elsif node.name == "dd"
          node = node.css("a")[0]
          url = @page_url + node[:href]
          article = Article.find_by_link(url)
          next if (article != nil && article.text != nil && article.text.length > 150)

          unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = url
            article.title = ZhConv.convert("zh-tw",node.text.strip)
            article.subject = ZhConv.convert("zh-tw",subject)
            article.num = novel.num + 1
            novel.num = novel.num + 1
            novel.save
            # puts node.text
            article.save
          end
          ArticleWorker.perform_async(article.id)
        end
      end
    elsif(@page_url.index('5800.cc'))
      nodes = @page_html.css(".TabCss a")
      nodes.each do |node|
        article = Article.find_by_link(@page_url+ node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = @page_url+ node[:href]
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
    elsif(@page_url.index('kanunu.org'))
      nodes = @page_html.xpath("//tr[@bgcolor='#ffffff']//a")
      nodes.each do |node|
        /\/(\d*\.html)/ =~ @page_url
        url = @page_url
        url = @page_url.gsub($1,"") if $1
        article = Article.find_by_link(url+ node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url+ node[:href]
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
    elsif(@page_url.index('tw.hjwzw'))
      nodes = @page_html.css("#tbchapterlist tr a")
      nodes.each do |node|
        article = Article.find_by_link("http://tw.hjwzw.com" + node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = "http://tw.hjwzw.com" + node[:href]
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
    elsif(@page_url.index('shumilou'))
      nodes = @page_html.css(".zl a")
      nodes.each do |node|
        article = Article.find_by_link(node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = node[:href]
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
    elsif(@page_url.index('xuanhutang'))
      nodes = @page_html.css(".acss tr a")
      nodes.each do |node|
        article = Article.find_by_link(@page_url + node[:href])
        next if (article != nil && article.text != nil && article.text.length > 250)

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
        ArticleWorker.perform_async(article.id)
      end
    elsif(@page_url.index('jianxia.cc'))
      nodes = @page_html.css(".xsyd_ml_2 a")
      nodes.each do |node|
        article = Article.find_by_link(node[:href])
        next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('readnovel'))
      nodes = @page_html.css(".listPanel li a")
      nodes.each do |node|
        article = Article.find_by_link(node[:href])
        next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('quanben'))
      nodes = @page_html.css("tr")
      novel = Novel.select("id,num,name").find(novel_id)
      subject = ""
      nodes.each do |node|
        if (node.children.size() == 1)
          subject = ZhConv.convert("zh-tw",node.children.text.strip)
        elsif (node.children.size() == 4)
          inside_nodes = node.children.children
          inside_nodes.each do |n|
            if n.name == "a"
              article = Article.find_by_link(@page_url + n[:href])
              next if (article != nil && article.text != nil)

              unless article 
              article = Article.new
              article.novel_id = novel_id
              article.link = @page_url + n[:href]
              article.title = ZhConv.convert("zh-tw",n.text.strip)
              article.subject = subject
              /(\d*)/ =~ n[:href]
              article.num = $1.to_i
              # puts node.text
              article.save
              end
              novel.num = article.num + 1
              novel.save
              ArticleWorker.perform_async(article.id)
            end
          end
        end
      end
    elsif(@page_url.index('d586.com'))
      nodes = @page_html.css(".xiaoshou_list ul a")
      novel = Novel.select("id,num,name").find(novel_id)
      subject = novel.name
      nodes.each do |node|
        article = Article.find_by_link("http://www.d586.com" + node[:href])
        next if (article != nil && article.text != nil && article.text.length > 100)

        unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = "http://www.d586.com" + node[:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip)
        article.subject = subject
        /\/(\d+)\// =~ node[:href]
        next if $1.nil?
        article.num = $1.to_i
        # puts node.text
        article.save
        end
        # novel.num = article.num + 1
        # novel.save
        ArticleWorker.perform_async(article.id)
      end

      # nodes = @page_html.css(".acss tr .ccss a")
      # novel = Novel.select("id,num,name").find(novel_id)
      # nodes.each do |node|
      #   article = Article.find_by_link(@page_url + node[:href])
      #   next if (article != nil && article.text != nil)

      #   unless article 
      #     article = Article.new
      #     article.novel_id = novel_id
      #     article.link = @page_url + node[:href]
      #     article.title = ZhConv.convert("zh-tw",node.text.strip)
      #     article.subject = novel.name
      #     /(\d*)/ =~ node[:href]
      #     article.num = $1.to_i
      #     # puts node.text
      #     article.save
      #   end
      #   novel.num = article.num + 1
      #   novel.save
      #   ArticleWorker.perform_async(article.id)
      # end
    elsif(@page_url.index('shu88.net'))
      url = @page_url.gsub("index.html","")
      nodes = @page_html.css('ol li')
      nodes.each do |node|
        article = Article.find_by_link(url+node.child[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url + node.child[:href]
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
    elsif(@page_url.index('dawenxue'))
      url = @page_url.gsub("index.html","")
      nodes = @page_html.css(".ccss a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('ranhen'))
      nodes = @page_html.css("dd a")
      nodes.each do |node|
        article = Article.find_by_link(@page_url + node[:href])
        next if (article != nil && article.text != nil)

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
        ArticleWorker.perform_async(article.id)
      end  
    elsif(@page_url.index('book.sfacg'))
      @page_html.css("div.list_menu_title .Download_box").remove
      @page_html.css("div.list_menu_title a").remove
      subjects = @page_html.css("div.list_menu_title")
      subject_titles = []

      subjects.each do |subject|
        text = subject.text
        text = text.gsub("【】","")
        text = text.gsub("下载本卷","")
        subject_titles << ZhConv.convert("zh-tw",text.strip)
      end

      num = @page_html.css(".list_Content").size()
      index = 0
      while index < num do
        nodes = @page_html.css(".list_Content")[index].css("a")
        nodes.each do |node|
            article = Article.find_by_link("http://book.sfacg.com" + node[:href])
            if (article != nil)
              article.subject = subject_titles[index]
              article.save
            end
            next if (article != nil && article.text != nil && article.text.size > 100)

            unless article 
              article = Article.new
              article.novel_id = novel_id
              article.link = "http://book.sfacg.com" + node[:href]
              article.title = ZhConv.convert("zh-tw",node.text.strip)
              novel = Novel.select("id,num,name").find(novel_id)
              article.subject = subject_titles[index]
              article.num = novel.num + 1
              novel.num = novel.num + 1
              novel.save
                # puts node.text
              article.save
            end
            ArticleWorker.perform_async(article.id)
          end
        index = index +1        
      end
    elsif(@page_url.index('daomubiji'))

      subject = ""
      nodes = @page_html.css(".bg .mulu")
      nodes.each do |node|

        child_nodes = node.css("td")
        child_nodes.each_with_index do |c_node,i|
          if i==0
            subject = ZhConv.convert("zh-tw",c_node.text.strip)
          else
            a_node = c_node.css("a")[0]
            next if a_node.nil?
            article = Article.find_by_link(a_node[:href])
            next if (article != nil && article.text != nil)
            unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = a_node[:href]
            article.title = ZhConv.convert("zh-tw",a_node.text.strip)
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
      end
    elsif(@page_url.index('wenku8.cn'))
      subject = ""
      nodes = @page_html.css(".acss tr td")
      url = @page_url.gsub("index.htm","")
      nodes.each do |node|
        if node[:class] == "vcss"
          subject = ZhConv.convert("zh-tw",node.text.strip)
        else
          a_node = node.css("a")[0]
          next if a_node.nil?
          article = Article.find_by_link(url + a_node[:href])
          next if (article != nil && article.text != nil && article.text.length > 100)
          unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url + a_node[:href]
          article.title = ZhConv.convert("zh-tw",a_node.text.strip)
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
    elsif(@page_url.index('daomuxsw'))
      subject = ""
      nodes = @page_html.css(".mainbody td")
      url = @page_url.gsub("index.html","")
      nodes.each do |node|
        if node[:class] == "vcss"
          subject = ZhConv.convert("zh-tw",node.text.strip)
        else
          a_nodes = node.css("a")
          a_nodes.each do |a_node|
            next if a_node.nil?
            article = Article.find_by_link(url + a_node[:href])
            next if (article != nil && article.text != nil && article.text.length > 100)
            unless article 
              article = Article.new
              article.novel_id = novel_id
              article.link = url + a_node[:href]
              article.title = ZhConv.convert("zh-tw",a_node.text.strip)
              novel = Novel.select("id,num,name").find(novel_id)
              article.subject = subject
              /(\d*)\.html/ =~ a_node[:href]
              next unless $1
              article.num = $1.to_i
              novel.num = novel.num + 1
              novel.save
              # puts node.text
              article.save
            end
            ArticleWorker.perform_async(article.id)
          end  
        end
      end
    elsif(@page_url.index('xianjie'))
      url = @page_url.gsub("index.html","")

      subject = ""
      nodes = @page_html.css(".zhangjie dl").children
      nodes.each do |node|
        if node.name == "dt"
          subject = ZhConv.convert("zh-tw",node.text.strip)
        elsif (node.name == "dd" && node.children.size() == 1 && node.children[0][:href] != nil)
          article = Article.find_by_link(url + node.children[0][:href])
          next if (article != nil && article.text != nil)

          unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url + node.children[0][:href]
          article.title = ZhConv.convert("zh-tw",node.text.strip)
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
    elsif(@page_url.index('hfxs'))
      url = @page_url.gsub("index.html","")

      subject = ""
      nodes = @page_html.css("div.List").children
      nodes.each do |node|
        if node.name == "dt"
          subject = ZhConv.convert("zh-tw",node.text.strip)
        elsif (node.name == "dd" && node.children.size() == 1 && node.children[0][:href] != nil)
          article = Article.find_by_link(url + node.children[0][:href])
          next if (article != nil && article.text != nil)

          unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url + node.children[0][:href]
          article.title = ZhConv.convert("zh-tw",node.text.strip)
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
    elsif(@page_url.index('siluke'))
      url = @page_url

      subject = ""
      nodes = @page_html.css("#list dl").children
      nodes.each do |node|
        if node.name == "dt"
          subject = ZhConv.convert("zh-tw",node.text.strip)
        elsif (node.name == "dd" && node.css("a").present?)
          article = Article.find_by_link(url + node.children[0][:href])
          next if (article != nil && article.text != nil)

          unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url + node.children[0][:href]
          article.title = ZhConv.convert("zh-tw",node.text.strip)
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
    elsif(@page_url.index('5ccc.net'))
      url = page_url.gsub('index.html','')
      nodes = @page_html.css(".ccss a")
      nodes.each do |node|
        article = Article.find_by_link(url+node[:href])
        next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('tw.mingzw'))
      nodes = @page_html.css(".chapterlist a")
      nodes.each do |node|
        article = Article.find_by_link("http://tw.mingzw.com/" + node[:href])
        next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('xxs8.com'))
      nodes = @page_html.css(".bookdetail a")
      nodes.each do |node|
        article = Article.find_by_link(node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = node[:href]
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
    elsif(@page_url.index('520xs'))
      nodes = @page_html.css("#list dl").children
      subject = ""
      nodes.each do |node|
        
        if node[:id] == "qw"
          subject = node.text
          puts subject
        elsif node.css("a")[0]
          node = node.css("a")[0]
          article = Article.find_by_link("http://www.520xs.com" + node[:href])
          next if (article != nil && article.text != nil)

          unless article
            article = Article.new
            article.novel_id = novel_id
            article.link = "http://www.520xs.com" + node[:href]
            article.title = ZhConv.convert("zh-tw",node.text.strip)
            novel = Novel.select("id,num,name").find(novel_id)
            if(subject == "")
              subject = novel.name
            end
            article.subject = ZhConv.convert("zh-tw",subject)
            /(\d*)\/\z/ =~ node[:href]
            article.num = $1.to_i
            # puts node.text
            article.save
          end
          ArticleWorker.perform_async(article.id)
        end
      end
    elsif(@page_url.index('tw.xiaoshuokan'))
      nodes = @page_html.css(".booklist a")
      nodes.each do |node|
        article = Article.find_by_link("http://tw.xiaoshuokan.com" + node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = "http://tw.xiaoshuokan.com" + node[:href]
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
    elsif(@page_url.index('uuxs.com'))
      #this load pic by ajax, so cannot crawl pic
      nodes = @page_html.css(".booklist a")
      nodes.each do |node|
        article = Article.find_by_link(@page_url + node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = @page_url + node[:href]
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
    elsif(@page_url.index('92txt.net'))
      nodes = @page_html.css(".ccss a")
      nodes.each do |node|
        article = Article.find_by_link(@page_url + node[:href])
        next if (article != nil && article.text != nil)

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
        ArticleWorker.perform_async(article.id)
      end
    elsif(@page_url.index('ranwenxiaoshuo'))
      url = "http://www.ranwenxiaoshuo.com"
      nodes = @page_html.css("div.uclist dd a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil && article.text.size > 100)

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
    elsif(@page_url.index('ranwen.net'))
      url = @page_url.gsub("index.html","")
      nodes = @page_html.css("div#defaulthtml4 a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil && article.text.size > 100)

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
    elsif(@page_url.index('shanwen'))
      url = @page_url.gsub("index.html","")
      nodes = @page_html.css("div.bookdetail a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('qbxiaoshuo.com'))
      url = "http://www.qbxiaoshuo.com"
      nodes = @page_html.css(".booklist a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('xhxsw.com'))
      url = @page_url.sub("reader.htm","")
      nodes = @page_html.css("td.ccss a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('bsxsw'))
      url = "http://www.bsxsw.com"
      nodes = @page_html.css(".chapterlist a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('du7.com'))
      nodes = @page_html.css(".uclist a")
      nodes.each do |node|
        article = Article.find_by_link(@page_url + node[:href])
        next if (article != nil && article.text != nil)

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
        ArticleWorker.perform_async(article.id)
      end
    elsif(@page_url.index('lwxs'))
      url = @page_url
      nodes = @page_html.css("div#defaulthtml4 td a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('yawen8'))
      url = @page_url
      nodes = @page_html.css(".bookUpdate a")
      nodes.each do |node|
        if (node.text.index("yawen8") ==nil)
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil && article.text.length > 100)

          unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = url + node[:href]
            title = node.text.strip
            title = title.gsub("www.yawen8.com","")
            title = title.gsub("雅文言情小说","")
            title = title.gsub("()","")
            article.title = ZhConv.convert("zh-tw",title)
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
    elsif(@page_url.index('rijigu'))
      url = "http://www.rijigu.com"
      nodes = @page_html.css("a.J_chapter")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('duyidu'))
      url = "http://www.duyidu.com"
      nodes = @page_html.css("a.listA")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('kxwxw'))
      url = "http://tw.kxwxw.com/"
      nodes = @page_html.css("div.chdb li a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('dzxsw'))
      url = "http://www.dzxsw.net"
      subject = ""
      nodes = @page_html.css(".list").children
      nodes.each do |node|
        if node[:class] == "book"
          subject = ZhConv.convert("zh-tw",node.text.strip)
        elsif node[:class] == nil
          inside_nodes = node.css("a")
          inside_nodes.each do |in_node|
            article = Article.find_by_link(url + in_node[:href])
            next if (article != nil && article.text != nil)

            unless article 
              article = Article.new
              article.novel_id = novel_id
              article.link = url + in_node[:href]
              article.title = ZhConv.convert("zh-tw",in_node.text.strip)
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
      end
    elsif(@page_url.index('zwwx.com'))
      subject = ""
      nodes = @page_html.css(".book_article_texttable div")
      nodes.each do |node|
        if node[:class] == "book_article_texttitle"
          subject = ZhConv.convert("zh-tw",node.text.strip)
        else
          inside_nodes = node.css("a")
          inside_nodes.each do |in_node|
            article = Article.find_by_link(in_node[:href])
            next if (article != nil && article.text != nil && article.text.length > 100)

            unless article 
              article = Article.new
              article.novel_id = novel_id
              article.link = in_node[:href]
              article.title = ZhConv.convert("zh-tw",in_node.text.strip)
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
      end
    elsif(@page_url.index('xs8.cn'))
      url = ""
      nodes = @page_html.css("div.mod_container a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('5200xs'))
      url = @page_url.sub("index.html","")
      nodes = @page_html.css("div.chapter a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('sj131'))
      url = @page_url.sub("index.html","")
      # @page_html.css("div.dirbox dd a").last.remove
      nodes = @page_html.css("ol li a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil && article.text.length > 150)

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
    elsif(@page_url.index('23hh'))
      url = @page_url
      nodes = @page_html.css("td a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('qizi.cc'))
      nodes = @page_html.css(".ListRow")
      nodes = nodes[0..nodes.size-2]
      nodes = nodes.css("a")
      nodes.each do |node|
          article = Article.find_by_link(@page_url + node[:href])
          next if (article != nil && article.text != nil)

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
          ArticleWorker.perform_async(article.id)
      end
    elsif(@page_url.index('bjxiaoshuo'))
      url = "http://www.bjxiaoshuo.com"
      nodes = @page_html.css("li a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('fxnzw'))
      url = "http://tw.fxnzw.com/"
      @page_html.css("#BookText ul li").last.remove
      @page_html.css("#BookText ul li").last.remove
      @page_html.css("#BookText ul li").last.remove
      nodes = @page_html.css("#BookText ul li a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('my285'))
      url = @page_url
      @page_html.css("div tr td a").first.remove
      @page_html.css("div tr td a").first.remove
      @page_html.css("div tr td a").last.remove
      @page_html.css("div tr td a").last.remove
      nodes = @page_html.css("div tr td a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('57book'))
      url = "http://tw.57book.net/"
      @page_html.css(".footer").remove
      nodes = @page_html.css(".booklist span a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('zhsxs'))
      url = "http://tw.zhsxs.com"
      nodes = @page_html.css("td.chapterlist a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('jinbang'))
      url = @page_url
      @page_html.css(".novel_list li a")[0..8].remove
      nodes = @page_html.css(".novel_list li a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('orion34g'))
      url = @page_url
      nodes = @page_html.css(".novel_list a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('d5wx'))
      url = @page_url
      nodes = @page_html.css("tr.ccss a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

          unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = url + node[:href]
            article.title = ZhConv.convert("zh-tw",node.text.strip)
            novel = Novel.select("id,num,name").find(novel_id)
            article.subject = novel.name
            s = node[:href]
            /(\d*)\.shtml/ =~ s
            article.num = $1.to_i
            # puts node.text
            article.save
          end
          ArticleWorker.perform_async(article.id)
      end
    elsif(@page_url.index('dz320'))
      url = ""
      nodes = @page_html.css("div.mulu a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('qbxs8'))
      url = @page_url.sub("index.shtml","")
      nodes = @page_html.css("ul li a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('yjwxw'))
      url = @page_url
      @page_html.css("td.ccss a")[0..30].remove
      nodes = @page_html.css("td.ccss a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('shunong'))    
      url = @page_url.sub("index.html","")
      nodes = @page_html.css(".booklist a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif (@page_url.index('zizaidu'))
      url = @page_url.sub("index.html","")
      nodes = @page_html.css("div.uclist a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url + node[:href]
          article.title = ZhConv.convert("zh-tw",node.text.strip)
          novel = Novel.select("id,num,name").find(novel_id)
          article.subject = novel.name
          /(\d*)/ =~ node[:href]
          article.num = $1.to_i
          # puts node.text
          article.save
        end
        ArticleWorker.perform_async(article.id)
      end
    elsif (@page_url.index('zwxiaoshuo.com'))
      url = @page_url
      nodes = @page_html.css(".insert_list li a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url + node[:href]
          article.title = ZhConv.convert("zh-tw",node.text.strip)
          novel = Novel.select("id,num,name").find(novel_id)
          article.subject = novel.name
          /(\d*)/ =~ node[:href]
          article.num = $1.to_i
          # puts node.text
          article.save
        end
        ArticleWorker.perform_async(article.id)
      end
    elsif (@page_url.index('17k.com'))
      url = "http://mm.17k.com"
      nodes = @page_html.css(".con li a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil)

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
    elsif (@page_url.index('zuiyq'))
      url = @page_url.sub("index.html","")
      nodes = @page_html.css("div#htmlList a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url + node[:href]
          article.title = ZhConv.convert("zh-tw",node.text.strip)
          novel = Novel.select("id,num,name").find(novel_id)
          article.subject = novel.name
          /(\d*)/ =~ node[:href]
          article.num = $1.to_i
          # puts node.text
          article.save
        end
        ArticleWorker.perform_async(article.id)
      end
    elsif (@page_url.index('6yzw'))
      url = @page_url.sub("index.html","")
      nodes = @page_html.css(".ccss a")
      nodes.each do |node|
        article = Article.find_by_link(url + node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url + node[:href]
          article.title = ZhConv.convert("zh-tw",node.text.strip)
          novel = Novel.select("id,num,name").find(novel_id)
          article.subject = novel.name
          /(\d*)/ =~ node[:href]
          article.num = $1.to_i
          # puts node.text
          article.save
        end
        ArticleWorker.perform_async(article.id)
      end
    elsif (@page_url.index('.bookzx.ne'))
      nodes = @page_html.css("#tigtag_content4 ul li a")
      nodes.each do |node|
        article = Article.find_by_link(@page_url + node[:href])
        next if (article != nil && article.text != nil)

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
          article.save
        end
        ArticleWorker.perform_async(article.id)
      end
    elsif (@page_url.index('shushu.com.cn'))
      @page_html.css(".box").remove
      nodes = @page_html.css(".bord a")
      nodes.each do |node|
        article = Article.find_by_link("http://shushu.com.cn" + node[:href])
        next if (article != nil && article.text != nil)

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = "http://shushu.com.cn" + node[:href]
          article.title = ZhConv.convert("zh-tw",node.text.strip)
          novel = Novel.select("id,num,name").find(novel_id)
          article.subject = novel.name
          article.num = novel.num + 1
          novel.num = novel.num + 1
          novel.save
          article.save
        end
        ArticleWorker.perform_async(article.id)
      end
    elsif(@page_url.index('luoqiu.com'))

      novel = Novel.select("id,num,name").find(novel_id)
      subject = novel.name
      nodes = @page_html.css(".booklist span")
      nodes.each do |node|
        if(node[:class]=="v")
          subject = ZhConv.convert("zh-tw",node.text.strip.gsub(".",""))
        else
          a_node = node.css("a")[0]
          url = @page_url.gsub("index.html","") + a_node[:href]
          article = Article.find_by_link(url)
          next if (article != nil && article.text != nil && article.text.length > 100)
          unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = url
            article.title = ZhConv.convert("zh-tw",a_node.text.strip) 
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
    elsif(@page_url.index('big5.zongheng'))
      novel = Novel.select("id,num,name").find(novel_id)
      subject = novel.name
      subject_nodes = @page_html.css(".chapter h2")
      nodes = @page_html.css(".chapter .booklist")
      nodes.each_with_index do |node,i|
        subject = ZhConv.convert("zh-tw",subject_nodes[i].text.strip)
        a_nodes = node.css("a")
        a_nodes.each do |a_node|
          url = a_node[:href]
          article = Article.find_by_link(url)
          next if (article != nil && article.text != nil && article.text.length > 100)
          unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = url
            article.title = ZhConv.convert("zh-tw",a_node.text.strip) 
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
    elsif(@page_url.index('59to.org'))
      url = "http://tw.59to.org"
      @page_html.css(".booklist a").last.remove
      @page_html.css(".booklist a").last.remove
      @page_html.css(".booklist a").last.remove
      @page_html.css(".booklist a").last.remove
      @page_html.css(".booklist a").last.remove
      nodes = @page_html.css(".booklist a")
      nodes.each do |node|
          article = Article.find_by_link(url + node[:href])
          next if (article != nil && article.text != nil)

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
    elsif(@page_url.index('59to.com'))
      url = @page_url

      subject = ""
      nodes = @page_html.css(".acss").children
      nodes.each do |node|
        if node.children.children[0].name == "h2"
          subject = ZhConv.convert("zh-tw",node.children.text.strip)
        elsif (node.children.children[0].name == "a")
          inside_nodes = node.children.children
          inside_nodes.each do |n|
            if n[:href] != nil
              article = Article.find_by_link(url + n[:href])
              next if (article != nil && article.text != nil)

              unless article 
              article = Article.new
              article.novel_id = novel_id
              article.link = url + n[:href]
              article.title = ZhConv.convert("zh-tw",n.text.strip)
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
        end
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
    text = text.gsub("精品文學 iPhone App現已推出！支持離線下載看小說，請使用iPhone下載安裝！","")
    article.text = text
    article.save
    puts "#{@page_url}  article_id : #{article.id}"
  end

  def crawl_text_onther_site article
    if(@page_url.index("yantengzw"))
      nodes = @page_html.css("#htmlContent")
      text  = change_node_br_to_newline(nodes)
      article_text = ZhConv.convert("zh-tw", text)
      article.text = article_text
      article.save
    elsif(@page_url.index("book.qq"))
      nodes = @page_html.css("#content")
      text  = change_node_br_to_newline(nodes)
      article_text = ZhConv.convert("zh-tw", text)
      article.text = article_text
      article.save
    elsif(@page_url.index("www.zizaidu.com/big5"))
      nodes = @page_html.css("#content")
      text  = change_node_br_to_newline(nodes).strip
      article_text = text.gsub("（最好的全文字小說網︰自在讀小說網 www.zizaidu.com）","")
      article.text = article_text
      article.save
    elsif (@page_url.index("www.4hw.com.cn"))
      @page_html.css(".art_cont .art_ad,.art_cont .fenye, .art_cont .tishi").remove
      article_text = ZhConv.convert("zh-tw",@page_html.css(".art_cont").text.strip)
      article.text = article_text
      article.save
    elsif (@page_url.index("read.shanwen.com"))
      @page_html.css("#content")
      @page_html.css("#content center").remove
      text = ZhConv.convert("zh-tw",@page_html.css("#content").text.strip)
      if text.length < 100
        imgs = @page_html.css(".divimage img")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版"
        article.text = text_img
      else
        article.text = ZhConv.convert("zh-tw", text)
      end
      article.save
    elsif (@page_url.index("shushu.com.cn"))
      @page_html.css("#content script,#content a").remove
      article_text = ZhConv.convert("zh-tw",@page_html.css("#content").text.strip)
      article.text = article_text
      if article.text.length < 150
        imgs = @page_html.css(".divimage img")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版APP"
        article.text = text_img
      end
      article.save
    elsif (@page_url.index("tw.9pwx.com"))
      @page_html.css(".bookcontent #msg-bottom").remove
      text = @page_html.css(".bookcontent").text.strip
      if text.length < 100
        begin
          url = "http://tw.9pwx.com"
          text = @page_html.css(".divimage img")[0][:src]
          article.text = url + text + "*&&$$*" + "如果看不到圖片, 請更新至新版"  
        rescue Exception => e      
        end
      else
        article_text = text.gsub("鑾勾絏ュ庤鎷誨潒濯兼煉鐪磭榪惰琚氣-官家求魔殺神武動乾坤最終進化神印王座| www.9pwx.com","")
        article_text = text.gsub("鍗兼雞銇264264-官家求魔殺神武動乾坤最終進化神印王座|","")
        article_text = text.gsub("www.9pwx.com","")
        article.text = article_text.strip
      end     
      article.save
    elsif (@page_url.index('sj131'))
      if @page_html.css("#content").text != ""
        @page_html.css("#content a").remove
        article_text = ZhConv.convert("zh-tw",@page_html.css("#content").text.strip)
        article_text = article_text.gsub("如果您喜歡這個章節","")
        article_text = article_text.gsub("精品小說推薦","")
        article.text = article_text
        article.save
      elsif @page_html.css(".contentbox").text != ""
        @page_html.css(".contentbox a").remove
        article_text = ZhConv.convert("zh-tw",@page_html.css(".contentbox").text.strip)
        article_text = article_text.gsub("如果您喜歡這個章節","")
        article_text = article_text.gsub("精品小說推薦","")
        article.text = article_text
        article.save
      else
        @page_html.css("#table_container a").remove
        @page_html.css("#table_container span").remove
        article_text = ZhConv.convert("zh-tw",@page_html.css("#table_container").text.strip)
        article_text = article_text.gsub("如果您喜歡這個章節","")
        article_text = article_text.gsub("精品小說推薦","")
        article.text = article_text
        article.save
      end
      if (article.text.length < 150 )
        imgs = @page_html.css("img.imagecontent")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版APP"
        article.text = text_img
        article.save
      end

    elsif (@page_url.index('yawen8'))
      article_text = ZhConv.convert("zh-tw",@page_html.css("div.txtc").text.strip)
      text2 = ""
      text3 = ""
      if article_text.index('本章未完')
        c = NovelCrawler.new
        c.fetch_other_site @page_url+"?p=2"
        text2 = ZhConv.convert("zh-tw",c.page_html.css("div.txtc").text.strip)
        if text2.index('本章未完')
          c = NovelCrawler.new
          c.fetch_other_site @page_url+"?p=3"
          text3 = ZhConv.convert("zh-tw",c.page_html.css("div.txtc").text.strip)
        end
      end
      article_text = article_text + text2 + text3
      article_text = article_text.gsub("［本章未完，請點擊下一頁繼續閱讀！］","")
      article_text = article_text.gsub("...   ","")
      article.text = article_text

      if (article.text.length < 150 )
        imgs = @page_html.css(".piccontent img")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版APP"
        article.text = text_img
        article.save
      end
      article.save
    elsif (@page_url.index('52buk.com'))
      text = @page_html.css(".novelcon").text.strip
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save
    elsif (@page_url.index('8535.org'))
      @page_html.css("#bookcontent #adtop, #bookcontent #endtips").remove
      text = @page_html.css("#bookcontent").text.strip
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save
    elsif (@page_url.index('59to.com'))
      @page_html.css("#content a").remove
      text = @page_html.css("#content").text
      article_text = text.gsub("*** 现在加入59文学，和万千书友交流阅读乐趣！59文学永久地址：www.59to.com ***", "")
      final_text = ZhConv.convert("zh-tw",article_text.strip)
      article.text = final_text
      article.save
    elsif (@page_url.index('59to.org'))
      @page_html.css(".bookcontent div").remove
      text = @page_html.css(".bookcontent").text.strip
      article_text  = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save  
    elsif (@page_url.index('www.k6uk.com'))
      text = @page_html.css("#content").text.strip
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save
    elsif (@page_url.index('www.dawenxue.net'))
      text = @page_html.css("#clickeye_content").text.strip
      text1 = text.gsub("大文学", "")
      text2 = text1.gsub("www.dawenxue.net", "")
      text2 = text2.gsub("()", "")
      text2 = text2.gsub("www.Sxiaoshuo.com", "")
      text2 = text2.gsub("最快的小说搜索网", "")
      text2 = text2.gsub("/////", "")    
      if text2.length < 100
        begin
          imgs = @page_html.css(".divimage img")
          text_img = ""
          imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
          end
          text_img = text_img + "如果看不到圖片, 請更新至新版"
          article.text = text_img
        rescue Exception => e      
        end
      else
        article_text = ZhConv.convert("zh-tw",text2)
        article.text = article_text
      end
      article.save
    elsif (@page_url.index('quanben'))
      text = @page_html.css("#content").text.strip
      text = text.gsub(/[a-zA-Z]/,"")
      text = text.gsub("全本小说网","")
      text = text.gsub("wWw!QuanBEn!CoM","")
      text = text.gsub("(www.quanben.com)","")
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save
    elsif (@page_url.index('wcxiaoshuo'))
      @page_html.css("#htmlContent a").remove
      @page_html.css("#htmlContent img").remove
      text = @page_html.css("#htmlContent").text.strip
      text = text.gsub("由【无*错】【小-说-网】会员手打，更多章节请到网址：www.wcxiaoshuo.com","")
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save
    elsif (@page_url.index('shumilou'))
      @page_html.css("#content span").remove
      @page_html.css("#content b").remove
      @page_html.css("#content .title").remove
      @page_html.css("#content script").remove
      text = @page_html.css("#content").text.strip
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save
    elsif (@page_url.index('dzxsw'))
      text = @page_html.css("#content").text
      text = text.gsub(/\/\d*/,"")
      text = text.gsub("'>","")
      text = text.gsub(".+?","")
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save
    elsif(@page_url.index('xianjie'))
      @page_html.css(".para script").remove
      text = @page_html.css(".para").text
      text = text.gsub("阅读最好的小说，就上仙界小说网www.xianjie.me","")
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save
    elsif (@page_url.index('u8xs'))
      text = change_node_br_to_newline(@page_html.css("#content"))
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save
    elsif (@page_url.index('ranhen.net'))
      text = @page_html.css("#content p").text
      text2 = text.gsub('小技巧：按 Ctrl+D 快速保存当前章节页面至浏览器收藏夹；按 回车[Enter]键 返回章节目录，按 ←键 回到上一章，按 →键 进入下一章。','')
      article_text = ZhConv.convert("zh-tw",text2)
      article.text = article_text
      article.save
    elsif (@page_url.index('6ycn.net'))
      @page_html.css("#content style, #content .pagesloop").remove
      text = @page_html.css("#content").text.strip
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save
    elsif (@page_url.index('book108.com'))
      @page_html.css("#content a").remove
      text = @page_html.css("#content p").text
      text2 = text.gsub("1０８尒説WWW.Book１０８。com鯁","")
      article_text = ZhConv.convert("zh-tw",text2)
      article.text = article_text
      article.save
    elsif (@page_url.index('77wx'))
      @page_html.css(".content a").remove
      text = @page_html.css(".content").text.strip
      text = text.gsub("七七文学","")
      text = text.gsub("九星天辰诀","")
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save
    elsif (@page_url.index('tw.hjwzw'))
      @page_html.css("#AllySite")[0].next.next
      @page_html.css("#AllySite")[0].next.next.css("a").remove
      @page_html.css("#AllySite")[0].next.next.css("b").remove
      text = @page_html.css("#AllySite")[0].next.next.text.strip
      text = text.gsub("返回書頁","")
      text = text.gsub("回車鍵","")
      text = text.gsub("快捷鍵: 上一章(\"←\"或者\"P\")","")
      text = text.gsub("下一章(\"→\"或者\"N\")","")
      text = text.gsub("在搜索引擎輸入","")
      text = text.gsub("就可以找到本書","")
      text = text.gsub("最快,最新TXT更新盡在書友天下:本文由“網”書友更新上傳我們的網址是“”如章節錯誤/舉報謝","")
      article.text = text
      article.save
    elsif (@page_url.index('xuanhutang'))
      @page_html.xpath("//div[@align='center']").remove
      @page_html.xpath("//div[@style='padding:6px 12px;line-height:20px;']").remove
      @page_html.css("#content a").remove
      text = @page_html.css("#content").text.strip
      text = text.gsub("看校园小说到-玄葫堂","")
      article_text = ZhConv.convert("zh-tw",text)

      if (article_text.length < 250)
        imgs = @page_html.css(".divimage img")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版APP"
        article_text = text_img
      end
      article.text = article_text
      article.save
    elsif (@page_url.index('shu88.net'))
      text = @page_html.css(".contentbox").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('sfacg'))
      node = @page_html.css("#ChapterBody")
      text = change_node_br_to_newline(node)
      if text.length < 50
        url = "http://book.sfacg.com"
        imgs = @page_html.css("#ChapterBody img")
        text_img = ""
        imgs.each do |img|
          if img[:src].index("sfacg.com")
            text_img = text_img + img[:src] + "*&&$$*"
          else
            text_img = text_img + url + img[:src] + "*&&$$*"
          end
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版"
        article.text = text_img
      else
        article.text = ZhConv.convert("zh-tw", text)
      end
      article.save
    elsif (@page_url.index('5ccc.net'))
      @page_html.css("#content a").remove
      @page_html.css("#content script").remove
      node = @page_html.css("#content")
      text = node.text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('tw.mingzw'))
      @page_html.css("div[@style='text-align: center']").remove
      @page_html.css("div[@style='border: 1px solid #a6a6a6; width: 850px; margin: 0 auto;'] script").remove
      node = @page_html.css("div[@style='border: 1px solid #a6a6a6; width: 850px; margin: 0 auto;']")
      text = node.text.strip
      text = text.gsub("如需請通過此鏈接進入沖囍下載頁面","")
      text = text.gsub("明智屋中文","")
      text = text.gsub("wWw.MinGzw.cOm","")
      text = text.gsub("沒有彈窗","")
      text = text.gsub("更新及時","")
      article.text = text
      article.save
    elsif (@page_url.index('520xs'))
      @page_html.css("#TXT a").remove
      node = @page_html.css("#TXT")
      text = change_node_br_to_newline(node).strip
      text = text.gsub("最新章节","")
      text = text.gsub("TXT下载","")
      text = text.gsub("520小说提供无弹窗全文字在线阅读，更新速度更快文章质量更好，如果您觉得520小说网不错就多多分享本站!谢谢各位读者的支持!","")
      text = text.gsub("520小说高速首发","")
      text = text.gsub(/本章节是.*地址为/,"")
      text = text.gsub("如果你觉的本章节还不错的话请不要忘记向您QQ群和微博里的朋友推荐哦！","")
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('tw.xiaoshuokan'))
      node = @page_html.css(".bookcontent")
      text = change_node_br_to_newline(node).strip
      text = text.gsub(/&(.*)WWW.3Zcn.net/,"")
      text = text.gsub(/&(.*)WWW.3Zcn.net/,"")
      text = text.gsub("三藏中文","")
      text = text.gsub("bsp","")
      text = text.gsub("Www.Xiaoshuokan.com","")
      text = text.gsub("好看小說網","")
      text = text.gsub("(本章免費)","")
      text = text.gsub("&n8","")
      text = text.gsub("ｏ","")
      text = text.gsub("&nWww.xiaoｓhuoｋａn.Com","")
      text = text.gsub("WWW.ｘｉａｏｓｈｕｏｋａｎ.ｃｏｍ","")
      article.text = text
      article.save
    elsif (@page_url.index('92txt.net'))
      node = @page_html.css("#chapter_content")
      text = change_node_br_to_newline(node)
      text = text.gsub("www.92txt.net 就爱网","")
      text = text.gsub("亲们记得多给戚惜【投推荐票】、【投月票】，【加入书架】，【留言评论】哦，鞠躬敬谢","")
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('guli.cc'))
      text = @page_html.css("div#content").text.strip
      text = text.gsub("txtrightshow();","").strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('ranwenxiaoshuo'))
      # the site may change content web element, use carefully
      # sometimes can't reach content by sidekiq
      text = @page_html.css("p").text.strip
      text = text.gsub("求金牌、求收藏、求推荐、求点击、求评论、求红包、求礼物，各种求，有什么要什么，都砸过来吧！","").strip
      text = text.gsub("小窍门：按左右键快速翻到上下章节","").strip
      article.text = ZhConv.convert("zh-tw", text)
      
      if text.length < 100
        imgs = @page_html.css("p img")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版APP"
        article.text = text_img
      end

      article.save
    elsif (@page_url.index('ranwen.net'))
      text = @page_html.css("div#content").text.strip
      if text.length < 50
        imgs = @page_html.css(".divimage img")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版"
        article.text = text_img
      else
        article.text = ZhConv.convert("zh-tw", text)
      end

      article.save
    elsif (@page_url.index('qbxiaoshuo'))
      text = @page_html.css(".bookcontent").text.strip
      text = text.gsub("[www.16Kbook.com]","")
      text = text.gsub("www.qbxiaoshuo.com全本小说网","")
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('xhxsw'))
      text = @page_html.css("#content").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('lwxs'))
      text = @page_html.css("div#content").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('rijigu'))
      text = @page_html.css("div#content").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('kxwxw'))
      text = @page_html.css("div.rdaa").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('qtxny'))
      text = @page_html.css("div#content").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('duyidu'))
      text = @page_html.css("div#content").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('shunong'))
      @page_html.css(".bookcontent div").remove
      @page_html.css(".bookcontent script").remove
      @page_html.css(".bookcontent a").remove
      text = @page_html.css(".bookcontent").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save  
    elsif (@page_url.index('xs8.cn'))
      text = @page_html.css("div.chapter_content").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('5200xs'))
      text = @page_html.css("div.novel_content").text.strip
      text = text.gsub("()","")
      text = text.gsub("【VIP】","")
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('hfxs'))
      @page_html.css("div.width script").remove
      text = @page_html.css("div.width").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('5800'))
      @page_html.css("#content a").remove
      text = @page_html.css("#content").text.strip
      text = text.gsub("*** 即刻参加58小说，和广大书友共享阅读乐趣！58小说永久地址：www.5800.cc ***","")
      article.text = ZhConv.convert("zh-tw", text)
      article.save  
    elsif (@page_url.index('23hh'))
      text = @page_html.css("#contents").text.strip
      if text.length < 100
        imgs = @page_html.css("#contents .divimage img")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版"
        article.text = text_img
      else
        text = text.gsub("http://","")
        article.text = ZhConv.convert("zh-tw", text)
      end
      article.save
    elsif (@page_url.index('readnovel'))
      text = @page_html.css(".mainContentNew").text.strip
      text = text.gsub("温馨提示：手机小说阅读网请访问m.xs.cn，随时随地看小说！公车、地铁、睡觉前、下班后想看就看。查看详情","")
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save    
    elsif (@page_url.index('fxnzw'))
      text = @page_html.css("div")[6].children[14].text.strip
      text = text.gsub("請記住:飛翔鳥中文小說網 www.fxnzw.com 沒有彈窗,更新及時 !","")
      text = text.gsub("()","")
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('kanunu'))
      text = @page_html.css("tr p").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('zhsxs'))
      text = @page_html.css("tr td div")[6].text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('bjxiaoshuo'))
      text = @page_html.css("#htmlContent").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save 
    elsif (@page_url.index('qiuwu'))
      text = @page_html.css("#content").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('6yzw'))
      text = @page_html.css("#readtext").text.strip
      if text.length < 100
        imgs = @page_html.css("#readtext .divimage img")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版"
        article.text = text_img
      else
        article.text = ZhConv.convert("zh-tw", text)
      end
      article.save
    elsif (@page_url.index('jinbang'))
      @page_html.css("a").remove
      text = @page_html.css("div.novel_content").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('guanhuaju'))
      text = @page_html.css("div#content_text").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save 
    elsif (@page_url.index('d5wx'))
      text = @page_html.css("td#contenthtzw").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('my285'))
      text = @page_html.css("tr")[4].text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('zwxiaoshuo.com'))
      @page_html.css(".contentbox div").remove
      text = @page_html.css(".contentbox").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save  
    elsif (@page_url.index('dz320'))
      @page_html.css("div.cmt").remove
      text = @page_html.css("div.content").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('yjwxw'))
      @page_html.css("#content div").remove
      text = @page_html.css("#content").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save  
    elsif (@page_url.index('zuiyq'))
      text = @page_html.css(".contentbox").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('orion34g'))
      @page_html.css(".novel_content div").remove
      text = @page_html.css(".novel_content").text.strip
      if text.length < 100
        begin
          text = @page_html.css(".divimage img")[0][:src]
          article.text = text + "*&&$$*" + "如果看不到圖片, 請更新至新版"
        rescue Exception => e      
        end
      else
        article.text = ZhConv.convert("zh-tw", text)
      end
      article.save  
    elsif (@page_url.index('qbxs8'))
      @page_html.css("div.text div").remove
      @page_html.css("div.text a").remove
      @page_html.css("div.text h1").remove
      @page_html.css("div.text h2").remove
      @page_html.css("div.text script").remove
      text = @page_html.css("div.text").text.strip
      text = text.gsub("*  * 女  生 小  说  网 - http://www.qbxs8.com - 好  看  的  女  生 小  说     ★★★★★薄情锦郁★★★★★ ","")
      article.text = ZhConv.convert("zh-tw", text)
      article.save                                   
    elsif (@page_url.index('57book'))
      @page_html.css("div#msg-bottom").remove
      text = @page_html.css("div.bookcontent").text.strip
      text = text.gsub("www.57book.net","")
      text = text.gsub("無極小說~~","")
      text = text.gsub("三藏小說免費小說手打網","")
      text = text.gsub("()","")
      article.text = ZhConv.convert("zh-tw", text)
      article.save                                    
    elsif (@page_url.index('bsxsw'))
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
      article.save
    elsif (@page_url.index('shushu5.com'))
      text = @page_html.css("#partbody").text
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('kushuku.com'))
      @page_html.css("span").remove
      node = @page_html.css("#content")
      text = change_node_br_to_newline(node)
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('d586.com'))
      node = @page_html.css(".content")
      node.css("a").remove
      node.css("script").remove
      text = change_node_br_to_newline(node)
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('bookzx.net'))
      node = @page_html.css("#tigtag_size")
      node.css("a").remove
      node.css("script").remove
      text = change_node_br_to_newline(node)
      article.text = ZhConv.convert("zh-tw", text.strip)

      if text.length < 100
        imgs = @page_html.css("#tigtag_size img")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版APP"
        article.text = text_img
      end
      article.save

    elsif (@page_url.index('feiku.com'))
      node = @page_html.css(".art_wrap.mt15")
      node.css("a").remove
      node.css("script").remove
      text = change_node_br_to_newline(node)
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('qizi.cc'))
      node = @page_html.css(".txt")
      node.css("a").remove
      node.css("script").remove
      text = change_node_br_to_newline(node)
      text = text.gsub("朋友..!","")
      text = text.gsub("www.qizi.cc","")
      text = text.gsub("棋子小说网","")
      text = text.gsub("据说时常阅读本站,可增加艳遇哦","")
      text = text.gsub("欢迎你","")
      text = text.gsub("最快更新","")
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('ttshuo'))
      node = @page_html.css(".detailcontent")
      node.css("a").remove
      node.css("script").remove
      text = change_node_br_to_newline(node)
      text = text.gsub("本作品来自天天小说网(www.ttshuo.com)","")
      text = text.gsub("大量精品小说","")
      text = text.gsub("永久免费阅读","")
      text = text.gsub("敬请收藏关注","")
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('daomubiji'))
      node = @page_html.css(".content")
      node.css("a").remove
      node.css(".shangxia").remove
      node.css(".cmt").remove
      node.css("script").remove
      node.css("span").remove
      text = node.text
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('wenku8.cn'))
      node = @page_html.css("#content")
      node.css("#contentdp").remove
      text = node.text
      article.text = ZhConv.convert("zh-tw", text.strip)
      if text.length < 100
        imgs = @page_html.css("#content .divimage img")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版APP"
        article.text = text_img
      end
      article.save
    elsif (@page_url.index('wsxs.net'))
      node = @page_html.css("#content")
      text = node.text
      text = text.gsub("☺文山小说网编辑整理，谢谢观赏！☺","")
      article.text = ZhConv.convert("zh-tw", text.strip)

      if text.length < 100
        imgs = @page_html.css("#content img")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版APP"
        article.text = text_img
      end
      article.save
    elsif(@page_url.index('jianxia.cc'))
      node = @page_html.css("#article p")[0]
      node.css("span").remove
      article.text = ZhConv.convert("zh-tw", node.text)
      article.save
    elsif (@page_url.index('gosky.net'))
      @page_html.css("#zw a").remove
      @page_html.css("#zw font").remove
      @page_html.css("#zw u").remove
      text = @page_html.css("#zw").text.strip
      text = text.gsub("wap.gosky.net", "")
      text = text.gsub("()", "")
      if text.length < 40
        text = @page_html.css("#c1c").text.strip
        text = text.gsub("wap.gosky.net", "")
        text = text.gsub("()", "")
      end
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save  
    elsif (@page_url.index('xxsy.net'))
      @page_html.css("#zjcontentdiv a").remove
      text = @page_html.css("#zjcontentdiv").text.strip
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save
    elsif (@page_url.index('qizi.cc'))
      @page_html.css(".txt font").remove
      @page_html.css(".txt a").remove
      @page_html.css(".txt div").remove
      text = @page_html.css(".txt").text.strip
      article_text = ZhConv.convert("zh-tw",text)
      article.text = article_text
      article.save
    elsif (@page_url.index('yqhhy.cc'))
      @page_html.css("#content a").remove
      @page_html.css("#content span").remove
      text = @page_html.css("#content").text.strip
      text = text.gsub("尽在言情后花园。","")
      text = text.gsub("www.yqhhy.cc","")
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('fftxt.net'))
      text = @page_html.css(".novel_content").text.strip
      text = text.gsub("_.book.addBookhistroy;","")
      text = text.gsub("_.book.shoBookshistory;","")
      text = text.gsub("您最近阅读过：","")
      text = text.gsub("17k火热连载阅读分享世界","")
      text = text.gsub("创作改变人生","")
      text = text.gsub("一秒记住【非凡TXT下载】www.fftxt.net，为您提供精彩小说阅读。","")
      article.text = ZhConv.convert("zh-tw", text)
      article.save  
    elsif (@page_url.index('yqwxc.com'))
      text = @page_html.css(".box").text.strip
      text = text.gsub("言情文学城","")
      text = text.gsub("WWW.YQWXC.COM","")
      text = text.gsub("免费看VIP全本小说","")
      article.text = ZhConv.convert("zh-tw", text)
      article.save
    elsif (@page_url.index('luoqiu.com'))
      node = @page_html.css("#content")
      text = node.text
      article.text = ZhConv.convert("zh-tw", text.strip)

      if text.length < 100
        imgs = @page_html.css("#content img")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版APP"
        article.text = text_img
      end
      article.save
    elsif (@page_url.index('jjwxc.net'))
      node = @page_html.css(".noveltext")
      node.css("a").remove
      node.css("font").remove
      node.css("span").remove
      node.css("script").remove
      text = change_node_br_to_newline(node).strip.gsub("[]","").gsub("  ","").gsub("\n\n","")
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('xybook.net'))
      node = @page_html.css(".article-article")
      node.css("a").remove
      text = node.text.strip
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('xiaoshuozhe'))
      node = @page_html.css("#BookText")
      node.css("#ad_right").remove
      node.css("font").remove
      text = node.text.strip
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('uuxs'))
      node = @page_html.css("#content")
      node.css("#adtop,#notify,script,.divimage,#endtips,.pageTools").remove
      text = node.text.strip
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('xxs8.com'))
      node = @page_html.css("#mmpage")
      text = node.text.strip
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif(@page_url.index('book.sto.cc'))
      node = @page_html.css("#BookContent")
      node.css("span,script").remove
      text = node.text.strip
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif(@page_url.index('daomuxsw'))
      node = @page_html.css("#content")
      text = node.text.strip
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif(@page_url.index('ck101.com'))
      node = @page_html.css(".t_f")
      text = node.text.strip
      article.text = text
      article.save
    elsif(@page_url.index('zwwx.com'))
      node = @page_html.css("#content")
      text = node.text.strip
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif(@page_url.index('du7.com'))
      node = @page_html.css(".text")
      text = change_node_br_to_newline(node).strip
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('17k.com'))
      node = @page_html.css("#chapterContent")
      node.css("script,a,.ct0416,.recent_read,#bdshare,.like_box").remove
      text = change_node_br_to_newline(node).strip
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('big5.zongheng'))
      node = @page_html.css("#chapterContent")
      node.css("span").remove
      text = change_node_br_to_newline(node).strip
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    elsif (@page_url.index('www.yunshuge'))
      node = @page_html.css("#content")
      text = change_node_br_to_newline(node).strip
      text = text.gsub("www.biquge.com ","")

      if text.length < 100
        imgs = @page_html.css("#imgview")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版APP"
        article.text = text_img
      end
      article.save
    elsif(@page_url.index('siluke'))
      node = @page_html.css("#content")
      node.css("script").remove
      text = change_node_br_to_newline(node).strip
      article.text = ZhConv.convert("zh-tw", text.strip)
      article.save
    end
  end

  def crawl_rank
    nodes = @page_html.xpath("//font[@color='#0099CC']")
    ships = ["ThisWeekHotShip", "ThisMonthHotShip", "HotShip"]

    (0..2).each do |i|
      novel_nodes = nodes[i].parent.parent.parent.parent.css("a")
      novel_nodes.each do |node|
        ship = eval "#{ships[i]}.new"
        # link = "http://www.bestory.com" + node[:href]
        # novel = Novel.find_by_link link
        name = node.text.split("/")[0]
        if name.size > 6
          novel = Novel.where(["name like ?", "%#{name[0..6]}%"])[0]
        else
          novel = Novel.find_by_name name
        end
        if novel
          ship.novel = novel
          ship.save
          puts name
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
