# encoding: UTF-8

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
    begin
      article = Article.joins(:article_text).select("text, title").find(params[:id])
      if article.text.nil?
        render :json => {title: article.title, text: "\n抱歉，目前伺服器有問題，請稍微等候一下(估計需要一天)，待伺服器重整，謝謝\n（因為伺服器的資料出了問題，書籤會有點亂掉，請刪除書籤，造成不便，十分抱歉!)"}.to_json
      else
        render :json => article
      end
    rescue
      render :json => {title: "", text: "\n抱歉，目前伺服器有問題，請稍微等候一下(估計需要一天)，待伺服器重整，謝謝\n（因為伺服器的資料出了問題，書籤會有點亂掉，請刪除書籤，造成不便，十分抱歉!)"}.to_json
    end
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
    articles = Article.select("id").where("novel_id = #{params[:novel_id]} and num > #{params[:num]}").show.limit(1)
    if articles.length > 0
      render :json => Article.joins(:article_text).select('articles.id, novel_id, text, title,num').find(articles[0].id)
    else
      render :json => nil
    end
  end

  def previous_article_by_num
    params[:num] = Article.select("num").find(params[:article_id]).num if(params[:num] == "0")
    articles = Article.select("id").where("novel_id = #{params[:novel_id]} and num < #{params[:num]}").show.limit(1)
    if articles.length > 0
      render :json => Article.joins(:article_text).select('articles.id, novel_id, text, title,num').find(articles[articles.length-1].id)
    else
      render :json => nil
    end
  end

end
