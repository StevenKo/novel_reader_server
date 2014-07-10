class NovelsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :require_admin, only: [:new, :create, :edit, :update, :index, :show, :destroy]

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
    @articles = Article.select("articles.id,title,subject,num,is_show, novel_id").where("novel_id = #{params[:id]} and is_show = true").order(sort_column + " " + sort_direction).paginate(:page => params[:page], :per_page => 50).order("num ASC")
    @websites = CrawlerAdapter.adapter_map
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
    @websites = CrawlerAdapter.adapter_map
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

  def recrawl_blank_articles
    novel = Novel.find(params[:id])
    novel.recrawl_articles_text
    redirect_to novel_path(params[:id])
  end

  private

  def sort_column
    Article.column_names.include?(params[:sort]) ? params[:sort] : "is_show"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
