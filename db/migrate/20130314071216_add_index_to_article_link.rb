class AddIndexToArticleLink < ActiveRecord::Migration
  def change
    add_index :articles, :link
  end
end
