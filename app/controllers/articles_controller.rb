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

  def reset_num
    num = params[:num]
    novel_id = params[:novel_id]
    article_id = params[:article_id]

    article = Article.where("novel_id = #{novel_id} and num = #{num}")
    if article[0]
      articles = Article.select("id,num").where("novel_id = #{novel_id} and num >= #{num}")
      Article.transaction do
        articles.each do |a|
          a.update_column(:num,a.num + 1)
        end
      end
      novel = Novel.select("id,num").find(novel_id)
      novel.update_column(:num,novel.num + 1)
      article = Article.select("id,num").find(article_id)
      article.update_column(:num,num)
    else
      article = Article.select("id,num").find(article_id)
      article.update_column(:num,num)
    end
    
    redirect_to :controller => 'novels', :action => 'show', :id => novel_id, :page => params[:page]
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
      redirect_to article_path(article.id)
    else
      render :action => "new", :novel_id => article.novel_id
    end
  end

  def re_crawl
    article = Article.select("id, text, link").find(params[:article_id])
    crawler = NovelCrawler.new

    if (article.link.index("bestory"))
      crawler.fetch article.link
      crawler.crawl_article article
    else
      crawler.fetch_other_site article.link
      crawler.crawl_text_onther_site article
    end
      
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

  def search_by_num
    @article = Article.where("novel_id = #{params[:novel_id]} and num = #{params[:num]}")[0]
    render :show
  end
end
