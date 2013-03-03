# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130303035101) do

  create_table "articles", :force => true do |t|
    t.integer  "novel_id"
    t.text     "text"
    t.string   "link"
    t.string   "title"
    t.string   "subject"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "articles", ["novel_id"], :name => "index_articles_on_novel_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "link"
    t.string   "cat_link"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "hot_ships", :force => true do |t|
    t.integer  "novel_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "hot_ships", ["novel_id"], :name => "index_hot_ships_on_novel_id"

  create_table "novels", :force => true do |t|
    t.string   "name"
    t.string   "author"
    t.text     "description"
    t.string   "pic"
    t.integer  "category_id"
    t.string   "link"
    t.string   "article_num"
    t.string   "last_update"
    t.boolean  "is_serializing"
    t.boolean  "is_category_recommend"
    t.boolean  "is_category_hot"
    t.boolean  "is_category_this_week_hot"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "novels", ["category_id"], :name => "index_novels_on_category_id"

  create_table "this_month_hot_ships", :force => true do |t|
    t.integer  "novel_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "this_month_hot_ships", ["novel_id"], :name => "index_this_month_hot_ships_on_novel_id"

  create_table "this_week_hot_ships", :force => true do |t|
    t.integer  "novel_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "this_week_hot_ships", ["novel_id"], :name => "index_this_week_hot_ships_on_novel_id"

end
