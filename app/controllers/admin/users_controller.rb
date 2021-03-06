# coding: utf-8

class Admin::UsersController < Admin::AdminController
  
  def index
    @users = User.all
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_url, :notice => "Administrateur ajouté avec succès."
    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])

    if user_params[:password].blank?
      if @user.update_without_password(user_params)
        redirect_to admin_users_url, :notice => "Administrateur modifié avec succès."  
      else
        flash[:error] = @user.errors.full_messages
        render 'edit'
      end
    else
      if @user.update(user_params)
        bypass_sign_in(@user)
        redirect_to admin_users_url, :notice => "Administrateur modifié avec succès."
      else
        flash[:error] = @user.errors.full_messages
        render 'edit'
      end
    end 
  end
  
  def destroy
    User.find(params[:id]).destroy
    head :ok
  end

private

  def user_params
    params.require(:user).permit!
  end

end