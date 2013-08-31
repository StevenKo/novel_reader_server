class Api::V1::UsersController < ApplicationController
  def create
    render :status=>404, :json => {"message" => "fail"} and return unless params[:device_id]
    user = find_user
    if user
      user.registration_id = params[:regid]
    else
      user = User.new
      user.device_id = params[:device_id]
      user.registration_id = params[:regid]
      user.read_novels = []
    end
    user.country = params[:country] if params[:country]
    user.platform = params[:platform] if params[:platform]
    user.version = params[:version] if params[:version]
    if user.save
      render :status=>200, :json => {"message" => "success"}
    else
      render :status=>404, :json => {"message" => "fail"}
    end
  end

  def update_novel
    novel = params[:novel]
    user = find_user
    if user
      user.read_novels << novel unless user.read_novels.include? novel
      user.save
      render :status=>200, :json => {"message" => "success"}
    else
      render :status=>404, :json => {"message" => "fail"}
    end 
  end

  def update_collected_novels
    novels = params[:novels]
    user = find_user
    if user
      user.collected_novels = novels
      user.save
      render :status=>200, :json => {"message" => "success"}
    else
      render :status=>404, :json => {"message" => "fail"}
    end
  end

  def update_downloaded_novels
    novels = params[:novels]
    user = find_user
    if user
      user.downloaded_novels = novels
      user.save
      render :status=>200, :json => {"message" => "success"}
    else
      render :status=>404, :json => {"message" => "fail"}
    end
  end

  private
    def find_user
      device_id = params[:device_id]
      return nil unless device_id
      user = User.find_by_device_id(device_id)
    end
end
