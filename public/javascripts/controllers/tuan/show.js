$(function(){
    $(".star_x a").bind({
        click: function(){
            $("#tuan_comment_" + $(this).parent().attr("data")).val($(this).index() + 1);
            $(this).siblings().andSelf().unbind('mouseover');
        },
        mouseover: function(){
            $(this).prevAll().andSelf().addClass('selected');
			$("#tuan_comment_" + $(this).parent().attr("data")).val($(this).index() + 1);
            $(this).nextAll().removeClass('selected');
        }
    });
    
    if ($('#mms_comment').val() == 1) {
    	$(".star_x a").unbind('mouseover');
    }
	
});
