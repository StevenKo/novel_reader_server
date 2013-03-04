class Article < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :novel
  scope :by_id_desc, order('id DESC')
end
