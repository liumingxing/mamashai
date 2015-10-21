$(function(){
    $.extend(MMS_CallBacks, {
        create_blog_category: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
                if ($("#dialog-form").length == 0) {
                    $("body").append('<div id="dialog-form" title="添加分类">' + data + '</div>');
                }
                else {
                    $("#dialog-form").html('<div id="dialog-form" title="添加分类">' + data + '</div>');
                }
                $("#dialog-form").dialog({
                    resizable: false,
                    height: 150,
                    width: 460,
                    modal: true,
                    buttons: {
                        '确定': function(){
                            f = $("#dialog-form").find("form");
                            $("#create_category_form").submit();
                            $(this).dialog("close");
                        },
                        '取消': function(){
                            $(this).dialog("close");
                        }
                    }
                });
            }
        },
        load_blogs_categories: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
				if(data == "添加分类失败！"){
					$.pnotify("添加分类失败！");
				}else{
					$.pnotify("添加分类成功！");
                	$('#post_blog_category_id').html(data);
				}
            }
        },
		blogs_category_edit: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
				trigger.parent().parent().html(data);
            }
        },
		blogs_category_update: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
				trigger.parents('.focus_item').html(data);
            }
        },
		load_blog_categorie_updated: function(data, textStatus, XMLHttpRequest, trigger){
            if (data) {
				if(data == "分类名称不能为空"){
					$.pnotify("修改分类失败！");
				}else{
					$.pnotify("修改分类成功！");
					trigger.parents('.focus_item').html(data);
				}
            }
        }
    });
	
});
