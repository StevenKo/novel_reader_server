# encoding: utf-8
class Crawler::Hfxs
  include Crawler

  def crawl_articles novel_id
    url = @page_url.gsub("index.html","")

    subject = ""
    nodes = @page_html.css("div.List").children
    nodes.each do |node|
      if node.name == "dt"
        subject = ZhConv.convert("zh-tw",node.text.strip)
      elsif (node.name == "dd" && node.children.size() == 1 && node.children[0][:href] != nil)
        article = Article.find_by_link(url + node.children[0][:href])
        next if isSkipCrawlArticle(article)

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
  end

  def crawl_article article
    @page_html.css("div.width script").remove
    text = @page_html.css("div.width").text.strip
    article.text = ZhConv.convert("zh-tw", text)
    article.save
  end

end