# encoding: utf-8
class Crawler::Kanunu
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.xpath("//tr[@bgcolor='#ffffff']//a")
    nodes.each do |node|
      /\/(\d*\.html)/ =~ @page_url
      url = @page_url
      url = @page_url.gsub($1,"") if $1
      article = Article.find_by_link(url+ node[:href])
      next if isSkipCrawlArticle(article)

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
  end

  def crawl_article article
    text = @page_html.css("tr p").text.strip
    article.text = ZhConv.convert("zh-tw", text)
    article.save
  end

  def crawl_novels category_id
    # puts @page_url
    nodes = @page_html.css("tr[bgcolor='#ffffff']")

    nodes.each do |novel_row|
      link = "http://book.kanunu.org" + novel_row.css("a")[0][:href]
      author = @page_html.css("h2").text.strip.sub("作品集","")
      name = novel_row.css("strong").text.sub("在线阅读","").strip
      description = novel_row.css("td[valign='top']").text.strip
      pic = "http://book.kanunu.org" + novel_row.css("img")[0][:src]
      novel =  Novel.find_by_link link
      unless novel
        novel = Novel.new
        novel.link = link
        novel.name = ZhConv.convert("zh-tw",name)
        novel.author = ZhConv.convert("zh-tw",author)
        novel.description = ZhConv.convert("zh-tw",description)
        novel.category_id = category_id
        novel.is_show = true
        novel.is_serializing = 0
        novel.pic = pic
        novel.save
      end
      CrawlWorker.perform_async(novel.id)
    end

    if(nodes.size == 0)
      nodes = @page_html.css("tr[bgcolor='#fff7e7'] a")
      nodes.each do |node|
        link = link = "http://book.kanunu.org" + node[:href]
        author = @page_html.css("h2").text.strip.sub("作品集","")
        name = node.text.strip
        novel = Novel.find_by_link link
        unless novel
          novel = Novel.new
          novel.link = link
          novel.name = ZhConv.convert("zh-tw",name)
          novel.author = ZhConv.convert("zh-tw",author)
          novel.category_id = category_id
          novel.is_show = true
          novel.is_serializing = 0
          novel.last_update = Time.now.strftime("%m/%d/%Y")
          novel.article_num = "?"
          crawl_novel_description link,novel
          novel.save
        end
        CrawlWorker.perform_async(novel.id)
      end
    end
  end

  def crawl_novel_description link, novel
    c = Crawler::Kanunu.new
    c.fetch link
    novel.description = ZhConv.convert("zh-tw",c.page_html.css(".p10-24").text.strip)
  end

end