$(function(){
    $.extend(MMS_CallBacks, {
        create_tuan_comments: function(data, textStatus, XMLHttpRequest, trigger){
            if (/\d+/.test(data)) {
                trigger.parents('.haoping').find('strong[container=count]').html(data);
            }
            else {
                $.pnotify(data);
            }
        },
        load_comments: function(data, textStatus, XMLHttpRequest, trigger){
            if (/\d+/.test(data)) {
                trigger.parents().parents().parents(".list_tuan_comments").html(data);
            }
            else {
                $.pnotify(data);
            }
        },
        load_favorite_tuans: function(data, textStatus, XMLHttpRequest, trigger){
            if (/\d+/.test(data)) {
                trigger.parents().parents().parents(".list_favorite_tuans").html(data);
            }
            else {
                $.pnotify(data);
            }
        },
        load_favorite_tuan: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
                trigger.parents('span').html(data);
                $.pnotify(data);
            }
        },
        create_favorite_tuan: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
                $.pnotify({
                    pnotify_text: data,
                    pnotify_delay: 900,
                    pnotify_before_open: function(pnotify){
                        pnotify.css({
                            "top": ($(window).height() / 2) - (pnotify.height() / 2),
                            "left": ($(window).width() / 2) - (pnotify.width() / 2)
                        });
                    }
                });
            }
        },
        delete_favorite_tuan: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
                if (data == "删除成功！") {
                    trigger.parents().parents("tr").remove();
                }
                $.pnotify(data);
            }
        },
        load_forward_tuans: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
                if ($("#dialog-form").length == 0) {
                    $("body").append('<div id="dialog-form" title="转晒">' + data + '</div>');
                }
                else {
                    $("#dialog-form").html('<div id="dialog-form" title="转晒">' + data + '</div>');
                }
                $("#dialog-form").dialog({
                    resizable: false,
                    height: 450,
                    width: 460,
                    modal: true,
                    buttons: {
                        '转晒': function(){
                            f = $("#dialog-form").find("form");
                            $("#forward_tuan_form").submit();
                            $(this).dialog("close");
                        },
                        '取消': function(){
                            $(this).dialog("close");
                        }
                    }
                });
                $('＃forward_tuan_content').focus();
            }
        },
        forward_form_result: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
                $("#dialog-form").html(data);
                $.pnotify(data);
                $("#dialog-form").dialog({
                    resizable: false,
                    height: 200,
                    width: 300,
                    modal: true,
                    buttons: {
                        '确定': function(){
                            $(this).dialog("close");
                        }
                    }
                });
            }
        },
        delete_comment_tuan: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
                if (data == "删除成功！") {
                    trigger.parents(".comments_all").remove();
                }
                $.pnotify(data);
            }
        },
        update_follow_user: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
                trigger.parents(".c1").html(data);
            }
        },
        load_my_order: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
                trigger.parents("tr").html(data);
            }
        },
        tuan_subscription: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
                $.pnotify(data);
            }
        },
        tuan_message: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
                $.pnotify(data);
            }
        },
        mama_comments: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
                trigger.parents("#tuan_list_comments").html(data);
            }
        },
        delete_comment_mama: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
                if (data == "删除成功！") {
                    trigger.parents(".comments_list").remove();
                }
                $.pnotify(data);
            }
        },
        create_article_good: function(data, textStatus, XMLHttpRequest, trigger){
            if (/\d+/.test(data)) {
                trigger.parents('.haoping').find('strong[container=count]').html(data);
            }
            else {
                $.pnotify(data);
            }
        }
    });
    
    
    window.setInterval(function(){
        time();
    }, 1000);
    
    $("#share_msn").toggle(function(){
        $("#share_address_top").show();
    }, function(){
        $("#share_address_top").hide();
    });
    $("#share_address_link_top").click(function(){
        $(this).select();
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
		if($('form#comment_form .input_comments').val()==''){
			alert('评价内容不能为空');
			return false;
		}
		var size = $('.star_ys input:hidden[value=""]').size();
		if (($('#mms_comment').val() == 1)||(size == 0)||(size==$('.star_x').size())){
	        $('form#comment_form .box_button').html('正在提交……');
		}else{
			alert('请您选择星星进行点评');
			return false;
		}
    });
    
    //点评结束
	
	//搜索
	$('form#search').submit(function(){
		var key = $('#key').val();
		if (key=='' || key == $('#key').attr('placeholder')){
			var error_message = "请输入团购商品名称...";
			$('#key').val(error_message);
			$('#key').attr('placeholder',error_message);
			return false;
		}
	});
});

function time(){
    $(".time").each(function(){
        var time = Number($(this).children(".none").text()) - new Date().getTime() / 1000;
        if (time > 0) {
            time = Number($(this).children(".none").text()) - new Date().getTime() / 1000;
            var aTime = count_time(time);
            $(this).children('.day').text(aTime[0]);
            $(this).children('.hour').text(aTime[1]);
            $(this).children('.minute').text(aTime[2]);
            $(this).children('.second').text(aTime[3]);
        }
    });
}

function count_time(time){
    var day = Math.floor(time / 60 / 60 / 24);
    var hour = Math.floor((time / 60 / 60) % 24);
    var minute = Math.floor((time / 60) % 60);
    var second = Math.floor(time % 60);
    var times = new Array(day, hour, minute, second)
    return times
}

function show_tuan_expand(action_name, tuan_id){
    var div_id = '#tuan_expand_' + tuan_id;
    url = '/ajax/' + action_name + '/' + tuan_id;
    if ($(div_id).hasClass(action_name)) {
        $(div_id).attr("className", '');
        $(div_id).hide();
    }
    else {
        $.post(url, function(data){
            $(div_id).html(data);
        });
        $(div_id).attr("className", action_name);
        $(div_id).show();
    }
}

function add_reply_to_comment(id, name){
    $('#comment_content_' + id).val('回复@' + name + ':');
    $('#comment_content_' + id).focus();
}


function updateStatusTextContent(obj){
    updateTextContent(obj);
    obj.style.height = obj.scrollHeight + 'px';
}

function updateTextContent(obj){
    var len_max = 210;
    var str = obj.value;
    var len = str.length
    if (len > len_max) {
        obj.value = str.substr(0, len_max);
    }
}

function show_cities(){
    $(".mmt_city_list").slideToggle("fast");
    $(".city_huan").toggleClass("city_huan_top");
}

