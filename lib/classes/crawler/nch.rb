# encoding: utf-8
class Crawler::Nch
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("table[cellpadding='0'][width='97%'] table[bgcolor='#C0C0C0'][bordercolordark='#FFFFFF'] a")
    nodes.each do |node|
      next if node.text == '觀看全集'
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link("http://www.nch.com.tw/" + node[:href])
      next if article
      

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = "http://www.nch.com.tw/" + node[:href]
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
    node = @page_html.css("td.b")
    text = change_node_br_to_newline(node).strip.gsub("[]","").gsub("  ","").gsub("\n\n","").gsub("\r\n","")
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end