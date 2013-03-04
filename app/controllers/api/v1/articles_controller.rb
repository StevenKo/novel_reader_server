class Api::V1::ArticlesController < Api::ApiController
  def index
    novel_id = params[:novel_id]
    order = params[:order]

    if order == "true"
      articles = Article.where('novel_id = (?)', novel_id).select("id,title,subject").paginate(:page => params[:page], :per_page => 15)
    else
      articles = Article.where('novel_id = (?)', novel_id).select("id,title,subject").paginate(:page => params[:page], :per_page => 15).by_id_desc
    end

    render :json => articles
  end

  def show
    article = Article.select("text").find(params[:id])
    render :json => article
  end
end
