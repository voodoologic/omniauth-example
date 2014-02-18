class TwitterProceedure < Twitter::REST::Client
  attr_accessor :acces_token, :access_token_secret, :consumer_key, :consumer_secret

  MAX_EVENTS = 3
  # num_attempts = 0

  def initialize(user)
      @access_token         = user.twitter_oauth_token
      @access_token_secret  = user.twitter_oauth_secret
      @consumer_key         = ENV['TWITTER_KEY'] 
      @consumer_secret      = ENV['TWITTER_SECRET'] 
  end

  def collect_user_tweets
    collect_with_max_id do |max_id|
      options = {:count => 200, :include_rts => true}
      options[:max_id] = max_id unless max_id.nil?
      user_timeline(user, options)
    end
  end

  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield max_id
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end

  def save_user_tweets

     collect_users_tweets.each do |t|
      Tweet.where(:uid => t.id).first_or_create do |tweet|
        tweet.uid             = t.id
        tweet.user_name       = t.user.username
        tweet.screen_name     = t.user.username
        tweet.profile_image   = t.user.profile_image_url
        tweet.posted_at       = t.created_at
        tweet.user_id         = t.user.id
      end
    end

  end
end
