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
          novel.category_id = category_id
          novel.save
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
    elsif(@page_url.index('xuanhutang'))
      nodes = @page_html.css(".acss tr a")
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
    elsif(@page_url.index('quanben'))
      nodes = @page_html.css(".acss tr a")
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
      article_text = ZhConv.convert("zh-tw",@page_html.css("#content").text.strip)
      article.text = article_text
      article.save
    elsif (@page_url.index("shushu.com.cn"))
      @page_html.css("#content script,#content a").remove
      article_text = ZhConv.convert("zh-tw",@page_html.css("#content").text.strip)
      article.text = article_text
      article.save
    elsif (@page_url.index("tw.9pwx.com"))
      @page_html.css(".bookcontent #msg-bottom").remove
      text = @page_html.css(".bookcontent").text.strip
      article_text = text.gsub("鑾勾絏ュ庤鎷誨潒濯兼煉鐪磭榪惰琚氣-官家求魔殺神武動乾坤最終進化神印王座| www.9pwx.com","")
      article.text = article_text.
      article.save
    elsif (@page_url.index('sj131'))
      @page_html.css("#content a").remove
      article_text = ZhConv.convert("zh-tw",@page_html.css("#content").text.strip)
      article_text = article_text.gsub("如果您喜歡這個章節","")
      article_text = article_text.gsub("精品小說推薦","")
      article.text = article_text
      article.save
    elsif (@page_url.index('yawen8'))
      @page_html.css("#content script, #content span, #content .pageTools").remove
      article_text = ZhConv.convert("zh-tw",@page_html.css("#content").text.strip)
      article.text = article_text
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
      article_text = ZhConv.convert("zh-tw",text2)
      article.text = article_text
      article.save
    elsif (@page_url.index('quanben'))
      text = @page_html.css("#content").text.strip
      text = text.gsub(/[a-zA-Z]/,"")
      text = text.gsub("全本小说网","")
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
      article.text = article_text
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
