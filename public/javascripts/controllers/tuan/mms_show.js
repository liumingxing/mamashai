$(function(){
	$("#share_msn").toggle(
		function(){
			$("#share_address_top").show();
		},function(){
			$("#share_address_top").hide();
		}
	);
	$("#share_address_link_top").click(function(){
		$(this).select();
	});
	$("#details_tag").click(function(){
		$(".post_shopping_info").show();
		$("#details_tag").parent().attr('class', 'current');
		$("#overall_comments").hide();
		$("#comments_tag").parent().attr('class', '');
	});
	$("#comments_tag").click(function(){
		$(".post_shopping_info").hide();
		$("#details_tag").parent().attr('class', '');
		$("#overall_comments").show();
		$("#comments_tag").parent().attr('class', 'current');
	});
});