# encoding: utf-8
class Crawler::Guli
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("#detaillist a")
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name
    nodes.each do |node|
      next unless node[:href]
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link("http://www.guli.cc" + node[:href])
      next if article

      unless article 
      article = Article.new
      article.novel_id = novel_id
      article.link = "http://www.guli.cc" + node[:href]
      article.title = ZhConv.convert("zh-tw",node.text.strip)
      article.subject = subject
      /\d+\/(\d+)\// =~ node[:href]
      next if $1.nil?
      article.num = $1.to_i
      # puts node.text
      article.save
      end
      # novel.num = article.num + 1
      # novel.save
      ArticleWorker.perform_async(article.id)
    end
  end
  
  def crawl_article article
    text = @page_html.css("div#content").text.strip
    text = text.gsub("txtrightshow();","").strip
    text = ZhConv.convert("zh-tw", text)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end