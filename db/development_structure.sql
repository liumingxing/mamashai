CREATE TABLE `age_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `age_id` int(11) DEFAULT NULL,
  `tag_id` int(11) DEFAULT NULL,
  `tp` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_age_tags_on_age_id_and_tag_id_and_tp` (`age_id`,`tag_id`,`tp`)
) ENGINE=InnoDB AUTO_INCREMENT=4822 DEFAULT CHARSET=utf8;

CREATE TABLE `ages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) DEFAULT NULL,
  `posts_count` int(11) DEFAULT '0',
  `products_count` int(11) DEFAULT '0',
  `angle_user_ids` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

CREATE TABLE `angle_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` varchar(210) DEFAULT NULL,
  `angle_post_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=306 DEFAULT CHARSET=utf8;

CREATE TABLE `angle_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` varchar(210) DEFAULT NULL,
  `logo` varchar(50) DEFAULT NULL,
  `angle_comments_count` int(11) DEFAULT '0',
  `is_hide` tinyint(1) DEFAULT '0',
  `age_id` int(11) DEFAULT NULL,
  `tag_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=256 DEFAULT CHARSET=utf8;

CREATE TABLE `article_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

CREATE TABLE `article_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `article_id` int(11) DEFAULT NULL,
  `count` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `content` varchar(210) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8;

CREATE TABLE `article_contents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` mediumtext,
  `article_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=utf8;

CREATE TABLE `article_goods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `article_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=368 DEFAULT CHARSET=utf8;

CREATE TABLE `articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `good_count` int(11) DEFAULT '0',
  `view_count` int(11) DEFAULT '0',
  `state` varchar(20) DEFAULT '未发布',
  `author` varchar(100) DEFAULT NULL,
  `origin_url` varchar(255) DEFAULT NULL,
  `article_category_id` int(11) DEFAULT NULL,
  `mms_user_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `article_goods_count` int(11) DEFAULT '0',
  `article_comments_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=utf8;

CREATE TABLE `baby_book_layouts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `html` text,
  `css` text,
  `html_sandbox` text,
  `html_history` text,
  `css_sandbox` text,
  `css_history` text,
  `is_publish` int(11) DEFAULT NULL,
  `lock_version` int(11) DEFAULT NULL,
  `tp` int(11) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8;

CREATE TABLE `baby_book_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `logo` varchar(50) DEFAULT NULL,
  `baby_book_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `content` text,
  `content_history` text,
  `layout_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10767 DEFAULT CHARSET=utf8;

CREATE TABLE `baby_book_pics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `logo` varchar(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28583 DEFAULT CHARSET=utf8;

CREATE TABLE `baby_book_texts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `content` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18980 DEFAULT CHARSET=utf8;

CREATE TABLE `baby_book_themes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `description` varchar(200) DEFAULT NULL,
  `tp` int(11) DEFAULT NULL,
  `layout_tp` int(11) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

CREATE TABLE `baby_book_votes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip` varchar(50) DEFAULT NULL,
  `vote_value` int(11) DEFAULT '1',
  `user_id` int(11) DEFAULT NULL,
  `baby_book_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26101 DEFAULT CHARSET=utf8;

CREATE TABLE `baby_books` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `is_private` tinyint(1) DEFAULT '0',
  `is_finish` tinyint(1) DEFAULT '0',
  `author1` varchar(50) DEFAULT NULL,
  `author2` varchar(50) DEFAULT NULL,
  `front_cover_page_id` int(11) DEFAULT NULL,
  `back_cover_page_id` int(11) DEFAULT NULL,
  `thumb` varchar(50) DEFAULT NULL,
  `baby_book_theme_id` int(11) DEFAULT NULL,
  `logo` varchar(20) DEFAULT NULL,
  `baby_book_pages_count` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `is_match` tinyint(1) DEFAULT '0',
  `vote_count` int(11) DEFAULT '0',
  `mp3` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1020 DEFAULT CHARSET=utf8;

CREATE TABLE `balance_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `log` varchar(255) DEFAULT NULL,
  `payment` varchar(255) DEFAULT NULL,
  `cash` float DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `operator_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8721 DEFAULT CHARSET=utf8;

CREATE TABLE `best_follow_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `follow_user_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `order_num` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=331 DEFAULT CHARSET=utf8;

CREATE TABLE `blog_urls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(250) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_blog_urls_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7351 DEFAULT CHARSET=utf8;

CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `posts_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

CREATE TABLE `cities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `post_code` varchar(20) DEFAULT NULL,
  `province_id` int(11) DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cities_on_province_id` (`province_id`)
) ENGINE=InnoDB AUTO_INCREMENT=798 DEFAULT CHARSET=utf8;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` varchar(210) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `post_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `rate` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_comments_on_post_id` (`post_id`),
  KEY `index_comments_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=50011 DEFAULT CHARSET=utf8;

CREATE TABLE `copy_user_signups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(35) DEFAULT NULL,
  `password` varchar(35) DEFAULT NULL,
  `password_reset` varchar(35) DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `kid_gender1` varchar(2) DEFAULT NULL,
  `kid_gender2` varchar(2) DEFAULT NULL,
  `kid_gender3` varchar(2) DEFAULT NULL,
  `kid_birthday1` datetime DEFAULT NULL,
  `kid_birthday2` datetime DEFAULT NULL,
  `kid_birthday3` datetime DEFAULT NULL,
  `kid_birthday4` datetime DEFAULT NULL,
  `kids_count` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `invite_user_id` int(11) DEFAULT NULL,
  `is_hide_age` tinyint(1) DEFAULT '0',
  `org_tps` varchar(50) DEFAULT NULL,
  `org_name` varchar(50) DEFAULT NULL,
  `age_ids` varchar(20) DEFAULT '',
  `name` varchar(50) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `idcard` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10529 DEFAULT CHARSET=utf8;

CREATE TABLE `coupons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sid` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `money` decimal(8,2) DEFAULT NULL,
  `limit_time` datetime DEFAULT NULL,
  `tp` int(11) DEFAULT '0',
  `score` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `day_keyword_signups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `signups_count` int(11) DEFAULT '0',
  `keyword_signup_id` int(11) DEFAULT NULL,
  `day` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=459 DEFAULT CHARSET=utf8;

CREATE TABLE `eproduct_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `eproducts_count` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `eproduct_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `eproducts_count` int(11) DEFAULT '0',
  `eproduct_category_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;

CREATE TABLE `eproducts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `content` text,
  `logo` varchar(100) DEFAULT NULL,
  `site_name` varchar(200) DEFAULT NULL,
  `link` varchar(200) DEFAULT NULL,
  `click_count` int(11) DEFAULT '0',
  `user_id` int(11) DEFAULT NULL,
  `post_id` int(11) DEFAULT NULL,
  `tp` int(11) DEFAULT NULL,
  `eproduct_category_id` int(11) DEFAULT NULL,
  `eproduct_tag_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `price` float DEFAULT NULL,
  `rate` int(11) DEFAULT NULL,
  `brand` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_eproducts_on_user_id` (`user_id`),
  KEY `index_eproducts_on_post_id` (`post_id`),
  KEY `index_eproducts_on_eproduct_tag_id` (`eproduct_tag_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2537 DEFAULT CHARSET=utf8;

CREATE TABLE `event_baby_plans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tags` varchar(300) DEFAULT NULL,
  `tag` varchar(50) DEFAULT NULL,
  `user_name` varchar(50) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `begin_at` date DEFAULT NULL,
  `end_at` date DEFAULT NULL,
  `start_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

CREATE TABLE `event_fee_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `fee1` float DEFAULT '0',
  `fee2` float DEFAULT '0',
  `fee3` float DEFAULT '0',
  `event_fee_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `event_fees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `total_fee1` float DEFAULT '0',
  `total_fee2` float DEFAULT '0',
  `total_fee3` float DEFAULT '0',
  `fee_remark` varchar(1000) DEFAULT NULL,
  `is_unopen` tinyint(1) DEFAULT '0',
  `boolean` tinyint(1) DEFAULT '0',
  `event_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_event_fees_on_event_id` (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `event_name_sticks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kid_name` varchar(50) DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `father` varchar(255) DEFAULT NULL,
  `mother` varchar(255) DEFAULT NULL,
  `mobile` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `post` varchar(255) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `is_sended` int(11) DEFAULT '0',
  `event_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3175 DEFAULT CHARSET=utf8;

CREATE TABLE `event_pays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `pay_money` float DEFAULT '0',
  `pay_users_count` int(11) DEFAULT '1',
  `real_name` varchar(20) DEFAULT NULL,
  `pay_names` varchar(1000) DEFAULT NULL,
  `note` varchar(1000) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `pay_user_ids` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

CREATE TABLE `event_pictures` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `logo` varchar(50) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_event_pictures_on_event_id` (`event_id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8;

CREATE TABLE `event_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `events_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_event_tags_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

CREATE TABLE `event_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `tp` int(11) DEFAULT '0',
  `join_num` int(11) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `email` varchar(30) DEFAULT NULL,
  `remark` varchar(150) DEFAULT NULL,
  `note` varchar(150) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `real_name` varchar(255) DEFAULT NULL,
  `is_pay` tinyint(1) DEFAULT '0',
  `city` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_event_users_on_event_id` (`event_id`),
  KEY `index_event_users_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=277 DEFAULT CHARSET=utf8;

CREATE TABLE `events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) DEFAULT NULL,
  `event_tag_id` int(11) DEFAULT NULL,
  `province_id` int(11) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT '0',
  `location` varchar(80) DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `age_ids` varchar(100) DEFAULT NULL,
  `pay_fee` int(11) DEFAULT NULL,
  `limit_num` int(11) DEFAULT NULL,
  `posts_count` int(11) DEFAULT '0',
  `event_users_count` int(11) DEFAULT '0',
  `join_users_count` int(11) DEFAULT '0',
  `event_pictures_count` int(11) DEFAULT '0',
  `integer` int(11) DEFAULT '0',
  `content` text,
  `cancel_reason` varchar(200) DEFAULT NULL,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `spot_id` int(11) DEFAULT NULL,
  `post_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `event_users_sum` int(11) DEFAULT '0',
  `summary` text,
  PRIMARY KEY (`id`),
  KEY `index_events_on_start_at` (`start_at`),
  KEY `index_events_on_province_id` (`province_id`),
  KEY `index_events_on_city_id` (`city_id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8;

CREATE TABLE `fans_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `users_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=123 DEFAULT CHARSET=utf8;

CREATE TABLE `favorite_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `content` varchar(210) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_favorite_posts_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1466 DEFAULT CHARSET=utf8;

CREATE TABLE `favorite_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_favorite_tags_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=373 DEFAULT CHARSET=utf8;

CREATE TABLE `favorite_tuans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tuan_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `content` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8;

CREATE TABLE `follow_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `follow_user_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `remark` varchar(50) DEFAULT NULL,
  `is_fans` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `fans_remark` varchar(50) DEFAULT NULL,
  `nick_name` varchar(50) DEFAULT NULL,
  `fans_nick_name` varchar(50) DEFAULT NULL,
  `follows_group_id` int(11) DEFAULT NULL,
  `fans_group_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_follow_users_on_user_id` (`user_id`),
  KEY `follow_user_id` (`follow_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=451183 DEFAULT CHARSET=utf8;

CREATE TABLE `follows_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `users_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=150 DEFAULT CHARSET=utf8;

CREATE TABLE `games_lianliankan_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `games_lianliankan_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `cost_time` time DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `games_lianliankans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `info` text,
  `logo` varchar(200) DEFAULT NULL,
  `players_count` int(11) DEFAULT '0',
  `users_count` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `gift_gets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gift_id` int(11) DEFAULT NULL,
  `send_user_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `is_no_name` tinyint(1) DEFAULT '0',
  `is_private` tinyint(1) DEFAULT '0',
  `is_send_hide` tinyint(1) DEFAULT '0',
  `is_get_hide` tinyint(1) DEFAULT '0',
  `content` varchar(210) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gift_gets_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1650 DEFAULT CHARSET=utf8;

CREATE TABLE `gifts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `logo` varchar(50) DEFAULT NULL,
  `gift_gets_count` int(11) DEFAULT '0',
  `score` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8;

CREATE TABLE `hot_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `posts_count` int(11) DEFAULT '0',
  `days` int(11) DEFAULT NULL,
  `tag_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4305 DEFAULT CHARSET=utf8;

CREATE TABLE `http_refers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `link` varchar(500) DEFAULT NULL,
  `http_refer` varchar(1000) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20100 DEFAULT CHARSET=utf8;

CREATE TABLE `industries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) DEFAULT NULL,
  `users_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8;

CREATE TABLE `invite_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(35) DEFAULT NULL,
  `invite_code` varchar(10) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `signuped_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2533 DEFAULT CHARSET=utf8;

CREATE TABLE `keyword_signups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `hits_count` int(11) DEFAULT '0',
  `signups_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=158 DEFAULT CHARSET=utf8;

CREATE TABLE `link_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

CREATE TABLE `link_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `link_category_id` int(11) DEFAULT NULL,
  `order_num` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;

CREATE TABLE `logged_exceptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `exception_class` varchar(255) DEFAULT NULL,
  `controller_name` varchar(255) DEFAULT NULL,
  `action_name` varchar(255) DEFAULT NULL,
  `message` text,
  `backtrace` text,
  `environment` text,
  `request` text,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

CREATE TABLE `long_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` text,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9126 DEFAULT CHARSET=utf8;

CREATE TABLE `message_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` varchar(500) DEFAULT NULL,
  `message_topic_id` int(11) DEFAULT NULL,
  `message_user_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_message_posts_on_message_topic_id` (`message_topic_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27353 DEFAULT CHARSET=utf8;

CREATE TABLE `message_topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_posts_count` int(11) DEFAULT '0',
  `last_message_post_id` int(11) DEFAULT NULL,
  `message_user_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `is_sys` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_message_topics_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14831 DEFAULT CHARSET=utf8;

CREATE TABLE `mms_amount_event_hits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_name` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `begin_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

CREATE TABLE `mms_amount_event_refers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mms_amount_event_hit_id` int(11) DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `http_refer` varchar(255) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3226 DEFAULT CHARSET=utf8;

CREATE TABLE `mms_apps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `logo` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `content` text,
  `icon` varchar(255) DEFAULT NULL,
  `is_system_components` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT '0',
  `sub_link_name` varchar(255) DEFAULT NULL,
  `sub_link` varchar(255) DEFAULT NULL,
  `default_position` int(11) DEFAULT NULL,
  `user_apps_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

CREATE TABLE `mms_award_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mms_event_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `award_date` date DEFAULT NULL,
  `award_type` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;

CREATE TABLE `mms_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) DEFAULT NULL,
  `content` text,
  `send_time` datetime DEFAULT NULL,
  `seccessed_account` int(11) DEFAULT NULL,
  `failed_account` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `flag` varchar(255) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `send_count` int(11) DEFAULT NULL,
  `line_numbers` int(11) DEFAULT NULL,
  `test_address` text,
  `send_interval` int(11) DEFAULT '1',
  `ignore_email_type` varchar(255) DEFAULT NULL,
  `email_server_type` varchar(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

CREATE TABLE `mms_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `state` tinyint(4) DEFAULT '0',
  `begin_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

CREATE TABLE `mms_tools` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `content` text,
  `users_count` int(11) DEFAULT '0',
  `logo` varchar(255) DEFAULT NULL,
  `pdf` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

CREATE TABLE `mms_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `power` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;

CREATE TABLE `name_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(500) DEFAULT NULL,
  `value` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

CREATE TABLE `order_addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `province_id` int(11) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `post_code` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `mobile` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `memo` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `order_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) DEFAULT NULL,
  `product_code` varchar(255) DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `product_state` int(11) DEFAULT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `price` float DEFAULT NULL,
  `order_price` float DEFAULT NULL,
  `discount` float DEFAULT NULL,
  `memo` text,
  `order_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `item_type` varchar(255) DEFAULT NULL,
  `product_weight` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8092 DEFAULT CHARSET=utf8;

CREATE TABLE `order_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `log` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `tp` int(11) DEFAULT '0',
  `user_name` varchar(255) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8495 DEFAULT CHARSET=utf8;

CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(255) DEFAULT NULL,
  `lock_version` int(11) DEFAULT NULL,
  `info` text,
  `total_money` float DEFAULT NULL,
  `fright_money` float DEFAULT NULL,
  `total_item_money` float DEFAULT NULL,
  `favorable_money` float DEFAULT NULL,
  `payment_info` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `express_company` varchar(255) DEFAULT NULL,
  `express_order_id` varchar(255) DEFAULT NULL,
  `express_at` datetime DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `using_balance` float DEFAULT '0',
  `receiver_name` varchar(255) DEFAULT NULL,
  `receiver_address` varchar(255) DEFAULT NULL,
  `receiver_mobile` varchar(255) DEFAULT NULL,
  `coupon_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8073 DEFAULT CHARSET=utf8;

CREATE TABLE `org_branches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8;

CREATE TABLE `org_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tps` varchar(50) DEFAULT NULL,
  `goal` varchar(300) DEFAULT NULL,
  `content` varchar(300) DEFAULT NULL,
  `blog_url` varchar(200) DEFAULT NULL,
  `contact` varchar(25) DEFAULT NULL,
  `qq` varchar(50) DEFAULT NULL,
  `tel` varchar(50) DEFAULT NULL,
  `mobile` varchar(50) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `msn` varchar(50) DEFAULT NULL,
  `wangwang` varchar(50) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8;

CREATE TABLE `picture_editors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `logo` varchar(50) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `mms_user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=365 DEFAULT CHARSET=utf8;

CREATE TABLE `post_rates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rate` int(11) DEFAULT NULL,
  `post_id` int(11) DEFAULT NULL,
  `post_user_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_post_rates_on_post_id` (`post_id`),
  KEY `index_post_rates_on_post_user_id` (`post_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=456 DEFAULT CHARSET=utf8;

CREATE TABLE `post_recommends` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` varchar(210) DEFAULT NULL,
  `post_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` varchar(210) DEFAULT NULL,
  `logo` varchar(50) DEFAULT NULL,
  `video_url_id` int(11) DEFAULT NULL,
  `blog_url_id` int(11) DEFAULT NULL,
  `gift_id` int(11) DEFAULT NULL,
  `mobile_tp` int(11) DEFAULT NULL,
  `forward_posts_count` int(11) DEFAULT '0',
  `favorite_posts_count` int(11) DEFAULT '0',
  `comments_count` int(11) DEFAULT '0',
  `is_hide` tinyint(1) DEFAULT '0',
  `score` int(11) DEFAULT NULL,
  `forward_post_id` int(11) DEFAULT NULL,
  `forward_user_id` int(11) DEFAULT NULL,
  `best_answer_id` int(11) DEFAULT NULL,
  `age_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `tag_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `rate` float DEFAULT '0',
  `post_rates_count` int(11) DEFAULT '0',
  `long_post_id` int(11) DEFAULT NULL,
  `post_recommends_count` int(11) DEFAULT '0',
  `spot_id` int(11) DEFAULT NULL,
  `tp` int(11) DEFAULT '0',
  `title` varchar(100) DEFAULT NULL,
  `new_title` varchar(150) DEFAULT NULL,
  `new_title_user_id` int(11) DEFAULT NULL,
  `expert_user_id` int(11) DEFAULT NULL,
  `is_book` tinyint(1) DEFAULT '0',
  `id_139` int(11) DEFAULT NULL,
  `subject_id` int(11) DEFAULT NULL,
  `eproduct_id` int(11) DEFAULT NULL,
  `post_rate` int(11) DEFAULT NULL,
  `rates_count` int(11) DEFAULT '0',
  `tuan_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_posts_on_user_id` (`user_id`),
  KEY `index_posts_on_age_id` (`age_id`),
  KEY `index_posts_on_created_at` (`created_at`),
  KEY `index_posts_on_category_id` (`category_id`),
  KEY `is_hide` (`is_hide`),
  KEY `tag_id` (`tag_id`),
  KEY `tp` (`tp`),
  KEY `title` (`title`),
  KEY `forward_post_id` (`forward_post_id`),
  KEY `forward_user_id` (`forward_user_id`),
  KEY `index_post_on_muti_key` (`id`,`user_id`,`forward_user_id`,`age_id`,`tag_id`,`blog_url_id`,`is_hide`,`spot_id`,`eproduct_id`,`comments_count`)
) ENGINE=InnoDB AUTO_INCREMENT=96973 DEFAULT CHARSET=utf8;

CREATE TABLE `product_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shop_product_id` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_product_orders_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `price` float DEFAULT NULL,
  `discount` float DEFAULT '1',
  `desc` text,
  `desc_history` text,
  `intro` varchar(255) DEFAULT NULL,
  `intro_history` text,
  `thumb` varchar(255) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `has_attachment` tinyint(1) DEFAULT NULL,
  `cond` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `weight` int(11) DEFAULT NULL,
  `preferential` float DEFAULT NULL,
  `cost` float DEFAULT NULL,
  `requirement` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_products_on_name` (`name`),
  UNIQUE KEY `index_products_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

CREATE TABLE `provinces` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `post_code` varchar(20) DEFAULT NULL,
  `users_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `score_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event` varchar(30) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `tag_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `total_score` int(11) DEFAULT NULL,
  `post_id` int(11) DEFAULT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_score_events_on_user_id` (`user_id`),
  KEY `index_score_events_on_tag_id` (`tag_id`)
) ENGINE=InnoDB AUTO_INCREMENT=648069 DEFAULT CHARSET=utf8;

CREATE TABLE `score_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `score` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `shop_products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `url` varchar(200) DEFAULT NULL,
  `content` varchar(300) DEFAULT NULL,
  `price` float DEFAULT NULL,
  `money_back` float DEFAULT NULL,
  `discount` float DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_shop_products_on_shop_id` (`shop_id`),
  KEY `index_shop_products_on_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `shopping_carts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `shopping_items` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8;

CREATE TABLE `shops` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `url` varchar(200) DEFAULT NULL,
  `logo` varchar(50) DEFAULT NULL,
  `description` varchar(50) DEFAULT NULL,
  `content` varchar(500) DEFAULT NULL,
  `discount_policy` varchar(500) DEFAULT NULL,
  `deliver_policy` varchar(50) DEFAULT NULL,
  `note` varchar(500) DEFAULT NULL,
  `discount` float DEFAULT NULL,
  `shop_products_count` int(11) DEFAULT '0',
  `view_count` int(11) DEFAULT '0',
  `posts_count` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_shops_on_shop_products_count` (`shop_products_count`),
  KEY `index_shops_on_posts_count` (`posts_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sms_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sid` varchar(20) DEFAULT NULL,
  `sno` varchar(20) DEFAULT NULL,
  `stxt` varchar(210) DEFAULT NULL,
  `stime` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `post_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=271 DEFAULT CHARSET=utf8;

CREATE TABLE `spot_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `spots_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_spot_tags_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

CREATE TABLE `spots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `province_id` int(11) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `spot_tag_id` int(11) DEFAULT NULL,
  `location` varchar(300) DEFAULT NULL,
  `tp` int(11) DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `post_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_hide` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_spots_on_province_id` (`province_id`),
  KEY `index_spots_on_city_id` (`city_id`),
  KEY `index_spots_on_spot_tag_id` (`spot_tag_id`),
  KEY `index_spots_on_post_id` (`post_id`),
  KEY `index_spots_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=225 DEFAULT CHARSET=utf8;

CREATE TABLE `subject_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `subject_posts_count` int(11) DEFAULT '0',
  `week_subject_posts_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1777 DEFAULT CHARSET=utf8;

CREATE TABLE `subjects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) DEFAULT NULL,
  `content` varchar(1500) DEFAULT NULL,
  `logo` varchar(150) DEFAULT NULL,
  `posts_count` int(11) DEFAULT '0',
  `subject_users_count` int(11) DEFAULT '0',
  `tp` int(11) DEFAULT '0',
  `is_good` tinyint(1) DEFAULT '0',
  `user_id` int(11) DEFAULT NULL,
  `subject_category_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deputy_user_id` int(11) DEFAULT NULL,
  `topic` text,
  `banner` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_subjects_on_deputy_user_id` (`deputy_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=124 DEFAULT CHARSET=utf8;

CREATE TABLE `sys_job_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sys_job_name` varchar(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `finished_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2991 DEFAULT CHARSET=utf8;

CREATE TABLE `sys_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) DEFAULT NULL,
  `url` varchar(200) DEFAULT NULL,
  `link_category_id` int(11) DEFAULT NULL,
  `link_tag_id` int(11) DEFAULT NULL,
  `order_num` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sys_links_on_order_num` (`order_num`),
  KEY `index_sys_links_on_link_category_id` (`link_category_id`),
  KEY `index_sys_links_on_link_tag_id` (`link_tag_id`)
) ENGINE=InnoDB AUTO_INCREMENT=249 DEFAULT CHARSET=utf8;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `posts_count` int(11) DEFAULT '0',
  `category_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tags_on_posts_count` (`posts_count`),
  KEY `index_tags_on_category_id` (`category_id`),
  KEY `index_tags_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2827 DEFAULT CHARSET=utf8;

CREATE TABLE `tmp_purchase_infos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `amount` int(11) DEFAULT NULL,
  `money` varchar(255) DEFAULT NULL,
  `pay_person` varchar(255) DEFAULT NULL,
  `receive_person` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `postcode` varchar(255) DEFAULT NULL,
  `mobile` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `memo` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

CREATE TABLE `tuan_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `tuans_count` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

CREATE TABLE `tuan_category_temps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `tuan_category_id` int(11) DEFAULT NULL,
  `tuans_count` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;

CREATE TABLE `tuan_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` varchar(210) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `tuan_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `rate` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=247 DEFAULT CHARSET=utf8;

CREATE TABLE `tuan_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` varchar(255) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tuan_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1291 DEFAULT CHARSET=utf8;

CREATE TABLE `tuan_temps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tuan_website_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `url` varchar(250) DEFAULT NULL,
  `logo` varchar(150) DEFAULT NULL,
  `begin_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `person_amount` int(11) DEFAULT NULL,
  `content` text,
  `origin_price` float DEFAULT NULL,
  `current_price` float DEFAULT NULL,
  `discount` float DEFAULT NULL,
  `save_money` float DEFAULT NULL,
  `tid` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `lng` float DEFAULT NULL,
  `lat` float DEFAULT NULL,
  `passed` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `tuan_websites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `url` varchar(150) DEFAULT NULL,
  `tuans_count` int(11) DEFAULT '0',
  `open_at` datetime DEFAULT NULL,
  `average_hot_count` int(11) DEFAULT '0',
  `average_rate` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `catch_url` varchar(255) DEFAULT NULL,
  `catch_config` text,
  `tuan_temps_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=136 DEFAULT CHARSET=utf8;

CREATE TABLE `tuans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tuan_website_id` int(11) DEFAULT NULL,
  `tuan_category_id` int(11) DEFAULT NULL,
  `address` varchar(250) DEFAULT NULL,
  `url` varchar(250) DEFAULT NULL,
  `logo` varchar(100) DEFAULT NULL,
  `begin_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `person_amount` int(11) DEFAULT NULL,
  `content` text,
  `title` varchar(200) DEFAULT NULL,
  `origin_price` float DEFAULT NULL,
  `current_price` float DEFAULT NULL,
  `discount` float DEFAULT NULL,
  `save_money` float DEFAULT NULL,
  `hits_count` int(11) DEFAULT '0',
  `buyers_count` int(11) DEFAULT '0',
  `tuan_comments_count` int(11) DEFAULT '0',
  `province_id` int(11) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `rate` int(11) DEFAULT '0',
  `rates_count` int(11) DEFAULT '0',
  `favorite_tuans_count` int(11) DEFAULT '0',
  `forward_posts_count` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lng` varchar(255) DEFAULT NULL,
  `lat` varchar(255) DEFAULT NULL,
  `tid` varchar(255) DEFAULT NULL,
  `tp` int(11) DEFAULT '0',
  `back_money` float DEFAULT '0',
  `fright_money` float DEFAULT '0',
  `free_fright_amount` int(11) DEFAULT NULL,
  `introduction` text,
  `sale_count` int(11) DEFAULT '0',
  `level` int(11) DEFAULT '0',
  `tuan_category_temp_id` int(11) DEFAULT NULL,
  `current_key` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=463 DEFAULT CHARSET=utf8;

CREATE TABLE `user_apps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `mms_app_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=129993 DEFAULT CHARSET=utf8;

CREATE TABLE `user_blogs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `blog_tp` varchar(20) DEFAULT NULL,
  `blog_name` varchar(200) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_blogs_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1083 DEFAULT CHARSET=utf8;

CREATE TABLE `user_book_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` varchar(1000) DEFAULT NULL,
  `logo` varchar(50) DEFAULT NULL,
  `img_title` varchar(100) DEFAULT NULL,
  `page_num` int(11) DEFAULT '0',
  `layout` int(11) DEFAULT '1',
  `post_id` int(11) DEFAULT NULL,
  `user_book_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `content1` varchar(230) DEFAULT NULL,
  `content2` varchar(230) DEFAULT NULL,
  `content3` varchar(230) DEFAULT NULL,
  `post1_id` int(11) DEFAULT NULL,
  `post2_id` int(11) DEFAULT NULL,
  `post3_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_book_pages_on_page_num` (`page_num`),
  KEY `index_user_book_pages_on_user_book_id` (`user_book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7916 DEFAULT CHARSET=utf8;

CREATE TABLE `user_books` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(30) DEFAULT NULL,
  `title_style` varchar(200) DEFAULT NULL,
  `author1` varchar(20) DEFAULT NULL,
  `author2` varchar(20) DEFAULT NULL,
  `file` varchar(50) DEFAULT NULL,
  `logo` varchar(50) DEFAULT NULL,
  `posts_order` varchar(60) DEFAULT NULL,
  `mx_post_id` int(11) DEFAULT '0',
  `layout` int(11) DEFAULT '1',
  `skin` int(11) DEFAULT '1',
  `user_book_pages_count` int(11) DEFAULT '0',
  `user_book_page_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `user_order_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_books_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=333 DEFAULT CHARSET=utf8;

CREATE TABLE `user_email_crpas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17145 DEFAULT CHARSET=utf8;

CREATE TABLE `user_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=105285 DEFAULT CHARSET=utf8;

CREATE TABLE `user_kids` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `logo` varchar(50) DEFAULT NULL,
  `gender` varchar(2) DEFAULT NULL,
  `education` varchar(20) DEFAULT NULL,
  `education_org` varchar(200) DEFAULT NULL,
  `content` varchar(210) DEFAULT NULL,
  `star` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_kids_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10868 DEFAULT CHARSET=utf8;

CREATE TABLE `user_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) DEFAULT NULL,
  `url` varchar(200) DEFAULT NULL,
  `link_category_id` int(11) DEFAULT NULL,
  `order_num` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `sys_link_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_links_on_order_num` (`order_num`),
  KEY `index_user_links_on_link_category_id` (`link_category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=154 DEFAULT CHARSET=utf8;

CREATE TABLE `user_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_no` varchar(20) DEFAULT NULL,
  `order_tp` varchar(15) DEFAULT NULL,
  `owner_name` varchar(20) DEFAULT NULL,
  `owner_mobile` varchar(20) DEFAULT NULL,
  `address` varchar(80) DEFAULT NULL,
  `post_code` varchar(10) DEFAULT NULL,
  `contact_name` varchar(20) DEFAULT NULL,
  `contact_mobile` varchar(20) DEFAULT NULL,
  `contact_email` varchar(35) DEFAULT NULL,
  `contact_tel` varchar(20) DEFAULT NULL,
  `contact_tel_pre` varchar(5) DEFAULT NULL,
  `contact_tel_post` varchar(5) DEFAULT NULL,
  `contact_fax` varchar(20) DEFAULT NULL,
  `note` varchar(500) DEFAULT NULL,
  `province_id` int(11) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `money` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_orders_on_order_no` (`order_no`)
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8;

CREATE TABLE `user_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pub_infos` varchar(20) DEFAULT NULL,
  `real_name` varchar(50) DEFAULT NULL,
  `idcard` varchar(50) DEFAULT NULL,
  `school` varchar(50) DEFAULT NULL,
  `content` varchar(120) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `score_actions` varchar(300) DEFAULT NULL,
  `rand_code` varchar(10) DEFAULT NULL,
  `bind_mobile` varchar(20) DEFAULT NULL,
  `notify_ignores` varchar(100) DEFAULT '',
  `user_actions` varchar(100) DEFAULT '',
  `uuid` varchar(50) DEFAULT NULL,
  `password_reset` varchar(35) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21654 DEFAULT CHARSET=utf8;

CREATE TABLE `user_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(100) DEFAULT NULL,
  `content` varchar(1000) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

CREATE TABLE `user_rewards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reward` varchar(30) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `get_reward_at` date DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `is_readed` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_user_rewards_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=252 DEFAULT CHARSET=utf8;

CREATE TABLE `user_score_statistic_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `user_score_statistics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `user_score_statistic_config_id` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_score_statistics_on_user_id` (`user_id`),
  KEY `index_user_score_statistics_on_user_score_statistic_config_id` (`user_score_statistic_config_id`),
  KEY `index_user_score_statistics_on_score` (`score`)
) ENGINE=InnoDB AUTO_INCREMENT=8864 DEFAULT CHARSET=utf8;

CREATE TABLE `user_signups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(35) DEFAULT NULL,
  `password` varchar(35) DEFAULT NULL,
  `password_reset` varchar(35) DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `kid_gender1` varchar(2) DEFAULT NULL,
  `kid_gender2` varchar(2) DEFAULT NULL,
  `kid_gender3` varchar(2) DEFAULT NULL,
  `kid_birthday1` datetime DEFAULT NULL,
  `kid_birthday2` datetime DEFAULT NULL,
  `kid_birthday3` datetime DEFAULT NULL,
  `kid_birthday4` datetime DEFAULT NULL,
  `kids_count` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `invite_user_id` int(11) DEFAULT NULL,
  `is_hide_age` tinyint(1) DEFAULT '0',
  `org_tps` varchar(50) DEFAULT NULL,
  `org_name` varchar(50) DEFAULT NULL,
  `age_ids` varchar(20) DEFAULT '',
  `name` varchar(50) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `idcard` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(35) DEFAULT NULL,
  `password` varchar(35) DEFAULT NULL,
  `logo` varchar(20) DEFAULT NULL,
  `name` varchar(25) DEFAULT NULL,
  `domain` varchar(25) DEFAULT NULL,
  `gender` varchar(2) DEFAULT NULL,
  `birthyear` int(11) DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `job_title` varchar(50) DEFAULT NULL,
  `msn` varchar(30) DEFAULT NULL,
  `qq` varchar(20) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `age_ids` varchar(20) DEFAULT '',
  `tag_ids` varchar(200) DEFAULT NULL,
  `tp` int(11) DEFAULT '0',
  `score` int(11) DEFAULT '0',
  `skin` int(11) DEFAULT '1',
  `user_kids_count` int(11) DEFAULT '0',
  `follow_users_count` int(11) DEFAULT '0',
  `fans_users_count` int(11) DEFAULT '0',
  `posts_count` int(11) DEFAULT '0',
  `unread_fans_count` int(11) DEFAULT '0',
  `unread_comments_count` int(11) DEFAULT '0',
  `unread_answers_count` int(11) DEFAULT '0',
  `unread_messages_count` int(11) DEFAULT '0',
  `unread_gifts_count` int(11) DEFAULT '0',
  `unread_atme_count` int(11) DEFAULT '0',
  `last_post_id` int(11) DEFAULT NULL,
  `first_kid_id` int(11) DEFAULT NULL,
  `province_id` int(11) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `industry_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `last_login_ip` varchar(255) DEFAULT NULL,
  `company` varchar(25) DEFAULT NULL,
  `invite_user_id` int(11) DEFAULT NULL,
  `age_id` int(11) DEFAULT '1',
  `link_category_ids` varchar(30) DEFAULT NULL,
  `pmt_ignores` varchar(30) DEFAULT '',
  `unread_favorites_count` int(11) DEFAULT '0',
  `invite_codes_count` int(11) DEFAULT '0',
  `mms_level` int(11) DEFAULT NULL,
  `invite_limit_num` int(11) DEFAULT '5',
  `is_hide_age` tinyint(1) DEFAULT '0',
  `unread_invited_count` int(11) DEFAULT '0',
  `is_100_notice` tinyint(1) DEFAULT '0',
  `ask_count` int(11) DEFAULT '0',
  `events_count` int(11) DEFAULT '0',
  `info_count` int(11) DEFAULT '0',
  `spots_count` int(11) DEFAULT '0',
  `org_profile_id` int(11) DEFAULT NULL,
  `rate` float DEFAULT '0',
  `rates_num` int(11) DEFAULT '0',
  `longitude` float DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `sid` varchar(255) DEFAULT NULL,
  `wap_tp` int(11) DEFAULT '0',
  `is_expert` tinyint(1) DEFAULT '0',
  `is_139` tinyint(1) DEFAULT NULL,
  `is_verify` tinyint(1) DEFAULT '0',
  `eproducts_count` int(11) DEFAULT '0',
  `balance` float DEFAULT '0',
  `invite_tuan_user_id` int(11) DEFAULT NULL,
  `has_grant` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_users_on_msn` (`msn`),
  KEY `index_users_on_province_id` (`province_id`),
  KEY `index_users_on_city_id` (`city_id`),
  KEY `index_users_on_posts_count` (`posts_count`),
  KEY `index_users_on_fans_users_count` (`fans_users_count`),
  KEY `index_users_on_tp` (`tp`),
  KEY `email` (`email`),
  KEY `index_users_on_email` (`email`),
  KEY `index_users_on_name` (`name`),
  KEY `index_users_on_mobile` (`mobile`),
  KEY `index_users_on_domain` (`domain`)
) ENGINE=InnoDB AUTO_INCREMENT=21736 DEFAULT CHARSET=utf8;

CREATE TABLE `video_urls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(250) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_video_urls_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=277 DEFAULT CHARSET=utf8;

CREATE TABLE `vip_user_applies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `age` int(11) DEFAULT NULL,
  `age_id` int(11) DEFAULT NULL,
  `end_age_id` int(11) DEFAULT NULL,
  `gender` varchar(5) DEFAULT NULL,
  `net_time` varchar(50) DEFAULT NULL,
  `advantage` varchar(50) DEFAULT NULL,
  `admin_time` varchar(50) DEFAULT NULL,
  `topics` varchar(200) DEFAULT NULL,
  `user_names` varchar(100) DEFAULT NULL,
  `reason` varchar(200) DEFAULT NULL,
  `to_do` varchar(400) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;

CREATE TABLE `visit_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `visit_user_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_visit_users_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27151 DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20091101123354');

INSERT INTO schema_migrations (version) VALUES ('20091101123915');

INSERT INTO schema_migrations (version) VALUES ('20091106222033');

INSERT INTO schema_migrations (version) VALUES ('20091106222049');

INSERT INTO schema_migrations (version) VALUES ('20091108045221');

INSERT INTO schema_migrations (version) VALUES ('20091108050106');

INSERT INTO schema_migrations (version) VALUES ('20091108050120');

INSERT INTO schema_migrations (version) VALUES ('20091108080942');

INSERT INTO schema_migrations (version) VALUES ('20091110072519');

INSERT INTO schema_migrations (version) VALUES ('20091110094412');

INSERT INTO schema_migrations (version) VALUES ('20091110112353');

INSERT INTO schema_migrations (version) VALUES ('20091110112421');

INSERT INTO schema_migrations (version) VALUES ('20091110112546');

INSERT INTO schema_migrations (version) VALUES ('20091112062205');

INSERT INTO schema_migrations (version) VALUES ('20091118011819');

INSERT INTO schema_migrations (version) VALUES ('20091118070943');

INSERT INTO schema_migrations (version) VALUES ('20091118075354');

INSERT INTO schema_migrations (version) VALUES ('20091120023831');

INSERT INTO schema_migrations (version) VALUES ('20091120055418');

INSERT INTO schema_migrations (version) VALUES ('20091120082306');

INSERT INTO schema_migrations (version) VALUES ('20091123042645');

INSERT INTO schema_migrations (version) VALUES ('20091123042726');

INSERT INTO schema_migrations (version) VALUES ('20091123113715');

INSERT INTO schema_migrations (version) VALUES ('20091125011146');

INSERT INTO schema_migrations (version) VALUES ('20091125011319');

INSERT INTO schema_migrations (version) VALUES ('20091211060154');

INSERT INTO schema_migrations (version) VALUES ('20091211060213');

INSERT INTO schema_migrations (version) VALUES ('20091213173456');

INSERT INTO schema_migrations (version) VALUES ('20091214054306');

INSERT INTO schema_migrations (version) VALUES ('20091215040609');

INSERT INTO schema_migrations (version) VALUES ('20091215100713');

INSERT INTO schema_migrations (version) VALUES ('20091216100537');

INSERT INTO schema_migrations (version) VALUES ('20091217020836');

INSERT INTO schema_migrations (version) VALUES ('20091217122900');

INSERT INTO schema_migrations (version) VALUES ('20091218080056');

INSERT INTO schema_migrations (version) VALUES ('20091221024307');

INSERT INTO schema_migrations (version) VALUES ('20091222020332');

INSERT INTO schema_migrations (version) VALUES ('20091222021222');

INSERT INTO schema_migrations (version) VALUES ('20091222052319');

INSERT INTO schema_migrations (version) VALUES ('20091222052341');

INSERT INTO schema_migrations (version) VALUES ('20091223021808');

INSERT INTO schema_migrations (version) VALUES ('20091224071203');

INSERT INTO schema_migrations (version) VALUES ('20091225022918');

INSERT INTO schema_migrations (version) VALUES ('20091225102114');

INSERT INTO schema_migrations (version) VALUES ('20091226081151');

INSERT INTO schema_migrations (version) VALUES ('20100102064846');

INSERT INTO schema_migrations (version) VALUES ('20100104054907');

INSERT INTO schema_migrations (version) VALUES ('20100106075654');

INSERT INTO schema_migrations (version) VALUES ('20100108024916');

INSERT INTO schema_migrations (version) VALUES ('20100111063922');

INSERT INTO schema_migrations (version) VALUES ('20100111064333');

INSERT INTO schema_migrations (version) VALUES ('20100111064352');

INSERT INTO schema_migrations (version) VALUES ('20100116080828');

INSERT INTO schema_migrations (version) VALUES ('20100118095208');

INSERT INTO schema_migrations (version) VALUES ('20100120055019');

INSERT INTO schema_migrations (version) VALUES ('20100124100740');

INSERT INTO schema_migrations (version) VALUES ('20100125020347');

INSERT INTO schema_migrations (version) VALUES ('20100126141947');

INSERT INTO schema_migrations (version) VALUES ('20100128043634');

INSERT INTO schema_migrations (version) VALUES ('20100128053605');

INSERT INTO schema_migrations (version) VALUES ('20100203113620');

INSERT INTO schema_migrations (version) VALUES ('20100205092139');

INSERT INTO schema_migrations (version) VALUES ('20100205100808');

INSERT INTO schema_migrations (version) VALUES ('20100206065644');

INSERT INTO schema_migrations (version) VALUES ('20100211014544');

INSERT INTO schema_migrations (version) VALUES ('20100215091654');

INSERT INTO schema_migrations (version) VALUES ('20100215093633');

INSERT INTO schema_migrations (version) VALUES ('20100224042823');

INSERT INTO schema_migrations (version) VALUES ('20100224064725');

INSERT INTO schema_migrations (version) VALUES ('20100225114750');

INSERT INTO schema_migrations (version) VALUES ('20100301041157');

INSERT INTO schema_migrations (version) VALUES ('20100303034428');

INSERT INTO schema_migrations (version) VALUES ('20100303035459');

INSERT INTO schema_migrations (version) VALUES ('20100303051928');

INSERT INTO schema_migrations (version) VALUES ('20100304062339');

INSERT INTO schema_migrations (version) VALUES ('20100304064207');

INSERT INTO schema_migrations (version) VALUES ('20100304064309');

INSERT INTO schema_migrations (version) VALUES ('20100315035943');

INSERT INTO schema_migrations (version) VALUES ('20100315040011');

INSERT INTO schema_migrations (version) VALUES ('20100315041334');

INSERT INTO schema_migrations (version) VALUES ('20100315055922');

INSERT INTO schema_migrations (version) VALUES ('20100315085031');

INSERT INTO schema_migrations (version) VALUES ('20100315092934');

INSERT INTO schema_migrations (version) VALUES ('20100316074012');

INSERT INTO schema_migrations (version) VALUES ('20100316092447');

INSERT INTO schema_migrations (version) VALUES ('20100316094446');

INSERT INTO schema_migrations (version) VALUES ('20100317031559');

INSERT INTO schema_migrations (version) VALUES ('20100317082834');

INSERT INTO schema_migrations (version) VALUES ('20100317115353');

INSERT INTO schema_migrations (version) VALUES ('20100317115414');

INSERT INTO schema_migrations (version) VALUES ('20100319073501');

INSERT INTO schema_migrations (version) VALUES ('20100320030848');

INSERT INTO schema_migrations (version) VALUES ('20100325094112');

INSERT INTO schema_migrations (version) VALUES ('20100326025046');

INSERT INTO schema_migrations (version) VALUES ('20100326085856');

INSERT INTO schema_migrations (version) VALUES ('20100331052856');

INSERT INTO schema_migrations (version) VALUES ('20100406053240');

INSERT INTO schema_migrations (version) VALUES ('20100406110020');

INSERT INTO schema_migrations (version) VALUES ('20100408021256');

INSERT INTO schema_migrations (version) VALUES ('20100409100713');

INSERT INTO schema_migrations (version) VALUES ('20100411114254');

INSERT INTO schema_migrations (version) VALUES ('20100415020025');

INSERT INTO schema_migrations (version) VALUES ('20100415040000');

INSERT INTO schema_migrations (version) VALUES ('20100415050248');

INSERT INTO schema_migrations (version) VALUES ('20100415051912');

INSERT INTO schema_migrations (version) VALUES ('20100415092726');

INSERT INTO schema_migrations (version) VALUES ('20100416071242');

INSERT INTO schema_migrations (version) VALUES ('20100419070643');

INSERT INTO schema_migrations (version) VALUES ('20100419071935');

INSERT INTO schema_migrations (version) VALUES ('20100420032632');

INSERT INTO schema_migrations (version) VALUES ('20100421072157');

INSERT INTO schema_migrations (version) VALUES ('20100421075109');

INSERT INTO schema_migrations (version) VALUES ('20100421095053');

INSERT INTO schema_migrations (version) VALUES ('20100422093756');

INSERT INTO schema_migrations (version) VALUES ('20100426041334');

INSERT INTO schema_migrations (version) VALUES ('20100426041350');

INSERT INTO schema_migrations (version) VALUES ('20100426052333');

INSERT INTO schema_migrations (version) VALUES ('20100426070811');

INSERT INTO schema_migrations (version) VALUES ('20100427092658');

INSERT INTO schema_migrations (version) VALUES ('20100428101803');

INSERT INTO schema_migrations (version) VALUES ('20100509075841');

INSERT INTO schema_migrations (version) VALUES ('20100509225012');

INSERT INTO schema_migrations (version) VALUES ('20100512015633');

INSERT INTO schema_migrations (version) VALUES ('20100514032531');

INSERT INTO schema_migrations (version) VALUES ('20100514061658');

INSERT INTO schema_migrations (version) VALUES ('20100514063212');

INSERT INTO schema_migrations (version) VALUES ('20100517033816');

INSERT INTO schema_migrations (version) VALUES ('20100517091629');

INSERT INTO schema_migrations (version) VALUES ('20100518040346');

INSERT INTO schema_migrations (version) VALUES ('20100518091734');

INSERT INTO schema_migrations (version) VALUES ('20100521091247');

INSERT INTO schema_migrations (version) VALUES ('20100522092646');

INSERT INTO schema_migrations (version) VALUES ('20100524043225');

INSERT INTO schema_migrations (version) VALUES ('20100524065910');

INSERT INTO schema_migrations (version) VALUES ('20100527071927');

INSERT INTO schema_migrations (version) VALUES ('20100531051713');

INSERT INTO schema_migrations (version) VALUES ('20100601013816');

INSERT INTO schema_migrations (version) VALUES ('20100601031143');

INSERT INTO schema_migrations (version) VALUES ('20100602041215');

INSERT INTO schema_migrations (version) VALUES ('20100602044851');

INSERT INTO schema_migrations (version) VALUES ('20100603063437');

INSERT INTO schema_migrations (version) VALUES ('20100603072409');

INSERT INTO schema_migrations (version) VALUES ('20100603084945');

INSERT INTO schema_migrations (version) VALUES ('20100604095429');

INSERT INTO schema_migrations (version) VALUES ('20100607083913');

INSERT INTO schema_migrations (version) VALUES ('20100608064222');

INSERT INTO schema_migrations (version) VALUES ('20100608093847');

INSERT INTO schema_migrations (version) VALUES ('20100608094230');

INSERT INTO schema_migrations (version) VALUES ('20100609064337');

INSERT INTO schema_migrations (version) VALUES ('20100611092546');

INSERT INTO schema_migrations (version) VALUES ('20100612095645');

INSERT INTO schema_migrations (version) VALUES ('20100614022517');

INSERT INTO schema_migrations (version) VALUES ('20100615021226');

INSERT INTO schema_migrations (version) VALUES ('20100615022036');

INSERT INTO schema_migrations (version) VALUES ('20100616033533');

INSERT INTO schema_migrations (version) VALUES ('20100617061010');

INSERT INTO schema_migrations (version) VALUES ('20100617110427');

INSERT INTO schema_migrations (version) VALUES ('20100618073003');

INSERT INTO schema_migrations (version) VALUES ('20100618074205');

INSERT INTO schema_migrations (version) VALUES ('20100618093955');

INSERT INTO schema_migrations (version) VALUES ('20100619010402');

INSERT INTO schema_migrations (version) VALUES ('20100619063449');

INSERT INTO schema_migrations (version) VALUES ('20100621060312');

INSERT INTO schema_migrations (version) VALUES ('20100621082145');

INSERT INTO schema_migrations (version) VALUES ('20100622031131');

INSERT INTO schema_migrations (version) VALUES ('20100622031508');

INSERT INTO schema_migrations (version) VALUES ('20100622081718');

INSERT INTO schema_migrations (version) VALUES ('20100622163021');

INSERT INTO schema_migrations (version) VALUES ('20100623092408');

INSERT INTO schema_migrations (version) VALUES ('20100623092808');

INSERT INTO schema_migrations (version) VALUES ('20100623103127');

INSERT INTO schema_migrations (version) VALUES ('20100627085853');

INSERT INTO schema_migrations (version) VALUES ('20100628152516');

INSERT INTO schema_migrations (version) VALUES ('20100705081904');

INSERT INTO schema_migrations (version) VALUES ('20100706011115');

INSERT INTO schema_migrations (version) VALUES ('20100707013208');

INSERT INTO schema_migrations (version) VALUES ('20100708012827');

INSERT INTO schema_migrations (version) VALUES ('20100708022241');

INSERT INTO schema_migrations (version) VALUES ('20100708043708');

INSERT INTO schema_migrations (version) VALUES ('20100709052213');

INSERT INTO schema_migrations (version) VALUES ('20100709074558');

INSERT INTO schema_migrations (version) VALUES ('20100712040200');

INSERT INTO schema_migrations (version) VALUES ('20100713014250');

INSERT INTO schema_migrations (version) VALUES ('20100713014517');

INSERT INTO schema_migrations (version) VALUES ('20100713025304');

INSERT INTO schema_migrations (version) VALUES ('20100713052808');

INSERT INTO schema_migrations (version) VALUES ('20100713053613');

INSERT INTO schema_migrations (version) VALUES ('20100713053922');

INSERT INTO schema_migrations (version) VALUES ('20100713104418');

INSERT INTO schema_migrations (version) VALUES ('20100714025313');

INSERT INTO schema_migrations (version) VALUES ('20100714114016');

INSERT INTO schema_migrations (version) VALUES ('20100715031416');

INSERT INTO schema_migrations (version) VALUES ('20100715033550');

INSERT INTO schema_migrations (version) VALUES ('20100715070245');

INSERT INTO schema_migrations (version) VALUES ('20100715091024');

INSERT INTO schema_migrations (version) VALUES ('20100720015106');

INSERT INTO schema_migrations (version) VALUES ('20100720075630');

INSERT INTO schema_migrations (version) VALUES ('20100720091104');

INSERT INTO schema_migrations (version) VALUES ('20100721035603');

INSERT INTO schema_migrations (version) VALUES ('20100721075553');

INSERT INTO schema_migrations (version) VALUES ('20100722005454');

INSERT INTO schema_migrations (version) VALUES ('20100723092656');

INSERT INTO schema_migrations (version) VALUES ('20100724164601');

INSERT INTO schema_migrations (version) VALUES ('20100726025455');

INSERT INTO schema_migrations (version) VALUES ('20100726070732');

INSERT INTO schema_migrations (version) VALUES ('20100729055432');

INSERT INTO schema_migrations (version) VALUES ('20100729093120');

INSERT INTO schema_migrations (version) VALUES ('20100730070051');

INSERT INTO schema_migrations (version) VALUES ('20100730100957');

INSERT INTO schema_migrations (version) VALUES ('20100730173219');

INSERT INTO schema_migrations (version) VALUES ('20100731091033');

INSERT INTO schema_migrations (version) VALUES ('20100802050453');

INSERT INTO schema_migrations (version) VALUES ('20100802074558');

INSERT INTO schema_migrations (version) VALUES ('20100803012340');

INSERT INTO schema_migrations (version) VALUES ('20100804015537');

INSERT INTO schema_migrations (version) VALUES ('20100805022744');

INSERT INTO schema_migrations (version) VALUES ('20100806060127');

INSERT INTO schema_migrations (version) VALUES ('20100809054558');