class Article < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :novel
end
