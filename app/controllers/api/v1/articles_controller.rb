class Api::V1::ArticlesController < Api::ApiController
  def index
    novel_id = params[:novel_id]
    # order = params[:order]
    articles = Article.where('novel_id = (?)', novel_id).select("id,link,title,subject").paginate(:page => params[:page], :per_page => 15)
    render :json => articles
  end

  def show
    article = Article.find(params[:id])
    render :json => article
  end
end
