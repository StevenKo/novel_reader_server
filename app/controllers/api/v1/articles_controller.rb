class Api::V1::ArticlesController < Api::ApiController
  def index
    novel_id = params[:novel_id]
    order = params[:order]

    if order == "true"
      articles = Article.where('novel_id = (?)', novel_id).select("id,title,subject")
    else
      articles = Article.where('novel_id = (?)', novel_id).select("id,title,subject").by_id_desc
    end

    render :json => articles
  end

  def show
    article = Article.select("text, title").find(params[:id])
    render :json => article
  end

  def next_article
    next_article = Article.find_next_article(params[:article_id].to_i,params[:novel_id])
    render :json => next_article
  end

  def previous_article
    previous_article = Article.find_previous_article(params[:article_id].to_i,params[:novel_id])
    render :json => previous_article
  end
end
