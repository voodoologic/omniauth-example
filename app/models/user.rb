class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :tweets

  ROLE = { :user => 2, :admin => 3}

  def self.from_omniauth(auth)
    user = where(auth.slice('provider', 'uid')).first || create_from_omniauth(auth)
    user.provider = "twitter"
    user.twitter_oauth_token = auth.credentials.token
    user.twitter_oauth_secret = auth.credentials.secret
    user.uid = auth.uid
    user.username = auth.info.nickname
    user.bypass_email_validation_for_oauth_users
    user.save!
    user
  end

  def create_from_omniauth(auth)
    create! do |user|
      user.provider = "twitter"
      user.twitter_oauth_token = auth.credentials.token
      user.twitter_oauth_secret = auth.credentials.secret
      user.uid = auth.uid
      user.username = auth.info.nickname
      user.bypass_email_validation_for_oauth_users
    end
  end

  def twitter
    TwitterProceedure.new(self)
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

  def get_latest_tweets!
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
