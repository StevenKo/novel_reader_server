class Api::V1::UsersController < ApplicationController
  def create
    render :status=>404, :json => {"message" => "fail"} and return unless params[:email]
    user = find_user
    if user
      user.email = params[:email]
    else
      user = User.new
      user.email = params[:email]
    end

    if user.save
      render :status=>200, :json => {"message" => "success"}
    else
      render :status=>404, :json => {"message" => "fail"}
    end
  end

  def update_novel
    user = find_user
    if user
      user.collect_novels = params[:collect_novels].split(",")
      user.download_novels = params[:download_novels].split(",")
      user.save
      render :status=>200, :json => {"message" => "success"}
    else
      render :status=>404, :json => {"message" => "fail"}
    end 
  end

  def get_novels
    user = find_user
    if user
      collected_novels = Novel.where(id: user.collect_novels).select("id,name,author,pic,article_num,last_update,is_serializing")
      download_novels = Novel.where(id: user.download_novels).select("id,name,author,pic,article_num,last_update,is_serializing")
      render :status=>200, :json => {"collected_novels" => collected_novels, "download_novels" => download_novels}
    else
      render :status=>404, :json => {"message" => "fail"}
    end
  end


  private
    def find_user
      email = params[:email]
      return nil unless email
      user = User.find_by_email(email)
    end
end
