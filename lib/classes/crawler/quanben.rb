# encoding: utf-8
class Crawler::Quanben
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("tr")
    novel = Novel.select("id,num,name").find(novel_id)
    subject = ""
    nodes.each do |node|
      if (node.children.size() == 1)
        subject = ZhConv.convert("zh-tw",node.children.text.strip)
      elsif (node.children.size() == 4)
        inside_nodes = node.children.children
        inside_nodes.each do |n|
          if n.name == "a"
            article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(@page_url + n[:href])
            next if isArticleTextOK(article,article.article_all_text) if article

            unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = @page_url + n[:href]
            article.title = ZhConv.convert("zh-tw",n.text.strip)
            article.subject = subject
            /(\d*)/ =~ n[:href]
            article.num = $1.to_i
            # puts node.text
            article.save
            end
            novel.num = article.num + 1
            novel.save
            ArticleWorker.perform_async(article.id)
          end
        end
      end
    end
  end

  def crawl_article article
    text = @page_html.css("#content").text.strip
    text = text.gsub(/[a-zA-Z]/,"")
    text = text.gsub("全本小说网","")
    text = text.gsub("wWw!QuanBEn!CoM","")
    text = text.gsub("(www.quanben.com)","")
    article_text = ZhConv.convert("zh-tw",text)
    text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end