class Api::V1::NovelsController < Api::ApiController

  def index
    category_id = params[:category_id]
    # order = params[:order]
    novels = Novel.where('category_id = (?)', category_id).select("id,name,author,pic,article_num,last_update,is_serializing").paginate(:page => params[:page], :per_page => 15)
    render :json => novels
  end

  def show
    novel = Novel.find(params[:id])
    render :json => novel
  end

  def category_hot
    category_id = params[:category_id]
    novels = Novel.where('category_id = (?) and is_category_hot = true', category_id).select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def category_this_week_hot
    category_id = params[:category_id]
    novels = Novel.where('category_id = (?) and is_category_this_week_hot = true', category_id).select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def category_recommend
    category_id = params[:category_id]
    novels = Novel.where('category_id = (?) and is_category_recommend = true', category_id).select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def hot
    novels_id = HotShip.all.map{|ship| ship.novel_id}.join(',')
    novels = Novel.where("id in (#{novels_id})").select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def this_week_hot
    novels_id = ThisWeekHotShip.all.map{|ship| ship.novel_id}.join(',')
    novels = Novel.where("id in (#{novels_id})").select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def this_month_hot
    novels_id = ThisMonthHotShip.all.map{|ship| ship.novel_id}.join(',')
    novels = Novel.where("id in (#{novels_id})").select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def search
    keyword = params[:search]
    novels = Novel.where("name like ? or author like ?", "%#{keyword}%","%#{keyword}%").select("id,name,author,pic")
    render :json => novels
  end

  def detail_for_save
    @novel = Novel.includes(:category).find(params[:id])
    @articles = Article.where("novel_id = #{@novel.id}").select("id, subject, title")
  end
end
