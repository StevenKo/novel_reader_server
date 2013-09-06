# encoding: utf-8
class Crawler::Txt92
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".ccss a")
    nodes.each do |node|
      article = Article.find_by_link(@page_url + node[:href])
      next if isArticleTextOK(article)

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

  def crawl_article article
    node = @page_html.css("#chapter_content")
    text = change_node_br_to_newline(node)
    text = text.gsub("www.92txt.net 就爱网","")
    text = text.gsub("亲们记得多给戚惜【投推荐票】、【投月票】，【加入书架】，【留言评论】哦，鞠躬敬谢","")
    article.text = ZhConv.convert("zh-tw", text)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end