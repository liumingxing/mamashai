try {
    document.execCommand('BackgroundImageCache', false, true);
} 
catch (e) {
}

$.extend($.pnotify.defaults, {
    pnotify_stack: {
        "dir1": "down",
        "dir2": "right",
        "push": "down"
    }
});

jQuery.fn.extend({
    serialize: function(){
        var params = $.grep(this.serializeArray(), function(e, i){
            return e.value != "undefined"
        });
        var obj = jQuery.param(params);
        return obj;
    }
});

MMS_CallBacks = {
    rm_container: function(data, textStatus, XMLHttpRequest, trigger){
        trigger.parents('[container]').fadeOut('slow', function(){
            $(this).remove()
        });
        if (trigger.attr('notify')) 
            $.pnotify(trigger.attr('notify'));
    },
    load_posts: function(data, textStatus, XMLHttpRequest, trigger){
        $("#" + "post_wapper_" + trigger.attr('data_id')).remove();
    },
    load_comments: function(data, textStatus, XMLHttpRequest, trigger){
        if (/\d+/.test(data)) {
            trigger.parents().parents().parents(".list_comments").html(data);
        }
        else {
            $.pnotify(data);
        }
    },
    load_favorites: function(data, textStatus, XMLHttpRequest, trigger){
        if (/\d+/.test(data)) {
            trigger.parents().parents().parents(".list_favorites").html(data);
        }
        else {
            $.pnotify(data);
        }
    },
    load_favorite_post: function(data, textStatus, XMLHttpRequest, trigger){
        if (data) {
            trigger.parents('span').html(data);
            $.pnotify(data);
        }
    },
	load_follow_user: function(data, textStatus, XMLHttpRequest, trigger){
        if (data) {
            trigger.parents('li').html(data);
            $.pnotify(data);
        }
    },
    load_forward_tuan: function(data, textStatus, XMLHttpRequest, trigger){
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
                        $.post(f.attr("action"), function(data){
                            alert(data);
                        });
                    },
                    '取消': function(){
                        $(this).dialog("close");
                    }
                }
            });
            $('＃forward_post_content').focus();
        }
    }
};

function callback(data, status, xhr, t){
    t.data('had_called', false)
    ajax_success_notify(t);
    var callback_name = t.attr('callback') || "";
    if (callback_name.length > 0 && MMS_CallBacks[callback_name] != null) 
        MMS_CallBacks[callback_name].call(this, data, status, xhr, t);
}

function ajax_start_notify(t){
    if (t.attr('s_notify')) 
        $.pnotify(t.attr('s_notify'));
}

function ajax_success_notify(t){
    if (t.attr('e_notify')) 
        $.pnotify(t.attr('e_notify'));
}


function auto_ajax_submit(){
    var f = $(this);
    ajax_start_notify(f);
    
    var post_data = f.serialize();
    post_data['_method'] = f.attr('auto_remote');
    
    $.post(f.attr("action"), post_data, function(data, status, xhr){
        callback.call(this, data, status, xhr, f)
    });
    return false;
};

function had_called(t){
    if (t.data('had_called')) {
        $.pnotify("请不要反复执行同样的操作！");
        return true;
    }
    t.data('had_called', false);
    return false;
}

function auto_ajax_link(){
    var a = $(this);
    
    if (!had_called(a)) {
        a.data('had_called', true);
        ajax_start_notify(a);
        if (a.attr('auto_remote') == "delete") {
            $.post(a.attr('ahref'), {
                _method: "delete"
            }, function(data, status, xhr){
                callback.call(this, data, status, xhr, a);
            });
        }
        if (a.attr('auto_remote') == "get") {
            $.get(a.attr('ahref'), function(data, status, xhr){
                callback.call(this, data, status, xhr, a);
            });
        }
        
        if (a.attr('auto_remote') == "post") {
            var d = {};
            var re = /^data_.*/
            $.each(a[0].attributes, function(i, attr){
                if (re.test(attr.name)) 
                    var n = attr.name.replace('data_', '');
                d[n] = attr.value;
            });
            $.post(a.attr('ahref'), d, function(data, status, xhr){
                callback.call(this, data, status, xhr, a);
            });
        }
    }
    return false;
};

function dialog(){
    var a = $(this);
    if (a.attr("dialog") == "dialog-confirm") {
        dialog_for_link(a);
    }
    if (a.attr("dialog") == "dialog-form") {
        dialog_for_form(a);
    }
}

function dialog_for_link(a){
    var d = {};
    var re = /^data_.*/
    $.each(a[0].attributes, function(i, attr){
        if (re.test(attr.name)) 
            var n = attr.name.replace('data_', '');
        d[n] = attr.value;
    });
    var dialog_title = "您确定要删除吗?"
    if (a.attr("dialog_title") != undefined) {
        dialog_title = a.attr("dialog_title");
    }
    var dialog_content = "您确定要删除吗?"
    if (a.attr("dialog_content") != undefined) {
        dialog_content = a.attr("dialog_content");
    }
    if ($("#dialog-confirm").length == 0) {
        $("body").append('<div id="dialog-confirm" title="' + dialog_title + '"><p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>' + dialog_content + '</p></div>');
    }
    else {
        $("#dialog-confirm").html('<div id="dialog-confirm" title="' + dialog_title + '"><p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>' + dialog_content + '</p></div>');
    }
    $("#dialog-confirm").dialog({
        resizable: false,
        height: 140,
        modal: true,
        buttons: {
            "确定": function(){
                $.post(a.attr('ahref'), d, function(data, status, xhr){
                    callback.call(this, data, status, xhr, a);
                });
                $(this).dialog("close");
            },
            "取消": function(){
                $(this).dialog("close");
            }
        }
    });
}

function dialog_for_form(a){
    var d = {};
    var re = /^data_.*/
    $.each(a[0].attributes, function(i, attr){
        if (re.test(attr.name)) 
            var n = attr.name.replace('data_', '');
        d[n] = attr.value;
    });
    $.post(a.attr('ahref'), d, function(data, status, xhr){
        callback.call(this, data, status, xhr, a);
    });
}

function delete_comment(url, post_expand_id){
    var a = $(this);
    $.post(url, {}, function(data){
        if (/\d+/.test(data)) {
            $("#" + post_expand_id).html(data);
        }
        else {
            $.pnotify(data);
        }
        $("#dialog-confirm").dialog("destroy");
        $("#dialog-confirm").remove();
    });
}


