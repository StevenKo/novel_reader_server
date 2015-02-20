# encoding: utf-8
class Crawler::Kanunu8
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.xpath("//tr[@bgcolor='#ffffff']//a")
    # url = @page_url.gsub("index.html","")
    # url = url.gsub(/\d*\.html/,"")
    
    nodes.each do |node|
      url = @page_url
      unless node[:href].index('book') || node[:href].index('files')
        url = @page_url.gsub("index.html","")
        url = url.gsub(/\d*\.html/,"")
      end

      unless (/^\// =~ node[:href]).nil?
        url = "http://www.kanunu8.com"
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


end