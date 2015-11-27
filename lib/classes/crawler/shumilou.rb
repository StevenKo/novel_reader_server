# encoding: utf-8
class Crawler::Shumilou
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".zl a")
    do_not_crawl = true
    nodes.each do |node|
      if novel_id == 21353
        do_not_crawl = false if node[:href] == "/mengmengshanhaijing/4498796.html"
        next if do_not_crawl
      end
      if novel_id == 2792
        do_not_crawl = false if node[:href] == "/xiaohuadetieshengaoshou/5848093.html"
        next if do_not_crawl
      end
      if novel_id == 20816
        do_not_crawl = false if node[:href] == "/wureyaoniewangyefeicainitiansixiaojie/4689362.html"
        next if do_not_crawl
      end
      if novel_id == 18081
        do_not_crawl = false if node[:href] == "/wodemeinvzongcailaopo/1449194.html"
        next if do_not_crawl
      end
      if novel_id == 22927
        do_not_crawl = false if node[:href] == "/jipinfuerdai/5846591.html"
        next if do_not_crawl
      end
      if novel_id == 21685
        do_not_crawl = false if node[:href] == "/jiuyanzhizun/5948291.html"
        next if do_not_crawl
      end
      if novel_id == 20688
        do_not_crawl = false if node[:href] == "/chaopinxiangshi/6035661.html"
        next if do_not_crawl
      end
      if novel_id == 21681
        do_not_crawl = false if node[:href] == "/hanyudaqianbei/6036850.html"
        next if do_not_crawl
      end
      if novel_id == 21237
        do_not_crawl = false if node[:href] == "/fuheidunvshenyixianggong/6028833.html"
        next if do_not_crawl
      end
      if novel_id == 4106
        do_not_crawl = false if node[:href] == "/yvxiangyi/6031241.html"
        next if do_not_crawl
      end
      if novel_id == 21772
        do_not_crawl = false if node[:href] == "/zhenguandaxianren/6028102.html"
        next if do_not_crawl
      end

      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(node[:href]))
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = get_article_url(node[:href])
        article.title = node.text.strip
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        if novel_id == 20688
          article.num = novel.num + 1 + 7688188
        else
          article.num = novel.num + 1
        end
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
    @page_html.css("#content span").remove
    @page_html.css("#content b").remove
    @page_html.css("#content .title").remove
    @page_html.css("#content script").remove
    @page_html.css("#content a").remove
    @page_html.css("div[style='color:#FF0000']").remove
    @page_html.css("center[style='font-size:15px']").remove
    text = @page_html.css("#content").text.strip
    article_text = ZhConv.convert("zh-tw",text,false)
    text = article_text

    if text.size < 100
      imgs = @page_html.css("#content img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      text = text_img
    end

    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end