<?php
/*
 * This is only a simple demo.
 * It is a free software; you can redistribute it 
 * and/or modify it. 
 */
require_once("../comm/utils.php");

 /**
 * @brief upload a picture to QQ platform 
 *
 * @param $appid
 * @param $appkey
 * @param $access_token
 * @param $access_token_secret
 * @param $openid
 */
function upload_pic($appid, $appkey, $access_token, $access_token_secret, $openid)
{
    //上传图片接口, 不要随便更改!!
    $url    = "http://openapi.qzone.qq.com/photo/upload_pic";
    echo do_multi_post($url, $appid, $appkey, $access_token, $access_token_secret, $openid);
}

//test for upload a picture
upload_pic($_SESSION["appid"], $_SESSION["appkey"], $_SESSION["token"], $_SESSION["secret"], $_SESSION["openid"]);
?>
