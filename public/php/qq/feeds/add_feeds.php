<?php
/*
 * This is only a simple demo.
 * It is a free software; you can redistribute it 
 * and/or modify it. 
 */
require_once("../comm/utils.php");

 /**
 * @brief add a feed to QQ platform 
 *
 * @param $appid
 * @param $appkey
 * @param $access_token
 * @param $access_token_secret
 * @param $openid
 */
function add_feeds($appid, $appkey, $access_token, $access_token_secret, $openid)
{
    //上传FEEDS接口, 不要随便更改!!
    $url    = "http://openapi.qzone.qq.com/feeds/add_feeds";
    echo do_post($url, $appid, $appkey, $access_token, $access_token_secret, $openid);
}

//test for add a feed 
add_feeds($_SESSION["appid"], $_SESSION["appkey"], $_SESSION["token"], $_SESSION["secret"], $_SESSION["openid"]);
?>
