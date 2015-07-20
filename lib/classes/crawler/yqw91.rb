# encoding: utf-8
class Crawler::Yqw91
  include Crawler

  def crawl_articles novel_id
    url = @page_url.gsub("index.html","")
    nodes = @page_html.css(".novel_list a")
    nodes.each do |node|
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + node[:href].strip)
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node[:href].strip
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
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
    @page_html.css(".novel_content div").remove
    text = change_node_br_to_newline(@page_html.css(".novel_content")).strip
    if text.length < 100
      begin
        text = @page_html.css(".divimage img")[0][:src]
        text = text + "*&&$$*" + "如果看不到圖片, 請更新至新版"
      rescue Exception => e      
      end
    else
      text = ZhConv.convert("zh-tw", text,false)
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end