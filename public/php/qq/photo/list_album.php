<?php
/*
 * This is only a simple demo.
 * It is a free software; you can redistribute it 
 * and/or modify it. 
 */
require_once("../comm/utils.php");

/*
 * @brief get album list 
 * @param $appid
 * @param $appkey
 * @param $access_token
 * @param $access_token_secret
 * @param $openid
 *
 */
function list_album($appid, $appkey, $access_token, $access_token_secret, $openid)
{
    //get user info 的api接口，不要随便更改!!
    $url    = "http://openapi.qzone.qq.com/photo/list_album";
    echo do_get($url, $appid, $appkey, $access_token, $access_token_secret, $openid);
}

//test
list_album($_SESSION["appid"], $_SESSION["appkey"], $_SESSION["token"], $_SESSION["secret"], $_SESSION["openid"]);
?>
