# encoding: utf-8
class Crawler::Ttshuo
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".ChapterList_Item a")
    nodes.each do |node|
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link("http://www.ttshuo.com" + node[:href])
      next if article

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
    set_novel_last_update_and_num(novel_id)
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
    text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end