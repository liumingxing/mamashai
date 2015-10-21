$(function(){
	$('#show_gou_content').toggle(function(){
		$(this).children("img").attr("src","/images/dianping/button_33.gif");
		$(".info").hide();
		$(".shop_infor_content .text").show();
	},function(){
		$(this).children("img").attr("src","/images/dianping/button_3.gif");
		$(".info").show();
		$(".shop_infor_content .text").hide();
	});
});
