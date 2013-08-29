class Novel < ActiveRecord::Base
  attr_accessible :name, :author, :description, :pic, :category_id, :article_num, :last_update, :is_serializing, :is_category_recommend, :is_category_hot, :is_category_this_week_hot, :is_classic, :is_classic_action, :is_show, :link
  belongs_to :category
  has_many :articles

  scope :show, where(:is_show => true)
end
