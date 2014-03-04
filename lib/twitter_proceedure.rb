class TwitterProceedure < Twitter::REST::Client
  attr_accessor :acces_token, :access_token_secret, :consumer_key, :consumer_secret
  # goal: 
  # recieve tweets on page load
  # do daily updates -- rake task
  # create tabs for meta data
  # put in location tab for maps (open source map)
  # graph of data 
  # personal voting
  # user voting
  # meta data about beer.
  # hyperlink to beer website. currated or top google search 
  # how do I store all this data. s3?
  # api for custom requests
  # 
  #

  MAX_ATTEMPTS = 3
  num_attempts = 0

  def initialize(user)
      @access_token         = user.twitter_oauth_token
      @access_token_secret  = user.twitter_oauth_secret
      @consumer_key         = ENV['TWITTER_KEY'] 
      @consumer_secret      = ENV['TWITTER_SECRET'] 
  end

  def collect_all_user_tweets
    collect_with_max_id do |max_id|
      options = {:count => 200, :include_rts => true}
      options[:max_id] = max_id unless max_id.nil?
      save_user_tweets(user_timeline(user, options))
    end
  end

  def get_daily_user_tweets

  end

  def get_all_tweets_from_tweet_id(tweet_id)
    rate_limit_safe do

    end
  end

  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield max_id
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end

  def save_user_tweets(user_tweets= nil)
    if user_tweets
      user_tweets.each do |t|
        Tweet.where(:uid => t.id.to_s).first_or_create do |tweet|
            tweet.uid             = t.id
            tweet.user_name       = t.user.username
            tweet.profile_image   = t.user.profile_image_url
            tweet.posted_at       = t.created_at
            tweet.user_id         = t.user.id
            tweet.geo_lat         = t.geo.latitude
            tweet.geo_lon         = t.geo.longitude
            tweet.details         = t['attrs'].to_json
        end
      end
    else
      self.user_timeline.each do |t|
        Tweet.where(:uid => t.id.to_s).first_or_create do |tweet|
          tweet.uid             = t.id.to_s
          tweet.user_name       = t.user.username
          tweet.profile_image   = t.user.profile_image_url.to_s
          tweet.posted_at       = t.created_at
          tweet.user_id         = t.user.id
          tweet.geo_lat         = t.geo.latitude
          tweet.geo_lon         = t.geo.longitude
          tweet.details         = t['attrs'].to_s
        end
      end
    end
  end

  def rate_limit_safe(&block)
    num_attempts = 0
    begin
      num_attempts += 1
      yield
    rescue Twitter::Error::TooManyRequests => error
      if num_attempts <= MAX_ATTEMPTS
        # NOTE: Your process could go to sleep for up to 15 minutes but if you
        # retry any sooner, it will almost certainly fail with the same exception.
        puts error.inspect
        sleep error.rate_limit.reset_in
        retry
      else
        raise
      end
    end
  end
end
