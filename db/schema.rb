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

ActiveRecord::Schema.define(:version => 20140701070303) do

  create_table "admins", :force => true do |t|
    t.string   "password_digest"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "article_texts", :force => true do |t|
    t.text     "text",       :limit => 16777215
    t.integer  "article_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "article_texts", ["article_id"], :name => "index_article_texts_on_article_id"

  create_table "articles", :force => true do |t|
    t.integer  "novel_id"
    t.string   "link"
    t.string   "title"
    t.string   "subject"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "num",        :default => 0
    t.boolean  "is_show",    :default => true
  end

  add_index "articles", ["link"], :name => "index_articles_on_link"
  add_index "articles", ["novel_id"], :name => "index_articles_on_novel_id"
  add_index "articles", ["num"], :name => "index_articles_on_num"

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
    t.boolean  "is_classic"
    t.boolean  "is_classic_action"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "crawl_times",               :default => 0
    t.integer  "num",                       :default => 0
    t.boolean  "is_show",                   :default => true
  end

  add_index "novels", ["author"], :name => "index_novels_on_author"
  add_index "novels", ["category_id"], :name => "index_novels_on_category_id"
  add_index "novels", ["is_show"], :name => "index_novels_on_is_show"
  add_index "novels", ["name"], :name => "index_novels_on_name"
  add_index "novels", ["num"], :name => "index_novels_on_num"

  create_table "recommend_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "recommend_category_novel_ships", :force => true do |t|
    t.integer  "novel_id"
    t.integer  "recommend_category_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "recommend_category_novel_ships", ["novel_id"], :name => "index_recommend_category_novel_ships_on_novel_id"
  add_index "recommend_category_novel_ships", ["recommend_category_id"], :name => "index_recommend_category_novel_ships_on_recommend_category_id"

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

  create_table "users", :force => true do |t|
    t.string   "registration_id"
    t.text     "read_novels"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "device_id"
    t.text     "downloaded_novels"
    t.text     "collected_novels"
    t.string   "country"
    t.string   "platform"
    t.integer  "version"
  end

  add_index "users", ["device_id"], :name => "index_users_on_device_id"

end
