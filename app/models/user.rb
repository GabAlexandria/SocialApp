class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :tags, as: :taggable

  def self.find_or_create_facebook_user(auth) 

    data = auth["extra"]["raw_info"]
    user = User.where(:email => data["email"]).first_or_initialize

    oauth = Koala::Facebook::OAuth.new(FACEBOOK_CONFIG[:app_id], FACEBOOK_CONFIG[:secret])
    new_access = oauth.exchange_access_token_info(auth.credentials.token)

    user.token = new_access["access_token"]
    user.expires_at = DateTime.now + new_access["expires"].to_i.seconds
    user.provider = auth.provider
    user.uid = auth.uid
    user.email = auth.info.email
    unless user.encrypted_password.present?
      user.password = Devise.friendly_token[0,20]
    end
    user.name = auth.info.name

    user.save!
    user
  end

  def get_location_from_facebook
    graph = Koala::Facebook::GraphAPI.new(self.token)
    loc =  graph.get_object(self.uid)["location"]["name"]
    logger.debug ["WWWWWWWWWWWWWWWWW"] << loc
    #if loc.present?
    #  user.update_attribute(:locations, loc)
    #end
  end

  def get_likes_from_facebook
    graph = Koala::Facebook::GraphAPI.new(self.token)
    likes = graph.get_connections(self.uid, "likes")
    friends = graph.get_connections(self.uid, "friends")

    logger.debug ["XXXXXXXXXXXX"] << likes
    logger.debug ["YYYYYYYYYYYY"] << friends
  end
end
