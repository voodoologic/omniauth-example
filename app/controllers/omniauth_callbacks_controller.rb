class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
     auth = request.env["omniauth.auth"]
    user = User.from_omniauth request.env["omniauth.auth"]
    logger.debug "user: " 
    logger.debug user.inspect
    logger.debug "autho.uid: "
    logger.debug auth.uid
    logger.debug "autho.info: "
    logger.debug auth.info
    logger.debug "autho.credentials.token: "
    logger.debug auth.credentials.token
    logger.debug "autho.credentials.secret: "
    logger.debug auth.credentials.secret
    if user.persisted?
      sign_in_and_redirect user, notice: "Signed in!"
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end

  alias_method :twitter, :all
end
