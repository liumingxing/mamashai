$(function(){
    //头部导航
    $("#mms_gou_menu").hover(function(){
        $(this).addClass('current_on');
        $(this).children("ul").show();
    }, function(){
        $(this).removeClass('current_on');
        $(this).children("ul").hide();
    });
    //边栏
    $('.list_1').hover(function(){
        $(this).children('.layer_list_infor').show();
        $(this).addClass('current');
    }, function(){
        $(this).children('.layer_list_infor').hide();
        $(this).removeClass('current');
    });
	
   // 右侧人气排行边栏
    $('#mms_hot_rank .web_user_rank > li').mouseover(function(){
        $(this).addClass('rank_one');
        $(this).siblings('li').removeClass('rank_one');
    });
    
	//搜索
	$('form#search').submit(function(){
		var key = $('#key').val();
		if (key=='' || key == $('#key').attr('placeholder')){
			var error_message = "请先输入要查找的内容";
			$('#key').val(error_message);
			$('#key').attr('placeholder',error_message);
			return false;
		}
	});
    
    //点评开始
	
	var rate_labels = ['很差','差','还行','好','很好']
	
    $(".star_x a").bind({
        click: function(){
            $("#tuan_comment_rate").val($(this).index() + 1);
        },
        mouseover: function(){
            $(this).prevAll().andSelf().addClass('selected');
            $(this).nextAll().removeClass('selected');
			$(this).parent().next().text(rate_labels[$(this).index()]);
        }
    });
	
	$(".star_x").mouseout(function(){
		var index = $("#tuan_comment_rate").val();
		if((index == null)||(index=='')){
			$(this).children("a").removeClass('selected');
			$(this).next('.info').text('评分');
		}else{
			$(this).children("a:lt("+index+")").addClass('selected');
			$(this).children("a:gt("+(index-1)+")").removeClass('selected');
			$(this).next('.info').text(rate_labels[index-1]);
		}
	});
	
    if ($('#mms_comment').val() == 1) {
		$(".star_x").unbind('mouseout');
        $(".star_x a").unbind('mouseover');
    }
	
    $('.input_comments').keyup(function(){
        var length = $(this).val().length
        if ((210 - length) >= 0) {
            $('.all_size').text('可输入' + (210 - length) + '个字');
        }
        else {
            $('.all_size').html('<span class="red">已超出' + (length - 210) + '个字</span>');
        }
    });
    
    $('form#comment_form').submit(function(){
		if($('form#comment_form .input_comments').val().length<8){
			alert('评价内容至少需要8个字以上');
			return false;
		}
		var size = $('.star_ys input:hidden[value!=""]').size();
		if ((size==$('.star_x').size())){
	        $('form#comment_form .box_button').html('正在提交……');
		}else{
			alert('请您选择星星进行点评');
			return false;
		}
    });
    
    //点评结束
	
	$("#share_msn").toggle(function(){
        $("#share_address_top").show();
    }, function(){
        $("#share_address_top").hide();
    });
});

function add_reply_to_comment(id, name){
    $('#comment_content_' + id).val('回复@' + name + ':');
    $('#comment_content_' + id).focus();
}
