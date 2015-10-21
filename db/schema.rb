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

ActiveRecord::Schema.define(:version => 20150402074446) do

  create_table "a_addresses", :force => true do |t|
    t.integer  "user_id"
    t.string   "receiver"
    t.string   "mobile"
    t.string   "city"
    t.string   "address"
    t.boolean  "default"
    t.string   "id_name"
    t.string   "id_code"
    t.string   "id_logo1"
    t.string   "id_logo2"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "a_baokuans", :force => true do |t|
    t.integer  "a_product_id"
    t.datetime "begin_at"
    t.datetime "stop_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "a_order_details", :force => true do |t|
    t.integer  "a_order_id"
    t.integer  "a_product_id"
    t.float    "price"
    t.float    "o_price"
    t.integer  "count"
    t.float    "sum"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "a_orders", :force => true do |t|
    t.integer  "user_id"
    t.float    "price"
    t.float    "o_price"
    t.integer  "score_amount"
    t.integer  "redpacket_amount"
    t.integer  "red_packet_id"
    t.float    "payment"
    t.string   "paymethods"
    t.string   "status"
    t.string   "address"
    t.string   "receiver"
    t.string   "mobile"
    t.string   "post_code"
    t.string   "province"
    t.string   "city"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "a_payments", :force => true do |t|
    t.integer  "order_id"
    t.string   "trade_no"
    t.string   "buyer_id"
    t.string   "buyer_email"
    t.string   "subject"
    t.float    "price"
    t.string   "status"
    t.string   "seller_email"
    t.string   "notify_id"
    t.string   "use_coupon"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "acategories", :force => true do |t|
    t.string   "name"
    t.string   "logo"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "acomments", :force => true do |t|
    t.integer  "aproduct_id"
    t.integer  "user_id"
    t.string   "text"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "advertisement_logos", :force => true do |t|
    t.integer  "advertisement_id"
    t.string   "logo"
    t.string   "url",              :limit => 455
    t.string   "title"
    t.string   "remark"
    t.string   "status",           :limit => 100, :default => "online"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "advertisements", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "code"
    t.string   "size"
    t.integer  "num"
  end

  create_table "advs", :force => true do |t|
    t.string   "link",       :limit => 200
    t.string   "logo",       :limit => 200
    t.string   "desc",       :limit => 200
    t.integer  "price"
    t.integer  "tp"
    t.boolean  "hide",                      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "age_tags", :force => true do |t|
    t.integer  "age_id"
    t.integer  "tag_id"
    t.integer  "tp"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "week_count",     :default => 0
    t.integer  "total_count",    :default => 0
    t.text     "description"
    t.string   "summary"
    t.string   "logo"
    t.boolean  "is_index_hot",   :default => false
    t.string   "short_tag_name"
    t.boolean  "week_hot",       :default => false
  end

  add_index "age_tags", ["age_id", "tag_id", "tp"], :name => "index_age_tags_on_age_id_and_tag_id_and_tp", :unique => true

  create_table "ages", :force => true do |t|
    t.string  "name",           :limit => 30
    t.integer "posts_count",                   :default => 0
    t.integer "products_count",                :default => 0
    t.string  "angle_user_ids", :limit => 100
    t.string  "topic",          :limit => 400
  end

  create_table "album_books", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "logo"
    t.text     "content",       :limit => 2147483647
    t.integer  "template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "like_count",                          :default => 0
    t.integer  "comment_count",                       :default => 0
    t.text     "json_bak",      :limit => 2147483647
    t.integer  "kid_id"
    t.boolean  "recommand",                           :default => false
    t.string   "logo1"
    t.integer  "view_count",                          :default => 0
    t.boolean  "is_hide",                             :default => false
  end

  add_index "album_books", ["user_id"], :name => "user_id"

  create_table "album_comments", :force => true do |t|
    t.integer  "book_id"
    t.integer  "user_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "album_discount_codes", :force => true do |t|
    t.string   "code"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount",     :default => 5, :null => false
  end

  add_index "album_discount_codes", ["code"], :name => "code", :unique => true

  create_table "album_orders", :force => true do |t|
    t.integer  "book_id"
    t.integer  "user_id"
    t.string   "status"
    t.string   "address"
    t.string   "telephone"
    t.string   "linkname"
    t.string   "postcode"
    t.integer  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "book_count", :default => 1
    t.string   "kd"
    t.datetime "pay_at"
    t.string   "memo"
  end

  create_table "album_pages", :force => true do |t|
    t.integer  "user_id"
    t.string   "logo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "used",       :limit => 1
  end

  create_table "album_pictures", :force => true do |t|
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "album_template_pages", :force => true do |t|
    t.integer  "album_template_id"
    t.string   "logo_phone"
    t.string   "logo_print"
    t.text     "json"
    t.string   "status",            :default => "run"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "fm",                :default => false
    t.integer  "position",          :default => 1
  end

  create_table "album_templates", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
    t.string   "color"
    t.integer  "hide",       :limit => 1, :default => 0, :null => false
    t.integer  "position"
  end

  create_table "albums", :force => true do |t|
    t.string   "name"
    t.string   "logo"
    t.string   "content"
    t.integer  "tp",             :default => 0
    t.integer  "pictures_count", :default => 0
    t.integer  "comments_count", :default => 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "access",         :default => "public"
  end

  create_table "alogos", :force => true do |t|
    t.integer  "aproduct_id"
    t.string   "path"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "angle_comments", :force => true do |t|
    t.string   "content",       :limit => 210
    t.integer  "angle_post_id"
    t.integer  "user_id"
    t.datetime "created_at"
  end

  create_table "angle_posts", :force => true do |t|
    t.string   "content",              :limit => 210
    t.string   "logo",                 :limit => 50
    t.integer  "angle_comments_count",                :default => 0
    t.boolean  "is_hide",                             :default => false
    t.integer  "age_id"
    t.integer  "tag_id"
    t.integer  "user_id"
    t.datetime "created_at"
  end

  create_table "apicalls", :force => true do |t|
    t.string   "name"
    t.date     "occur"
    t.integer  "count",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apicalls", ["name", "occur"], :name => "NewIndex1", :unique => true

  create_table "apn_devices", :force => true do |t|
    t.integer  "user_id"
    t.string   "device_token"
    t.boolean  "active",                          :default => true
    t.string   "alias"
    t.integer  "tp"
    t.string   "parse_obj_id",     :limit => 200
    t.string   "parse_created_at", :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apn_devices", ["alias"], :name => "alias"
  add_index "apn_devices", ["device_token", "tp"], :name => "devicetoken_tp", :unique => true
  add_index "apn_devices", ["user_id"], :name => "user_id"

  create_table "apn_last_pages", :force => true do |t|
    t.integer  "tp"
    t.string   "page_url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "apn_messages", :force => true do |t|
    t.integer  "user_id"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tp",         :limit => 30
    t.string   "result",     :limit => 500
  end

  add_index "apn_messages", ["user_id"], :name => "user_id"

  create_table "app_genders", :force => true do |t|
    t.integer "qing",  :default => 0
    t.integer "titai", :default => 0
    t.integer "fuqi",  :default => 0
  end

  create_table "apple_comments", :force => true do |t|
    t.string   "name"
    t.integer  "score"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "apple_goods", :force => true do |t|
    t.string   "title"
    t.string   "name"
    t.string   "content"
    t.datetime "created_at", :null => false
    t.date     "occur"
    t.datetime "updated_at", :null => false
  end

  create_table "aproducts", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.string   "brand"
    t.string   "for_age"
    t.string   "logo"
    t.text     "introduce"
    t.float    "price"
    t.float    "o_price"
    t.string   "model"
    t.string   "weight",       :limit => 100
    t.string   "fee",          :limit => 100
    t.string   "from"
    t.string   "remark"
    t.text     "detail"
    t.text     "detail_draft"
    t.integer  "remain"
    t.integer  "sell_total",                  :default => 0
    t.integer  "sell_month",                  :default => 0
    t.integer  "sell_week",                   :default => 0
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "article_categories", :force => true do |t|
    t.string   "name",                       :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tp",          :default => 0
    t.integer  "parent_id"
  end

  create_table "article_comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "article_id"
    t.integer  "count",                     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content",    :limit => 210
  end

  create_table "article_contents", :force => true do |t|
    t.text     "content",    :limit => 16777215
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "article_contents", ["article_id"], :name => "index_article_contents_on_article_id", :unique => true
  add_index "article_contents", ["content"], :name => "index_article_contents_on_content"

  create_table "article_goods", :force => true do |t|
    t.integer  "user_id"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "article_tag_types", :force => true do |t|
    t.string "name"
  end

  create_table "article_tags", :force => true do |t|
    t.integer "article_tag_type_id"
    t.string  "name"
  end

  create_table "articles", :force => true do |t|
    t.string   "title",                                                    :null => false
    t.string   "title_"
    t.integer  "good_count",                            :default => 0
    t.integer  "view_count",                            :default => 0
    t.string   "state",                  :limit => 20,  :default => "未发布"
    t.string   "author",                 :limit => 100
    t.string   "origin_url"
    t.integer  "article_category_id"
    t.integer  "mms_user_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
    t.integer  "article_goods_count",                   :default => 0
    t.integer  "article_comments_count",                :default => 0
    t.integer  "gou_brand_article_id"
    t.integer  "gou_brand_story_id"
    t.string   "tags",                   :limit => 200
    t.string   "tuiguang_text"
    t.string   "tuiguang_url"
  end

  create_table "at_reminds", :force => true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "at_reminds", ["post_id", "user_id"], :name => "index_at_reminds_on_post_id_and_user_id", :unique => true
  add_index "at_reminds", ["post_id"], :name => "index_at_reminds_on_post_id"
  add_index "at_reminds", ["user_id"], :name => "index_at_reminds_on_user_id"

  create_table "baby_book_layouts", :force => true do |t|
    t.string   "name"
    t.text     "html"
    t.text     "css"
    t.text     "html_sandbox"
    t.text     "html_history"
    t.text     "css_sandbox"
    t.text     "css_history"
    t.integer  "is_publish"
    t.integer  "lock_version"
    t.integer  "tp",           :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "album_sina",   :default => false
  end

  create_table "baby_book_pages", :force => true do |t|
    t.string   "name",            :limit => 100
    t.string   "logo",            :limit => 50
    t.integer  "baby_book_id"
    t.integer  "position"
    t.text     "content"
    t.text     "content_history"
    t.integer  "layout_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "baby_book_pics", :force => true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.string   "logo",       :limit => 20
    t.datetime "created_at"
  end

  create_table "baby_book_texts", :force => true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.text     "content"
  end

  create_table "baby_book_themes", :force => true do |t|
    t.string   "name",        :limit => 20
    t.string   "description", :limit => 200
    t.integer  "tp"
    t.integer  "layout_tp",                  :default => 1
    t.datetime "created_at"
  end

  create_table "baby_book_votes", :force => true do |t|
    t.string   "ip",           :limit => 50
    t.integer  "vote_value",                 :default => 1
    t.integer  "user_id"
    t.integer  "baby_book_id"
    t.datetime "created_at"
  end

  create_table "baby_books", :force => true do |t|
    t.string   "name",                  :limit => 50
    t.integer  "user_id"
    t.boolean  "is_private",                           :default => false
    t.boolean  "is_finish",                            :default => false
    t.string   "author1",               :limit => 50
    t.string   "author2",               :limit => 50
    t.integer  "front_cover_page_id"
    t.integer  "back_cover_page_id"
    t.string   "thumb",                 :limit => 50
    t.integer  "baby_book_theme_id"
    t.string   "logo",                  :limit => 120
    t.integer  "baby_book_pages_count",                :default => 0
    t.datetime "created_at"
    t.boolean  "is_match",                             :default => false
    t.integer  "vote_count",                           :default => 0
    t.string   "mp3"
  end

  create_table "bafu_forms", :force => true do |t|
    t.string   "name"
    t.string   "name2"
    t.string   "name3"
    t.date     "birthday"
    t.string   "parent_name"
    t.string   "mobile"
    t.string   "kind"
    t.string   "desc"
    t.string   "born_at"
    t.string   "email"
    t.string   "target"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "baidu_apps", :force => true do |t|
    t.string  "app_name",       :limit => 100, :null => false
    t.string  "app_desc",       :limit => 200, :null => false
    t.string  "app_url",        :limit => 200, :null => false
    t.string  "app_action",     :limit => 100
    t.integer "ebook_topic_id"
    t.string  "image_url",      :limit => 100
  end

  create_table "bainians", :force => true do |t|
    t.integer  "user_id"
    t.string   "logo",       :limit => 200
    t.string   "role_name",  :limit => 200
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bainians", ["user_id"], :name => "index_bainians_on_user_id"

  create_table "balance_logs", :force => true do |t|
    t.integer  "user_id"
    t.string   "log"
    t.string   "payment"
    t.float    "cash",        :default => 0.0
    t.datetime "created_at"
    t.integer  "operator_id"
  end

  create_table "baomings", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "baomings", ["name"], :name => "index_baomings_on_name", :unique => true

  create_table "bbrl_reports", :force => true do |t|
    t.integer  "user_id"
    t.string   "user_name"
    t.string   "q1"
    t.string   "q2"
    t.string   "q3"
    t.string   "q4"
    t.string   "q5"
    t.string   "q6"
    t.string   "q7"
    t.string   "q8"
    t.string   "q9"
    t.string   "q10"
    t.string   "q11"
    t.string   "q12"
    t.string   "q13"
    t.string   "q14"
    t.string   "q15"
    t.string   "q16"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bbrl_stars", :force => true do |t|
    t.string   "tp",         :null => false
    t.integer  "user_id",    :null => false
    t.integer  "num",        :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bbrl_users", :force => true do |t|
    t.string   "app_id"
    t.string   "name"
    t.string   "address"
    t.string   "youbian"
    t.string   "mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bbrl_versions", :force => true do |t|
    t.string   "version"
    t.text     "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
  end

  create_table "bbrl_vips", :force => true do |t|
    t.integer  "user_id"
    t.string   "user_name"
    t.integer  "week_posts_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "best_follow_users", :force => true do |t|
    t.integer  "follow_user_id"
    t.integer  "user_id"
    t.integer  "order_num",      :default => 0
    t.datetime "created_at"
  end

  create_table "blacknames", :force => true do |t|
    t.string   "name"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blacknames", ["ip"], :name => "index_blacknames_on_ip", :unique => true

  create_table "blacksids", :force => true do |t|
    t.string   "sid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "blockcomments", :force => true do |t|
    t.integer  "user_id1"
    t.string   "user_name1"
    t.integer  "user_id2"
    t.string   "user_name2"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "blocknames", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "blockpublics", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "blockpublics", ["user_id"], :name => "user_id", :unique => true

  create_table "blockstars", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "blog_categories", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blog_urls", :force => true do |t|
    t.string  "url",     :limit => 250
    t.integer "user_id"
  end

  add_index "blog_urls", ["user_id"], :name => "index_blog_urls_on_user_id"

  create_table "book_contents", :force => true do |t|
    t.text     "content"
    t.integer  "book_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "book_malls", :force => true do |t|
    t.integer  "book_id"
    t.integer  "gou_site_id"
    t.string   "book_mall_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_number",  :default => -1
  end

  create_table "book_subjects", :force => true do |t|
    t.integer  "book_id"
    t.integer  "subject_id"
    t.integer  "subject_book_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "book_subjects", ["book_id"], :name => "index_book_subjects_on_book_id"
  add_index "book_subjects", ["subject_id"], :name => "index_book_subjects_on_subject_id"

  create_table "book_tags", :force => true do |t|
    t.integer  "book_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "book_tags", ["book_id", "tag_id"], :name => "index_book_tags_on_book_id_and_tag_id"
  add_index "book_tags", ["tag_id"], :name => "index_book_tags_on_tag_id"

  create_table "book_visits", :force => true do |t|
    t.integer  "book_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "books", :force => true do |t|
    t.string   "book_name"
    t.string   "book_site"
    t.string   "book_author"
    t.integer  "translator_id"
    t.string   "publishing_house"
    t.integer  "brand_id"
    t.string   "paperback"
    t.integer  "series_book_ids"
    t.text     "unite_recommend"
    t.text     "book_summary"
    t.text     "author_summary"
    t.text     "media_view"
    t.integer  "gou_site_id"
    t.string   "buy_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mms_user_id"
    t.integer  "user_id"
    t.string   "logo"
    t.integer  "view_count",       :default => 0
    t.integer  "good_count",       :default => 0
    t.integer  "comment_count",    :default => 0
    t.string   "state",            :default => "未发布"
    t.string   "book_pages"
    t.string   "translator"
    t.string   "series_book_name"
    t.string   "tag_names"
    t.string   "my_subjects"
    t.text     "book_active"
    t.string   "author_type"
  end

  add_index "books", ["book_name"], :name => "index_books_on_book_name"

  create_table "bse_applies", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "mobile"
    t.string   "age"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "calendar_advs", :force => true do |t|
    t.string   "name"
    t.string   "logo"
    t.integer  "tp"
    t.text     "url"
    t.text     "code"
    t.string   "status",     :default => "online"
    t.integer  "position",   :default => 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "only"
    t.string   "client"
  end

  create_table "calendar_tip_advs", :force => true do |t|
    t.string   "code"
    t.string   "logo_iphone"
    t.string   "logo_ipad"
    t.integer  "tp"
    t.text     "url"
    t.string   "status",      :default => "online"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "text"
    t.string   "only"
    t.string   "client"
  end

  create_table "categories", :force => true do |t|
    t.string  "name",        :limit => 20
    t.integer "posts_count",               :default => 0
  end

  create_table "cities", :force => true do |t|
    t.string  "name",        :limit => 50
    t.string  "post_code",   :limit => 20
    t.integer "province_id"
    t.float   "longitude"
    t.float   "latitude"
    t.float   "fright_fee",                :default => 10.0
  end

  add_index "cities", ["province_id"], :name => "index_cities_on_province_id"

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                                 :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 25
    t.string   "guid",              :limit => 10
    t.integer  "locale",            :limit => 1,  :default => 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "fk_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_assetable_type"
  add_index "ckeditor_assets", ["user_id"], :name => "fk_user"

  create_table "claps", :force => true do |t|
    t.integer  "user_id"
    t.integer  "tp_id"
    t.string   "tp",         :limit => 100
    t.datetime "created_at"
  end

  add_index "claps", ["tp_id"], :name => "index_claps_on_tp_id"
  add_index "claps", ["user_id"], :name => "user_id"

  create_table "column_author_applies", :force => true do |t|
    t.integer  "user_id"
    t.string   "real_name"
    t.string   "gender"
    t.string   "identity_type"
    t.string   "identity_id"
    t.string   "tel"
    t.string   "mobile"
    t.string   "blog"
    t.string   "weibo"
    t.string   "qq"
    t.string   "email"
    t.text     "plan_describe"
    t.string   "logo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

