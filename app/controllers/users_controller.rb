class UsersController < ApplicationController
  before_filter :set_current_user
  def show
    begin 
    @tweets = @current_user.twitter.user_timeline
    rescue => e
      logger.debug e
      @tweet = []
    end
  end

  def set_current_user
    @current_user = current_user
  end

  def email_aquisition

  end
end
