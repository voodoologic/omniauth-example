class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :tweets

  ROLE = { :user => 2, :admin => 3}

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.provider = "twitter"
      logger.debug "autho.uid: "
      logger.debug auth.uid
      user.uid = auth.uid
      logger.debug "autho.info: "
      logger.debug auth.info
      user.username = auth.info.nickname
      user.bypass_email_validation_for_oauth_users
      logger.debug "autho.credentials.token: "
      logger.debug auth.credentials.token
      user.twitter_oauth_token = auth.credentials.token
      logger.debug "autho.credentials.secret: "
      logger.debug auth.credentials.secret
      user.twitter_oauth_secret = auth.credentials.secret
      save
    end
  end

  def twitter
    Twitter::Client.new(
      :oauth_token => twitter_oauth_token,
      :oauth_token_secret => twitter_oauth_secret
    )
  end
  def self.new_with_session(params, session)
    if session['devise.user_attributes']
      new(session['devise.user_attributes']) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def email_required?
    super && provider.blank?
  end

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  def bypass_email_validation_for_oauth_users
    skip_confirmation! if email.blank? && provider.present?
  end

end
