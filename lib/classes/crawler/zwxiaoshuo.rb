# encoding: utf-8
class Crawler::Zwxiaoshuo
  include Crawler

  def crawl_articles novel_id
    url = @page_url
    nodes = @page_html.css(".insert_list li a")
    nodes.each do |node|
      article = Article.find_by_link(url + node[:href])
      next if isArticleTextOK(article)

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
  end

  def crawl_article article
    @page_html.css(".contentbox div").remove
    text = @page_html.css(".contentbox").text.strip
    article.text = ZhConv.convert("zh-tw", text)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end