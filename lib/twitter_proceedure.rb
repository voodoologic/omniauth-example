class TwitterProceedure < Twitter::REST::Client

  MAX_EVENTS = 3
  # num_attempts = 0

  def initialize(user)
    Twitter::REST::Client.new do |config|
      config.access_token         = user.twitter_oauth_token
      config.access_token_secret  = user.twitter_oauth_secret
      config.consumer_key         = ENV['TWITTER_KEY'] 
      config.consumer_secret      = ENV['TWITTER_SECRET'] 
    end
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
