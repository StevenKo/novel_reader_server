# encoding: utf-8
class Crawler::Yq123
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("#list dl").children
    subject = ""
    do_not_crawl = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node| 
      if node[:id] == "qw"
        subject = node.text
        puts subject
      elsif node.css("a")[0]
        node = node.css("a")[0]
        do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
        next if do_not_crawl_from_link
        if novel_id == 21442
          do_not_crawl = false if node[:href] == "http://www.123yq.com/read/35/35427/7123831.shtml"
          next if do_not_crawl
        end
        if novel_id == 22137
          do_not_crawl = false if node[:href] == "http://www.123yq.com/read/33/33483/7633101.shtml"
          next if do_not_crawl
        end
      
        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(node[:href])
        next if article

        unless article
          article = Article.new
          article.novel_id = novel_id
          article.link = node[:href]
          article.title = ZhConv.convert("zh-tw",node.text.strip,false)
          novel = Novel.select("id,num,name").find(novel_id)
          if(subject == "")
            subject = novel.name
          end
          article.subject = ZhConv.convert("zh-tw",subject,false)
          /(\d*)\.shtml/ =~ node[:href]
          article.num = $1.to_i
          # puts node.text
          article.save
        end
        ArticleWorker.perform_async(article.id)
      end
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    @page_html.css("#TXT a,script").remove
    node = @page_html.css("#TXT")
    text = change_node_br_to_newline(node).strip
    text = text.gsub("最新章节","")
    text = text.gsub("TXT下载","")
    text = text.gsub(/本章节是.*地址为/,"")
    text = text.gsub("如果你觉的本章节还不错的话请不要忘记向您QQ群和微博里的朋友推荐哦！","")
    text = ZhConv.convert("zh-tw", text,false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end