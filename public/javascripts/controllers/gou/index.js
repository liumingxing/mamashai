var Cookies = {
    set: function(d, g){
        var a = arguments;
        var j = arguments.length;
        var b = a[2] || null;
        var i = a[3] || "/";
        var f = a[4] || null;
        var h = a[5] || false;
        document.cookie = d + "=" + escape(g) + ((b == null) ? "" : ("; expires=" + b.toGMTString())) + ((i == null) ? "" : ("; path=" + i)) + ((f == null) ? "" : ("; domain=" + f)) + ((h == true) ? "; secure" : "")
    },
    get: function(f){
        var b = f + "=";
        var h = b.length;
        var a = document.cookie.length;
        var g = 0;
        var d = 0;
        while (g < a) {
            d = g + h;
            if (document.cookie.substring(g, d) == b) {
                return Cookies.getCookieVal(d)
            }
            g = document.cookie.indexOf(" ", g) + 1;
            if (g == 0) {
                break
            }
        }
        return null
    },
    clear: function(a){
        if (Cookies.get(a)) {
            document.cookie = a + "=; expires=Thu, 01-Jan-70 00:00:01 GMT"
        }
    },
    getCookieVal: function(b){
        var a = document.cookie.indexOf(";", b);
        if (a == -1) {
            a = document.cookie.length
        }
        return unescape(document.cookie.substring(b, a))
    }
};


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
        $(".slider").stop(true, false).animate({
            top: -adHeight * index
        }, 0);
        $(".num li").removeClass("on").eq(index).addClass("on");
    }
})(jQuery);
