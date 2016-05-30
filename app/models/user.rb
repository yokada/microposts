class User < ActiveRecord::Base
  before_save { self.email = self.email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :email, presence: true, length: {maximum: 255 }
  has_secure_password

  validates :profile, length: {maximum: 255}, allow_blank: true

  COUNTRY_OPTIONS = ['Japan', 'United States', 'China', 'others'].map!(&:freeze).freeze
  validates :country, inclusion: { in: COUNTRY_OPTIONS }, allow_blank: true

  has_many :microposts

  # following users of other one user
  has_many :following_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :following_users, through: :following_relationships, source: :followed #<= source :followed means references symbol name provided Relationship class

  # followers of other one user's
  has_many :follower_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :follower_users, through: :following_relationships, source: :follower

  def follow(other_user)
    following_relationships.find_or_create_by(followed_id: other_user.id)
  end

  def unfollow(other_user)
    #binding.pry
    following_relationship = following_relationships.find_by(followed_id: other_user.id)
    following_relationship.destroy if following_relationship
  end

  def following?(other_user)
    following_users.include?(other_user)
  end

  def retweeted?(micropost)
    microposts.exists?(retweet_id: micropost.id)
  end

  def feed_items
    Micropost.where(user_id: following_user_ids + [self.id])
  end

end
