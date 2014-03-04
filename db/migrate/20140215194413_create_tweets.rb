class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :text
      t.string :uid
      t.string :user_name
      t.string :profile_image
      t.datetime :posted_at
      t.float :geo_lat
      t.float :geo_lon
      t.text :details

      t.timestamps
    end
  end
end
