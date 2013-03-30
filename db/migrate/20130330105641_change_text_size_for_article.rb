class ChangeTextSizeForArticle < ActiveRecord::Migration
  def up
    change_column :articles, :text, :text, :limit => 65535*2
  end

  def down
    change_column :articles, :text, :text
  end
end
