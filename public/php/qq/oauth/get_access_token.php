<?php
/*
 * This is only a simple demo.
 * It is a free software; you can redistribute it 
 * and/or modify it. 
 */
require_once("../comm/utils.php");

/**
 * @brief get a access token 
 *        rfc1738 urlencode
 * @param $appid
 * @param $appkey
 * @param $request_token
 * @param $request_token_secret
 * @param $vericode
 *
 * @return a string, as follows:
 *      oauth_token=xxx&oauth_token_secret=xxx&openid=xxx&oauth_signature=xxx&oauth_vericode=xxx&timestamp=xxx
 */
function get_access_token($appid, $appkey, $request_token, $request_token_secret, $vericode)
{
    //获取access token接口，不要随便更改!!
    $url    = "http://openapi.qzone.qq.com/oauth/qzoneoauth_access_token?";
    //构造签名串.源串:方法[GET|POST]&uri&参数按照字母升序排列
    $sigstr = "GET"."&".rawurlencode("http://openapi.qzone.qq.com/oauth/qzoneoauth_access_token")."&";

    //必要参数，不要随便更改!!
    $params = array();
    $params["oauth_version"]          = "1.0";
    $params["oauth_signature_method"] = "HMAC-SHA1";
    $params["oauth_timestamp"]        = time();
    $params["oauth_nonce"]            = mt_rand();
    $params["oauth_consumer_key"]     = $appid;
    $params["oauth_token"]            = $request_token;
    $params["oauth_vericode"]         = $vericode;

    //对参数按照字母升序做序列化
    $normalized_str = get_normalized_string($params);
    $sigstr        .= rawurlencode($normalized_str);

    //echo "sigstr = $sigstr";

    //签名,确保php版本支持hash_hmac函数
    $key = $appkey."&".$request_token_secret;
    $signature = get_signature($sigstr, $key);
    //构造请求url
    $url      .= $normalized_str."&"."oauth_signature=".rawurlencode($signature);

	$context = stream_context_create(array( 'http' => array( 'timeout' => 6 )));
    $result = file_get_contents($url, 0, $context);
    while (!$result)
    {
    	$result = file_get_contents($url, 0, $context);
    }
    return $result;
}

//tips//
/**
 * QQ互联登录，授权成功后会回调此地址
 * 必须要用授权的request token换取access token
 * 访问QQ互联的任何资源都需要access token
 * 目前access token是长期有效的，除非用户解除与第三方绑定
 * 如果第三方发现access token失效，请引导用户重新登录QQ互联，授权，获取access token
 */
//print_r($_REQUEST);

//授权成功后，会返回用户的openid
//检查返回的openid是否是合法id
if (!is_valid_openid($_REQUEST["openid"], $_REQUEST["timestamp"], $_REQUEST["oauth_signature"]))
{
    //demo对错误简单处理
    echo "###invalid openid\n";
    echo "sig:".$_REQUEST["oauth_signature"]."\n";
    exit;
}

//tips
//这里已经获取到了openid，可以处理第三方账户与openid的绑定逻辑
//但是我们建议第三方等到获取accesstoken之后在做绑定逻辑

//用授权的request token换取access token
$access_str = get_access_token($_SESSION["appid"], $_SESSION["appkey"], $_REQUEST["oauth_token"], $_SESSION["secret"], $_REQUEST["oauth_vericode"]);
//echo "access_str:$access_str\n";
$result = array();
parse_str($access_str, $result);

//print_r($result);

//error
if (isset($result["error_code"]))
{
    echo "error_code = ".$result["error_code"];
    exit;
}

//获取access token成功后也会返回用户的openid
//我们强烈建议第三方使用此openid
//检查返回的openid是否是合法id
if (!is_valid_openid($result["openid"], $result["timestamp"], $result["oauth_signature"]))
{
    //demo对错误简单处理
    echo "@@@invalid openid";
    echo "sig:".$result["oauth_signature"]."\n";
    exit;
}

//将access token，openid保存!!
//XXX 作为demo,临时存放在session中，网站应该用自己安全的存储系统来存储这些信息
$_SESSION["token"]   = $result["oauth_token"];
$_SESSION["secret"]  = $result["oauth_token_secret"]; 
$_SESSION["openid"]  = $result["openid"];

//第三方处理用户绑定逻辑
//将openid与第三方的帐号做关联
//bind_to_openid();

function get_user_info($appid, $appkey, $access_token, $access_token_secret, $openid)
{
    //get user info 的api接口，不要随便更改!!
    $url    = "http://openapi.qzone.qq.com/user/get_user_info";
    return do_get($url, $appid, $appkey, $access_token, $access_token_secret, $openid);
}
header("Location:http://localhost:3000/account/login_from_qq?token=".$_SESSION["token"]."&secret=".$_SESSION["secret"]."&openid=".$_SESSION["openid"]."&info=".rawurlencode(get_user_info($_SESSION["appid"], $_SESSION["appkey"], $_SESSION["token"], $_SESSION["secret"], $_SESSION["openid"])));
?>
