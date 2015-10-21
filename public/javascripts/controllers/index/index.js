$(function(){
    $("#user_password").val($("#user_password").attr("palceholder"));
    
    
    var loop_post = function(){
        var post = $('#welcome_posts .sun_text').last();
        post.remove().prependTo('#welcome_posts').hide().slideDown('slow');
    }
    setInterval(loop_post, 3000);
    
    
    //广告开始
    var len = $(".num > li").length;
    var index = 0;
    var adTimer;
    $(".num li").mouseover(function(){
        index = $(".num li").index(this);
        showImg(index);
    }).eq(0).mouseover();
    //滑入 停止动画，滑出开始动画.
    $('.mmsads').hover(function(){
        clearInterval(adTimer);
    }, function(){
        adTimer = setInterval(function(){
            showImg(index)
            index++;
            if (index == len) {
                index = 0;
            }
        }, 6000);
    }).trigger("mouseleave");
    
    $("#ad_close").click(function(){
        var date = new Date();
        date.setDate(date.getDate() + 7);
        Cookies.set("ad_time", $('#mms_ad_time').val(), date);
        $("#mms_ad_div").hide();
        $("#mms_ad_link").show();
    });
    
    $("#mms_ad_link").children('a').click(function(){
        var date = new Date();
        date.setDate(date.getDate() + 7);
        Cookies.set("ad_time", '', date);
        $("#mms_ad_div").show();
        $("#mms_ad_link").hide();
    });
    
    //广告结束
    
    
    $(".mms_change_users").click(function(){
        $(".m_content").load(('/index/change_welcome_users'));
    });
    
    //登录框开始
    $("#user_password_text").focus(function(){
        $(this).hide();
        $("#user_password").show();
        $("#user_password")[0].focus();
    });
    
    $("#user_password").blur(function(){
        if ($(this).val() == '' || $(this).val() == null||$(this).val()==$(this).attr('placeholder')) {
            $(this).hide();
            $("#user_password_text").show();
        }
    });
	
	$("#user_email").focus(function(){
		if ($(this).attr("placeholder") == $(this).val())
		{
			$(this).val("");
		}
	})
	//登录结束
    
});


function showImg(index){
	var adHeight = $(".mmsads").height();
    $(".slider").stop(true, false).animate({
        top: -adHeight * index
    }, 0);
    $(".num li").removeClass("on").eq(index).addClass("on");
}
