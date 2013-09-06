# encoding: utf-8
class Crawler::Zongheng
  include Crawler

  def crawl_articles novel_id
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name
    subject_nodes = @page_html.css(".chapter h2")
    nodes = @page_html.css(".chapter .booklist")
    nodes.each_with_index do |node,i|
      subject = ZhConv.convert("zh-tw",subject_nodes[i].text.strip)
      a_nodes = node.css("a")
      a_nodes.each do |a_node|
        url = a_node[:href]
        article = Article.find_by_link(url)
        next if isArticleTextOK(article)
        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url
          article.title = ZhConv.convert("zh-tw",a_node.text.strip) 
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
    node = @page_html.css("#chapterContent")
    node.css("span").remove
    text = change_node_br_to_newline(node).strip
    article.text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article)
    article.save
  end

end