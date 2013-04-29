class Api::V1::ArticlesController < Api::ApiController
  def index
    novel_id = params[:novel_id]
    order = params[:order]

    if order == "true"
      articles = Article.where('novel_id = (?)', novel_id).show.select("id,title,subject")
    else
      articles = Article.where('novel_id = (?)', novel_id).show.select("id,title,subject").by_id_desc
    end

    render :json => articles
  end

  # def db_transfer_index
  #   novel_id = params[:novel_id]
  #   articles = Article.where('novel_id = (?)', novel_id).select("id,title,subject,link,novel_id")

  #   render :json => articles
  # end

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

  def articles_by_num
    novel_id = params[:novel_id]
    order = params[:order]

    if order == "true"
      articles = Article.where('novel_id = (?)', novel_id).show.select("id,title,subject,num").by_num_asc
    else
      articles = Article.where('novel_id = (?)', novel_id).show.select("id,title,subject,num").by_num_desc
    end

    render :json => articles
  end

  def next_article_by_num
    params[:num] = Article.select("num").find(params[:article_id]).num if(params[:num] == "0")
    articles = Article.select("id").where("novel_id = #{params[:novel_id]} and num > #{params[:num]}").show
    if articles.length > 0
      render :json => Article.select('id, novel_id, text, title,num').find(articles[0].id)
    else
      render :json => nil
    end
  end

  def previous_article_by_num
    params[:num] = Article.select("num").find(params[:article_id]).num if(params[:num] == "0")
    articles = Article.select("id").where("novel_id = #{params[:novel_id]} and num < #{params[:num]}").show
    if articles.length > 0
      render :json => Article.select('id, novel_id, text, title,num').find(articles[articles.length-1].id)
    else
      render :json => nil
    end
  end

end
