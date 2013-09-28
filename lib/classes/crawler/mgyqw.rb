# encoding: utf-8
class Crawler::Mgyqw
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".td_con a")
    nodes.each do |node|
        url = @page_url.sub("index.html","") + node[:href]
        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url)
        next if isArticleTextOK(article,article.article_all_text) if article

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url
          article.title = ZhConv.convert("zh-tw",node.text.strip)
          novel = Novel.select("id,num,name").find(novel_id)
          article.subject = novel.name
          /(\d*)\.html/ =~ node[:href]
          article.num = $1
          novel.num = novel.num + 1
          novel.save
          # puts node.text
          article.save
        end
        ArticleWorker.perform_async(article.id)
    end
  end

  def crawl_article article
    node = @page_html.css("#div_readContent")
    node.css("script").remove
    text = change_node_br_to_newline(node)
    text = ZhConv.convert("zh-tw", text.strip)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end