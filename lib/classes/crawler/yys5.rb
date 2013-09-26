# encoding: utf-8
class Crawler::Yys5
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".f_title > a")
    url = "http://bbs.yys5.com/"
    nodes.each do |node|
      article = Article.joins(:article_text).select("articles.id, is_show, title, link, novel_id, subject, num, article_texts.text").find_by_link(url + node[:href])
      next if isArticleTextOK(article,article.text) if article
      next if node[:style]
      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node[:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        article.num = novel.num + 1
        novel.num = novel.num + 1
        novel.save
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end

    nodes = page_html.css("a.p_redirect")
    if nodes[1] && nodes[1].text == "››"
      url = "http://bbs.yys5.com/" + nodes[1][:href]
      crawler = CrawlerAdapter.get_instance url
      crawler.fetch url
      crawler.crawl_articles novel_id
    end
  end

  def crawl_article article
    node = @page_html.css(".t_msgfont")
    node.css("span[style='font-size:0px;color:#E7F4FE;']").remove
    node.css("span[style='display:none;']").remove
    text = change_node_br_to_newline(node)
    text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end