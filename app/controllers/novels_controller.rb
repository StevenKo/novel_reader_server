class NovelsController < ApplicationController
  def index
    @novels = Novel.select("id,name,author,is_show").paginate(:page => params[:page], :per_page => 20)
  end

  def search
    keyword = params[:search].strip
    @novels = Novel.select("id,name,author,is_show").where("name like ? or author like ?", "%#{keyword}%","%#{keyword}%").select("id,name,author,pic,article_num,last_update,is_serializing")
  end

  def update_novel
    novel = Novel.find(params[:novel_id])
    redirect_to :action => 'show', :id => novel.id
  end

  def show
    @novel = Novel.find(params[:id])
    @articles = Article.select("id,title,subject,num,is_show, text, novel_id").where("novel_id = #{params[:id]}").paginate(:page => params[:page], :per_page => 50).order("num ASC")
  end

  def edit
    @novel = Novel.find(params[:id])
  end

  def destroy
    @novel = Novel.find(params[:id])
    Article.delete_all("novel_id = #{@novel.id}")
    @novel.destroy
    redirect_to :controller => 'novels', :action => 'index'
  end

  def new
    @novel = Novel.new
  end

  def create
    @novel = Novel.new(params[:novel])
    if @novel.save
      render :action => 'show', :id => @novel.id
    else
      render :action => "new"
    end
  end

  def update
    @novel = Novel.find(params[:id])
    if @novel.update_attributes(params[:novel])
      redirect_to :action => 'show'
    else
      render :action => "edit" 
    end
  end

  def set_all_articles_to_invisiable
    Article.update_all("is_show = false", "novel_id = #{params[:id]}")
    redirect_to novel_path(params[:id])
  end

  def recrawl_all_articles
    CrawlWorker.perform_async(params[:id])
    redirect_to novel_path(params[:id])
  end

end
