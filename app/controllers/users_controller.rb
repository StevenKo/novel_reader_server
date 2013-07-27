class UsersController < ApplicationController
  def create
    regid = params[:regid]
    user = User.find_by_registration_id(regid)
    if user
      user.registration_id = regid;
      user.save
    else
      user = User.new
      user.registration_id = regid
      user.read_novels = []
      user.save
    end
    render :status=>200, :json => {"message" => "success"}
  end

  def update_novel
    novel = params[:novel]
    regid = params[:regid]
    user = User.find_by_registration_id(regid)
    if user
      user.read_novels << novel unless user.read_novels.include? novel
      user.save
      render :status=>200, :json => {"message" => "success"}
    else
      render :status=>404, :json => {"message" => "fail"}
    end
    
  end
end
