<?php
set_include_path(dirname(dirname(__FILE__)) . '/lib/');
require_once 'OpenSDK/Tencent/Weibo.php';

include 'appkey.php';

OpenSDK_Tencent_Weibo::init($appkey, $appsecret);

//打开session
session_start();
header('Content-Type: text/html; charset=utf-8');
$exit = false;

$_SESSION[OpenSDK_Tencent_Weibo::ACCESS_TOKEN] = $_GET['token'];
$_SESSION[OpenSDK_Tencent_Weibo::OAUTH_TOKEN_SECRET] = $_GET['secret'];

	//已经取得授权
	$uinfo = OpenSDK_Tencent_Weibo::call('user/info');
        
        $res = OpenSDK_Tencent_Weibo::call('t/add_pic', array(
                'content' => $_GET['content'],
                'clientip' => $_GET['ip'],
        ), 'POST', array(
                'pic' => array(
                        'type' => 'image/jpg',
                        'name' => '0.jpg',
                        'data' => file_get_contents($_GET['pic']),
                ),
        ));

        echo $res['msg'].':'.$res['data']['id'];	
