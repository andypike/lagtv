class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :replay

  attr_accessible :text, :rating

  validates :text,      :presence => true
  validates :replay_id, :presence => true
  validates :user_id,   :presence => true

  validates_uniqueness_of :user_id, :scope => :replay_id, :message => "- You may only comment once on a replay."
end
