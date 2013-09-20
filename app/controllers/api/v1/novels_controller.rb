class Api::V1::NovelsController < Api::ApiController

  def index
    category_id = params[:category_id]
    # order = params[:order]
    novels = Novel.where('category_id = (?)', category_id).show.select("id,name,author,pic,article_num,last_update,is_serializing").paginate(:page => params[:page], :per_page => 15)
    render :json => novels
  end

  # def db_transfer_index
  #   category_id = params[:category_id]
  #   novels = Novel.where('category_id = (?)', category_id).select("id,link,is_classic,is_classic_action")
  #   render :json => novels
  # end

  def show
    novel = Novel.find(params[:id])
    render :json => novel
  end

  def category_hot
    category_id = params[:category_id]
    novels = Novel.where('category_id = (?) and is_category_hot = true', category_id).show.select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def category_this_week_hot
    category_id = params[:category_id]
    novels = Novel.where('category_id = (?) and is_category_this_week_hot = true', category_id).show.select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def category_recommend
    category_id = params[:category_id]
    novels = Novel.where('category_id = (?) and is_category_recommend = true', category_id).show.select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def hot
    novels_id = HotShip.all.map{|ship| ship.novel_id}.join(',')
    novels = Novel.where("id in (#{novels_id})").show.select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def this_week_hot
    novels_id = ThisWeekHotShip.all.map{|ship| ship.novel_id}.join(',')
    novels = Novel.where("id in (#{novels_id})").show.select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def this_month_hot
    novels_id = ThisMonthHotShip.all.map{|ship| ship.novel_id}.join(',')
    novels = Novel.where("id in (#{novels_id})").show.select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def all_novel_update
    novels = Novel.show.select("id,name,author,pic,article_num,last_update,is_serializing").order("updated_at DESC").paginate(:page => params[:page], :per_page => 15)
    render :json => novels
  end

  def search
    keyword = params[:search].strip
    keyword_cn = keyword.clone
    keyword_cn = ZhConv.convert("zh-tw",keyword_cn)
    novels = Novel.where("name like ? or author like ? or name like ? or author like ?", "%#{keyword}%","%#{keyword}%","%#{keyword_cn}","%#{keyword_cn}").show.select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def detail_for_save
    @novel = Novel.find(params[:id])
    render :json => { "novel" =>  @novel }
    # @articles = Article.where("novel_id = #{@novel.id}").select("id, subject, title")
  end

  
  def classic
    novels = Novel.where('is_classic = true').show.select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end

  def classic_action
    novels = Novel.where('is_classic_action = true').show.select("id,name,author,pic,article_num,last_update,is_serializing")
    render :json => novels
  end
end
