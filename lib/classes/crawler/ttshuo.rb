# encoding: utf-8
class Crawler::Ttshuo
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".ChapterList_Item a")
    nodes.each do |node|
      article = Article.find_by_link("http://www.ttshuo.com" + node[:href])
      next if isSkipCrawlArticle(article)

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
  end

  def crawl_article article
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
  end

end