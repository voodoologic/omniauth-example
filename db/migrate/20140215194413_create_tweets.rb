class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :text
      t.integer :uid
      t.string :user_name
      t.string :screen_name
      t.string :profile_image
      t.datetime :posted_at
      t.string :coordinates
      t.string :details

      t.timestamps
    end
  end
end
