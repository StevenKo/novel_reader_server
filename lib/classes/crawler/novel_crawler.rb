# encoding: utf-8
class Crawler::NovelCrawler
  include Crawler

  def crawl_article article
    if (@page_url.index('qiuwu'))
      text = @page_html.css("#content").text.strip
      article.text = ZhConv.convert("zh-tw", text)
      raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
      article.save
    end
  end
end
