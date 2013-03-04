object @novel
attributes :id,:name,:author,:description,:pic,:category_id,:article_num,:last_update,:is_serializing


node(:category) { |novel| @novel.category}
node(:articles){|novel| @articles}