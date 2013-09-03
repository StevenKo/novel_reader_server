# encoding: utf-8
class KanunuNovelCrawler
  include Crawler

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
    c = KanunuNovelCrawler.new
    c.fetch link
    novel.description = ZhConv.convert("zh-tw",c.page_html.css(".p10-24").text.strip)
  end

end