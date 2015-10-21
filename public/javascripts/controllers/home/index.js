(function($){
    $(function(){
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
			date.setDate(date.getDate()+7);
			Cookies.set("ad_time",$('#mms_ad_time').val(),date);
			$("#mms_ad_div").hide();
			$("#mms_ad_link").show();
		});
		
		$("#mms_ad_link").children('a').click(function(){
			var date = new Date();
			date.setDate(date.getDate()+7);
			Cookies.set("ad_time",'',date);
			$("#mms_ad_div").show();
			$("#mms_ad_link").hide();
		});
		
    })
    // 通过控制top ，来显示不同的幻灯片
    function showImg(index){
        var adHeight = $(".mmsads").height();
		$(".slider li").hide();
		$($(".slider li").get(index)).show();

        $(".num li").removeClass("on").eq(index).addClass("on");
    }
})(jQuery);


