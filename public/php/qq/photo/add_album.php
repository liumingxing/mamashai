<?php
/*
 * This is only a simple demo.
 * It is a free software; you can redistribute it 
 * and/or modify it. 
 */
require_once("../comm/utils.php");

 /**
 * @brief add a album to QQ platform 
 *
 * @param $appid
 * @param $appkey
 * @param $access_token
 * @param $access_token_secret
 * @param $openid
 */
function add_album($appid, $appkey, $access_token, $access_token_secret, $openid)
{
    //上传图片接口, 不要随便更改!!
    $url    = "http://openapi.qzone.qq.com/photo/add_album";
    echo do_post($url, $appid, $appkey, $access_token, $access_token_secret, $openid);
}

//test for add a album 
add_album($_SESSION["appid"], $_SESSION["appkey"], $_SESSION["token"], $_SESSION["secret"], $_SESSION["openid"]);
?>
