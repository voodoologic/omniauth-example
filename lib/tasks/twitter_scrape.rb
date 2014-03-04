namespace :twitter do 
  desc "once a day scape of user twitter account."
  task :daily_scrape => :environment do
    User.all.each do |u|
      u.get_latest_tweets

    end
  end
end
