class Tweet < ApplicationRecord
  include ActionView::Helpers::UrlHelper
  before_save :add_hashtags
  
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liking_users, :through => :likes, :source => :user

  validates :content, :presence => true
  
  scope :tweets_for_me, -> (user) { where(user_id: user.arr_friends_id_and_me) }
  
  paginates_per 50

  def add_hashtags
    new_content = ""
    self.content.split(" ").each do |word|
      if word.starts_with?("#")
        word_clean = word.gsub("#", "")
        new_content += link_to(word, Rails.application.routes.url_helpers.root_path+"?search="+word_clean)+" "
      else
        new_content += word + " "
      end
    end
    self.content = new_content
  end

  def like_icon(user)
    if self.is_liked?(user)
      'heart'
    else
      'heart-broken'
    end
  end

  def retweet_color
    self.count_rt > 0 ? 'primary' : 'muted'
  end

  #@tweet.is_liked?(current_user)
  #@tweet.unlike(current_user)
  #@tweet.like(current_user)

  def is_liked?(user)
    self.liking_users.include?(user)
  end

  def like(user)
    Like.create(user: user, tweet: self)
  end

  def remove_like(user)
    Like.where(user: user, tweet: self).destroy_all
  end
  def count_rt
    Tweet.where(rt_ref: self.id).count
  end
  def is_retweet?
    self.rt_ref.present?
  end

  def tweet_ref
    Tweet.find(self.rt_ref)
  end
end
