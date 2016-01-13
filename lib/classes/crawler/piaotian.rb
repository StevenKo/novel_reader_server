# encoding: utf-8
class Crawler::Piaotian
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".centent a")
    do_not_crawl = true
    nodes.each do |node|
      do_not_crawl = false if crawl_this_article(novel_id,node[:href])
      next if do_not_crawl

      if novel_id == 17988
        do_not_crawl = false if node[:href] == '4549275.html'
        next if do_not_crawl
      end

      if novel_id == 22363
        do_not_crawl = false if node[:href] == '4520330.html'
        next if do_not_crawl
      end
      
      if novel_id == 22331
        do_not_crawl = false if node[:href] == '4293998.html'
        next if do_not_crawl
      end

      if novel_id == 20706
        do_not_crawl = false if node[:href] == '4365062.html'
        next if do_not_crawl
      end

      if novel_id == 17996
        do_not_crawl = false if node[:href] == '4429287.html'
        next if do_not_crawl
      end

      if novel_id == 21514
        do_not_crawl = false if node[:href] == '4428958.html'
        next if do_not_crawl
      end

      if novel_id == 22709
        do_not_crawl = false if node[:href] == '4428362.html'
        next if do_not_crawl
      end

      if novel_id == 18646
        do_not_crawl = false if node[:href] == '4445848.html'
        next if do_not_crawl
      end

      if novel_id == 18315
        do_not_crawl = false if node[:href] == '4258690.html'
        next if do_not_crawl
      end

      if novel_id == 13255
        do_not_crawl = false if node[:href] == '138583.html'
        next if do_not_crawl
      end

      if novel_id == 22979
        do_not_crawl = false if node[:href] == '4502894.html'
        next if do_not_crawl
      end

      if novel_id == 23111
        do_not_crawl = false if node[:href] == '4501948.html'
        next if do_not_crawl
      end

      if novel_id == 22107
        do_not_crawl = false if node[:href] == '4503374.html'
        next if do_not_crawl
      end
      if novel_id == 22137
        do_not_crawl = false if node[:href] == '4503509.html'
        next if do_not_crawl
      end
      if novel_id == 23573
        do_not_crawl = false if node[:href] == '4501955.html'
        next if do_not_crawl
      end
      if novel_id == 22799
        do_not_crawl = false if node[:href] == '4497086.html'
        next if do_not_crawl
      end
      if novel_id == 20884
        do_not_crawl = false if node[:href] == '4508386.html'
        next if do_not_crawl
      end
      if novel_id == 18125
        do_not_crawl = false if node[:href] == "4520813.html"
        next if do_not_crawl
      end
      if novel_id == 21599
        do_not_crawl = false if node[:href] == "4453405.html"
        next if do_not_crawl
      end
      if novel_id == 17932
        do_not_crawl = false if node[:href] == "4443209.html"
        next if do_not_crawl
      end
      if novel_id == 21159
        do_not_crawl = false if node[:href] == "4446945.html"
        next if do_not_crawl
      end
      if novel_id == 18949
        do_not_crawl = false if node[:href] == "4492188.html"
        next if do_not_crawl
      end
      if novel_id == 18257
        do_not_crawl = false if node[:href] == "4491931.html"
        next if do_not_crawl
      end
      if novel_id == 18285
        do_not_crawl = false if node[:href] == "4503221.html"
        next if do_not_crawl
      end
      if novel_id == 19137
        do_not_crawl = false if node[:href] == "3294012.html"
        next if do_not_crawl
      end
      if novel_id == 17921
        do_not_crawl = false if node[:href] == "4524769.html"
        next if do_not_crawl
      end

      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(node[:href]))
      next if article
      next if node[:href].index('javascript:window')
      next if node[:href] == "#"

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = get_article_url(node[:href])
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        if novel_id == 22979
          article.num = novel.num + 1 + 7686443
        elsif novel_id == 23111
          article.num = novel.num + 1 + 7692278
        elsif novel_id == 22107
          article.num = novel.num + 1 + 7694510
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
    @page_html.css("script,a,span,div[align='center']").remove
    text = change_node_br_to_newline(@page_html).strip
    text = text.gsub("\r\n","")
    article_text = ZhConv.convert("zh-tw",text,false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end