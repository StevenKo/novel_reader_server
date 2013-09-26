# encoding: utf-8
class Crawler::Zwwx
  include Crawler

  def crawl_articles novel_id
    subject = ""
    nodes = @page_html.css(".book_article_texttable div")
    nodes.each do |node|
      if node[:class] == "book_article_texttitle"
        subject = ZhConv.convert("zh-tw",node.text.strip)
      else
        inside_nodes = node.css("a")
        inside_nodes.each do |in_node|
          article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(in_node[:href])

          next if isArticleTextOK(article,article.text) if article

          unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = in_node[:href]
            article.title = ZhConv.convert("zh-tw",in_node.text.strip)
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
  end

  def crawl_article article
    node = @page_html.css("#content")
    text = node.text.strip
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    article.save
  end

end