# encoding: utf-8
class Crawler::Kanunu
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.xpath("//tr[@bgcolor='#ffffff']//a")
    # url = @page_url.gsub("index.html","")
    # url = url.gsub(/\d*\.html/,"")
    url = "http://book.kanunu.org"
    nodes.each do |node|
      unless node[:href].index('book') || node[:href].index('files')
        url = @page_url.gsub("index.html","")
        url = url.gsub(/\d*\.html/,"")
      end
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url+ node[:href])
      next if article

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
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    text = @page_html.css("#content").text.strip
    unless text.size > 100
      text = @page_html.css("td[width='820']").text
    end
    text = ZhConv.convert("zh-tw", text)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

  def crawl_novels category_id
    # puts @page_url
    nodes = @page_html.css("tr[bgcolor='#ffffff']")
    nodes.each do |novel_row|
      next unless novel_row.css("a")[0]
      link = "http://book.kanunu.org" + novel_row.css("a")[0][:href]
      author = @page_html.css("h2").text.strip.sub("作品集","")
      name = novel_row.css("strong").text.sub("在线阅读","").strip
      description = novel_row.css("td[valign='top']").text.strip
      description = novel_row.css("td.p10-24").text.strip if description.size < 20
      pic = "http://book.kanunu.org" + novel_row.css("img")[0][:src] if novel_row.css("img")[0]
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
        CrawlWorker.perform_async(novel.id)
      end
    end

    nodes = @page_html.css("tr[bgcolor='#fff7e7'] strong a")
    nodes.each_with_index do |node,i|
      # next if i > 5
      # node = node.parent
      link = "http://book.kanunu.org" + node[:href]
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