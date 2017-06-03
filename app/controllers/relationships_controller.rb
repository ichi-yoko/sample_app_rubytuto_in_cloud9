class RelationshipsController < ApplicationController
  before_action :logged_in_user

  # POST /relationshops
  # hidden_field_tag @user.id
  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    # Ajaxを使う
    # redirect_to user
    respond_to do |format|
      format.html { redirect_to @user }
      format.js   # { create.js.erb} が省略されている
    end
  end

  # DELETE /relationshops/:id
  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    # Ajaxを使う
    # redirect_to user
    respond_to do |format|
      format.html { redirect_to @user }
      format.js   # { destroy.js.erb} が省略されてい
    end
  end
end
