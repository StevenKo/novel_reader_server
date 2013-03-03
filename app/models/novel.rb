class Novel < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :category
  has_many :articles
end
