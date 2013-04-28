class ArticlesController < ApplicationController
  
  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(params[:article])
      render :action => 'show'
    else
      render :action => "edit" 
    end
  end

  def show
    @article = Article.find(params[:id]) 
  end

  def new
    @novel_id = params[:novel_id]
  end

  def create
    article = Article.new(params[:article])
    novel = Novel.select("id,num").find(article.novel_id)
    article.num = novel.num + 1
    novel.num = novel.num + 1
    if article.save && novel.save
      render :action => 'show'
    else
      render :action => "new", :novel_id => article.novel_id
    end
  end

  def re_crawl
    article = Article.select("id, text, link").find(params[:article_id])
    crawler = NovelCrawler.new
    crawler.fetch article.link
    crawler.crawl_article article
    redirect_to :action => 'show', :id => article.id
  end

  def crawl_text_onther_site
    article = Article.select("id, text, link").find(params[:article_id])
    crawler = NovelCrawler.new
    crawler.fetch_other_site params[:url]
    crawler.crawl_text_onther_site article
    redirect_to :action => 'show', :id => article.id
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    redirect_to :controller => 'novels', :action => 'show', :id => @article.novel_id
  end
end
