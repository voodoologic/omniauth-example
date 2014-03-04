class UsersController < ApplicationController
  before_filter :set_current_user
  def show
    begin 
      @current_user.twitter.save_user_tweets
      @tweets = @current_user.tweets
    rescue => e
      logger.debug e
      @tweets = []
    end
  end

  def set_current_user
    @current_user = current_user
  end

  def email_aquisition

  end
end
