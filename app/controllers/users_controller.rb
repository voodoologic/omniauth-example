class UsersController < ApplicationController
  before_filter :set_current_user
  def show

  end

  def set_current_user
    @current_user = current_user
  end

  def email_aquisition

  end
end