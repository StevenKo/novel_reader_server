class NovelsController < ApplicationController
  def index
    @novels = Novel.select("id,name,author").paginate(:page => params[:page], :per_page => 20)
  end

  def search
    keyword = params[:search].strip
    @novels = Novel.select("id,name,author").where("name like ? or author like ?", "%#{keyword}%","%#{keyword}%").select("id,name,author,pic,article_num,last_update,is_serializing")
  end

  def update_novel
    novel = Novel.find(params[:novel_id])
    redirect_to :action => 'show', :id => novel.id
  end

  def show
    @novel = Novel.find(params[:id])
    @articles = Article.select("id,title,subject,num").where("novel_id = #{params[:id]}").paginate(:page => params[:page], :per_page => 50)
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

end
