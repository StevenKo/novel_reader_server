# encoding: utf-8
class Crawler::Snwx
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("#list a")
    do_not_crawl = true
    nodes.each do |node|
      do_not_crawl = false if crawl_this_article(novel_id,node[:href])
      next if do_not_crawl
      

      if(novel_id == 21520)
        do_not_crawl = false if node[:href] == '24745660.html'
        next if do_not_crawl
      end
      if(novel_id == 18911)
        do_not_crawl = false if node[:href] == '21572227.html'
        next if do_not_crawl
      end

      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(@page_url + node[:href])
      next if article

      unless article 
      article = Article.new
      article.novel_id = novel_id
      article.link = @page_url + node[:href]
      article.title = ZhConv.convert("zh-tw",node.text.strip,false)
      novel = Novel.select("id,num,name").find(novel_id)
      article.subject = novel.name
      article.num = novel.num + 1
      novel.num = novel.num + 1
      novel.save
      article.save
      end
      ArticleWorker.perform_async(article.id)          
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css("#BookText")
    node.css("script").remove
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text.strip,false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end