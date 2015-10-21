
function check_event_quit(){
    if (document.getElementById('event_user_note').value.strip() == '') {
        document.getElementById('error_event_quit').innerHTML = '请填写原因';
    }
    else {
        document.getElementById('event_user_quit_form').onsubmit();
    }
}


////////////// ask  //////////////

function submit_ask_form(tp){
    document.getElementById('search_tp').value = tp;
    document.getElementById('search_ask_form').submit();
}


///////////// index //////////////

function show_index_category_tags(id){ 
    Element.toggle('category_tags_' + id);
    if (document.getElementById('category_index_' + id).className == 'c1') {
        document.getElementById('category_index_' + id).className = 'c2';
    }
    else {
        document.getElementById('category_index_' + id).className = 'c1';
    }
    
}


function show_fade_link(){
    new Marquee({
        element: "fade_link",
        data: [{
            message: "伸出母亲的手，玉树儿童捐助义卖活动",
            life: 3,
            link: "/yushu"
        },{
            message: "注册妈妈晒 天天有惊喜！",
            life: 3,
            link: "/activity/item8"
        }, {
            message: "北京人民广播电台爱家频道《宝贝计划》",
            life: 3,
            link: "/activity/item10"
        }]
    });
}


function toggle_search(id){
    for (var i = 1; i < 4; i++) {
        Element.hide('search_' + i);
    }
    Element.show('search_' + id);
}

function submit_search(){
    for (var i = 1; i < 4; i++) {
        if (document.getElementById('search_tp_' + i).checked) 
            break;
    }
    document.getElementById('web_search_form' + i).submit();
}

function show_today_time(){
    document.getElementById('time_str').innerHTML = new Date().toLocaleString();
    setInterval("document.getElementById('time_str').innerHTML=new Date().toLocaleString();", 1000);
    document.getElementById('time_week').innerHTML = '星期' + '日一二三四五六'.charAt(new Date().getDay());
}

//////////// comments ///////////////

function select_all_comments(all_check){
    var checkboxs = document.getElementsByClassName('form_checkbox');
    for (var i = 0; i < checkboxs.length; i++) {
        checkboxs[i].checked = all_check.checked;
    }
}

function select_all_comments_form_link(id){
    all_check = document.getElementById(id);
    all_check.checked = !all_check.checked;
    select_all_comments(all_check);
}

function delete_comments(back_action){
    var comment_ids = new Array();
    var checkboxs = document.getElementsByClassName('form_checkbox');
    for (var i = 0; i < checkboxs.length; i++) {
        if (checkboxs[i].checked && checkboxs[i].value != 'checkbox') {
            comment_ids.push(checkboxs[i].value);
        }
    }
    window.location = '/home/delete_select_comments?back_action=' + back_action + '&comment_ids=' + comment_ids.join(',')
}

function add_reply_to_comment(id, name){
    document.getElementById('comment_content_' + id).value = '回复@' + name + ':';
    document.getElementById('comment_content_' + id).focus();
}

//////////// gift ///////////////

function select_send_gift(id){
	$(".current").removeClass('current')
	$('#send_gift_' + id).addClass('current')
	document.getElementById('gift_get_gift_id').value = id;
}

function select_send_user(name){
    document.getElementById('gift_get_user_name').value = name;
    scroll_to_gift_form();
}

function scroll_to_gift_form(){
    document.getElementById('gift_get_user_name').focus();
    document.getElementById('gift_sent_title').scrollIntoView();
}

function show_tab(id_pre, class_name, class_active, length, cursor){
    for (var i = 1; i <= length; i++) {
        document.getElementById(id_pre + i).style.display = "none";
        document.getElementById(id_pre + i + '_t').className = class_name;
    }
    document.getElementById(id_pre + cursor).style.display = "block";
    document.getElementById(id_pre + cursor + '_t').className = class_active;
}

/////////////// form_tips /////////////

var top_search_post_pmt = "搜索话题、朋友...";
var search_post_pmt = "搜索关键字...";
var dd_menu_tag_pmt = "输入自定义话题";
var search_text_post_pmt = '输入关键字'
var video_pmt = '请输入视频Flash网址(URL)'

/// dd_menu tag

function init_dd_menu_tag(){
    document.getElementById('dd_menu_tag_name').onfocus = clear_dd_menu_tag_tip;
    document.getElementById('dd_menu_tag_name').onblur = show_dd_menu_tag_tip;
    show_dd_menu_tag_tip();
}

function clear_dd_menu_tag_tip(){
    clear_form_tip('dd_menu_tag_name', dd_menu_tag_pmt);
}

function show_dd_menu_tag_tip(){
    show_form_tip('dd_menu_tag_name', dd_menu_tag_pmt);
}

/// index search

function init_search_post_form(){
    document.getElementById('search_post_content').onfocus = clear_search_post_tip;
    document.getElementById('search_post_content').onblur = show_search_post_tip;
    show_search_post_tip();
}

function check_search_post_form(){
    clear_search_post_tip();
    return true;
}

function clear_search_post_tip(){
    clear_form_tip('search_post_content', search_post_pmt);
}

function show_search_post_tip(){
    show_form_tip('search_post_content', search_post_pmt);
}

/// top search

function init_top_search_post_form(){
    document.getElementById('top_search_post_content').onfocus = clear_top_search_post_tip;
    document.getElementById('top_search_post_content').onblur = show_top_search_post_tip;
    show_top_search_post_tip();
}


function check_top_search_post_form(){
    clear_top_search_post_tip();
    return true;
}

function clear_top_search_post_tip(){
    clear_form_tip('top_search_post_content', top_search_post_pmt);
}

function show_top_search_post_tip(){
    show_form_tip('top_search_post_content', top_search_post_pmt);
}

/// book_page post text search

function init_search_text_post_form(){
    document.getElementById('search_text_post_content').onfocus = clear_search_text_post_tip;
    document.getElementById('search_text_post_content').onblur = show_search_text_post_tip;
    show_search_text_post_tip();
}


function check_search_text_post_form(){
    clear_search_text_post_tip();
    return true;
}

function clear_search_text_post_tip(){
    clear_form_tip('search_text_post_content', search_text_post_pmt);
}

function show_search_text_post_tip(){
    show_form_tip('search_text_post_content', search_text_post_pmt);
}


function clear_form_tip(id, pmt){
    if (document.getElementById(id).value == pmt) {
        document.getElementById(id).value = "";
    }
}

function show_form_tip(id, pmt){
    if (trim(document.getElementById(id).value) == "") {
        document.getElementById(id).value = pmt;
    }
}


////////////  post_form /////////////

function insert_post_smiles(){
    //debugger;
    if (document.getElementById('post_form_pic').style.display == "" || (document.getElementById('post_form_video') && document.getElementById('post_form_video').style.display == "")) {
        var otherIndex = Math.max(parseInt(document.getElementById('post_form_pic').style.zIndex), parseInt(document.getElementById('post_form_video') && document.getElementById('post_form_video').style.zIndex)) || 0;
        document.getElementById('smiles_list').style.zIndex = parseInt(otherIndex) + 1;
    }
    else {
        document.getElementById('smiles_list').style.zIndex = 5;
    }
	
    if ($.trim($("#smiles_list").text()) == "") {
		jQuery("#smiles_list").load("/ajax/form_post_smiles")
	}
		
	$("#smiles_list").toggle();
}


function insert_post_logo(){
    if (document.getElementById('post_content') && document.getElementById('post_content').value == '') {
        document.getElementById('post_content').value = '晒图片';
    }
    Element.toggle('post_form_pic');
    if (document.getElementById('post_form_video')) 
        Element.hide('post_form_video');
    if (document.getElementById('smiles_list').style.display == "") {
        var smileIndex = document.getElementById('smiles_list').style.zIndex || 0;
        document.getElementById('post_form_pic').style.zIndex = parseInt(smileIndex) + 1;
    }
    else {
        document.getElementById('post_form_pic').style.zIndex = 5;
    }
    if (document.getElementById('post_video_link')) 
        document.getElementById('post_video_link').value = '';
}

function insert_post_vote(){
    $("#post_form_vote").toggle();
   
}

function insert_post_video(){
    if (document.getElementById('post_content') && document.getElementById('post_content').value == '') {
        document.getElementById('post_content').value = '晒视频';
    }
    //Element.toggle('post_form_video');
    //Element.hide('post_form_pic');
    jQuery("#post_form_video").toggle();
	jQuery("#post_form_pic").hide()
	if (document.getElementById('smiles_list').style.display == "") {
        var smileIndex = document.getElementById('smiles_list').style.zIndex || 0;
        document.getElementById('post_form_video').style.zIndex = parseInt(smileIndex) + 1;
    }
    else {
        document.getElementById('post_form_video').style.zIndex = 5;
    }
    
    document.getElementById('post_logo').value = '';
    document.getElementById('post_video_link').value = video_pmt;
}

function show_post_form_pmt(){
    fade_action_pmt('post_form_pmt', 3);
}

function fade_action_pmt(id, delay){
    new Effect.Fade(id, {
        delay: delay,
        duration: 1,
        from: 1,
        to: 0
    });
}

function check_post_form(){
    if (!check_content()) {
        return false;
    }
    
    //  if (!vvideo('post_video_link')) {
    //     return false;
    //  }
    if (document.getElementById("post_video_link").value == video_pmt) 
        document.getElementById("post_video_link").value = ""; 

    return true;
}

function select_pmt_ignore_tag(){
    document.getElementById('pmt_ignore_tag').value = ((document.getElementById('pmt_ignore_tag').value == '') ? '1' : '');
}


//////////// check post form ////////////////////


function check_content(){
    try {
        var statusStr = document.getElementById('post_content').value;
        if (jQuery.trim(statusStr) == "") {
            alert("您没有输入晒品");
            return false;
        }
		
		if (getStringBytes(statusStr) > 140) {
			alert("您输入的字符超过140个字啦");
			return false;
		}
        /*
		statusStr = trim(statusStr);
        var tag_name = statusStr.match(/#(.+?)#/);
        if (tag_name) {
            if (tag_name[1] == '自定义话题') {
                alert('请输入自定义话题');
                return false;
            }
            var len = getStringBytes(tag_name[1]);
            if (len < 2) {
                alert('自定义话题必须2个字以上');
                return false;
            }
            if (('[' + tag_name[1] + ']') == statusStr) {
                alert('请输入正文');
                return false;
            }
        }
        */
        return true;
        
    } 
    catch (e) {
    
    }
    
    return false;
}

function vvideo(obj){
    obj = document.getElementById(obj);
    var value = jQuery.trim(obj.value);
    //debugger;
    if (!value || value == video_pmt) {
        alert("输入不能为空");
        obj.value = "";
        return false;
    }//验证是否为空
    if (!/tudou|youku|sina|56|ku6/i.test(value)) {
        alert("只能输入优酷、土豆、新浪、QQ、酷6、56上的视频");
        obj.value = "";
        return false;
    };//验证是网址是否在白名单中
    if (!/^http/i.test(value) || //验证是否是http开始
    (!/\.swf/i.test(value) && !/tudou/i.test(value)) ||
    (!/\.swf/i.test(value) && !/www\.tudou\.com\/[lv]{1}/i.test(value))) {
    
        alert("请输入以.swf结尾的flash视频地址，不是页面地址，支持视频来源：优酷、土豆、新浪、QQ、56网、酷6");
        obj.value = "";
        return false;
    }
    $('#post_form_video').hide();
    return true;
}



function isYoukuAddress(s){
    var patrn = /v\.youku\.com\/v_show\/id_([^\.]*).html/;
    if (patrn.exec(s)) 
        return true;
    return false
}

function isku6Address(s){
    var patrn = /v\.ku6\.com\/show\/[a-zA-Z0-9,._!{}\?=&%#@;*:\+\-\|\/~$\^]*(\.html)/;
    if (patrn.exec(s)) 
        return true;
    return false
}

function IsURL(str_url){
    var re = new RegExp("^http:\/\/.{0,93}");
    if (re.test(str_url)) {
        return (true);
    }
    else {
        return (false);
    }
    return true;
}
////////////  select ids  /////////////

function select_hidden_tag_id(id, link, class_name){
    currents = document.getElementsByClassName(class_name + ' current');
    if (currents.length > 0) {
        currents[0].className = class_name;
    }
    document.getElementById(class_name).value = id;
    link.className = class_name + ' current';
}


////////////  age and tag /////////////

function show_custom_tags(){
    $('#custom_tags_layer').show();
}

function hide_custom_tags(){
    $('#custom_tags_layer').hide();
}

function select_custom_tags(){
    var tag_name = '自定义话题';
    select_sys_tag('', document.getElementById('custom_tags'));
    hide_custom_tags();
    document.getElementById('post_content').value = '#' + tag_name + '#' + document.getElementById('post_content').value.replace(/#(.+?)#/, '');
    searchKeyWords(tag_name, document.getElementById('post_content'));
}

function insert_sys_tag(tag_id, tag_name, link){
    document.getElementById('post_content').value = '#' + tag_name + '#' + document.getElementById('post_content').value.replace(/#(.+?)#/, '');
    select_sys_tag(tag_id, link);
    if (document.getElementById('custom_tags_layer').style.display != 'none') {
        hide_custom_tags();
    }
    if (tag_id == '') {
        searchKeyWords(tag_name, document.getElementById('post_content'));
    }
}

function select_sys_tag(tag_id, link){
    currents = document.getElementsByClassName('sys_tag current');
    if (currents.length > 0) {
        currents[0].className = 'sys_tag';
    }
    link.className = 'sys_tag current';
    document.getElementById('post_tag_id').value = tag_id;
}

function searchKeyWords(keyWord, txt){
    var str = "";
    var found = false;
    if (str == "" || (found && str.indexOf(keyWord) < 0)) {
        str = txt.value;
    }
    
    
    if (str.indexOf(keyWord) >= 0) {
        var index0 = str.indexOf(keyWord);
        var index1 = keyWord.length;
        if (jQuery.browser.msie) {
            var rng = txt.createTextRange();
            rng.collapse(true);
            rng.moveStart("character", index0);
            rng.moveEnd("character", index1);
            rng.select();
            str = str.replace(keyWord, String(Math.pow(10, index1) - 1));
            found = true;
        }
        else {
            txt.setSelectionRange(index0, index0 + index1)
        }
        txt.focus();
        
    }
}

///////////// post_logo ///////////////

function show_big_post_logo(id){
	$('#post_logo_' + id).hide();
	$('#post_big_logo_' + id).show();
	big = $('#post_picture_' + id)
	big.attr("src", big.attr('src1'))
}

function hide_big_post_logo(id){
	$('#post_logo_' + id).show();
	$('#post_big_logo_' + id).hide();
}

var post_images = {};

function rotate_post_logo(id){
    post_images[id] = post_images[id] || {};
    post_images[id]._left = post_images[id]._left || 0;
    post_images[id]._left++;
    rotate_picture(id, -90, null, 450);
}

function rotate_picture(id, angle, callback, maxWidth){
    var p = document.getElementById('post_picture_' + id);
    p.angle = ((p.angle == undefined ? 0 : p.angle) + angle) % 360;
    if (p.angle >= 0) {
        var rotation = Math.PI * p.angle / 180
    }
    else {
        var rotation = Math.PI * (360 + p.angle) / 180
    }
    var costheta = Math.cos(rotation);
    var sintheta = Math.sin(rotation);
    
    if (document.all && !window.opera) {
        var imgID = id;
        var canvas = document.createElement("img");
        canvas.src = p.src;
        canvas.height = p.height;
        canvas.width = p.width;
        if (!post_images[imgID]._initWidth) {
            post_images[imgID]._initWidth = canvas.width;
            post_images[imgID]._initHeight = canvas.height
        }
        
        if (canvas.height > maxWidth + 8) {
            canvas._w1 = canvas.width;
            canvas._h1 = canvas.height;
            canvas.height = maxWidth - 4;
            canvas.width = (canvas._w1 * canvas.height) / canvas._h1
        }
        canvas.style.filter = "progid:DXImageTransform.Microsoft.Matrix(M11=" + costheta + ",M12=" + (-sintheta) + ",M21=" + sintheta + ",M22=" + costheta + ",SizingMethod='auto expand')";
        setTimeout(function(){
            var left = post_images[imgID]._left, right = post_images[imgID]._right;
            if (right % 2 == 0 || left % 2 == 0 || Math.abs(right - left) % 2 == 0) {
                canvas.width = post_images[imgID]._initWidth - 4;
                canvas.height = post_images[imgID]._initHeight - 4
            }
            if ((left === 1 && !right) || (!left && right === 1)) {
                post_images[imgID]._width = canvas.width;
                post_images[imgID]._height = canvas.height
            }
            if (right > 0 && left > 0 && Math.abs(right - left) % 2 != 0) {
                canvas.width = post_images[imgID]._width - 4;
                canvas.height = post_images[imgID]._height - 4
            }
        }, 0);
    }
    else {
        var canvas = document.createElement("canvas");
        if (!p.oImage) {
            canvas.oImage = p
        }
        else {
            canvas.oImage = p.oImage
        }
        canvas.style.width = canvas.width = Math.abs(costheta * canvas.oImage.width) + Math.abs(sintheta * canvas.oImage.height);
        canvas.style.height = canvas.height = Math.abs(costheta * canvas.oImage.height) + Math.abs(sintheta * canvas.oImage.width);
        if (canvas.width > maxWidth) {
            canvas.style.width = maxWidth + "px"
        }
        var context = canvas.getContext("2d");
        context.save();
        if (rotation <= Math.PI / 2) {
            context.translate(sintheta * canvas.oImage.height, 0)
        }
        else {
            if (rotation <= Math.PI) {
                context.translate(canvas.width, -costheta * canvas.oImage.height)
            }
            else {
                if (rotation <= 1.5 * Math.PI) {
                    context.translate(-costheta * canvas.oImage.width, canvas.height)
                }
                else {
                    context.translate(0, -sintheta * canvas.oImage.width)
                }
            }
        }
        context.rotate(rotation);
        try {
            context.drawImage(canvas.oImage, 0, 0, canvas.oImage.width, canvas.oImage.height)
        } 
        catch (e) {
        }
        context.restore()
    }
    canvas.id = p.id;
    canvas.angle = p.angle;
    p.parentNode.replaceChild(canvas, p);
    if (callback && typeof callback === "function") {
        callback(canvas)
    }
}

function show_logo_previews(minWidth){
	if (minWidth == undefined)
		minWidth = 140;
	$(window).load(function(){
        var width = minWidth;
		var x = ($('#large_logo').width() - width) / 2;
        var y = ($('#large_logo').height() - width) / 2;
		if (x < 0 || y < 0) {
            return;
        }
        $('#large_logo').imgAreaSelect({
            minWidth: width,
            minHeight: width,
            aspectRatio: '1:1',
            x1: x,
            y1: y,
            x2: x + width,
            y2: y + width,
            handles: true,
            onSelectChange: logo_previews,
            onSelectBegin: logo_previews
        });
    });
}

function show_kid_logo_previews(){
    $(window).load(function(){
        var width = 140;
        var x = ($('#large_logo').width() - width) / 2;
        var y = ($('#large_logo').height() - width) / 2;
        if (x < 0 || y < 0) {
            return;
        }
        $('#large_logo').imgAreaSelect({
            minWidth: width,
            minHeight: width,
            aspectRatio: '1:1',
            x1: x,
            y1: y,
            x2: x + width,
            y2: y + width,
            handles: true,
            onSelectChange: kid_logo_previews,
            onSelectBegin: kid_logo_previews
        });
    });
}

function logo_previews(img, selection){
    show_preview(140, selection.width, selection.x1, selection.y1);
    show_preview(48, selection.width, selection.x1, selection.y1);
    show_preview(30, selection.width, selection.x1, selection.y1);
}

function kid_logo_previews(img, selection){
    show_preview(140, selection.width, selection.x1, selection.y1);
    show_preview(75, selection.width, selection.x1, selection.y1);
    show_preview(30, selection.width, selection.x1, selection.y1);
}

function show_preview(w, size, x, y){
    var scale = w / size;
    $('#logo' + w).css({
        width: Math.round(scale * $('#large_logo').width()) + 'px',
        height: Math.round(scale * $('#large_logo').height()) + 'px',
        marginLeft: '-' + Math.round(scale * x) + 'px',
        marginTop: '-' + Math.round(scale * y) + 'px'
    });
    $('input#logo_size').val(size);
    $('input#logo_left').val(x);
    $('input#logo_top').val(y);
}

function show_page_picture_preview(width, height){
    $(window).load(function(){
        var t_width = width;
        var t_height = height;
        var m_width = $('#large_logo').width();
        var m_height = $('#large_logo').height();
        if (width > m_width) {
            t_width = m_width;
        }
        if (height > m_height) {
            t_height = m_height;
        }
        var x = (m_width - t_width) / 2;
        var y = (m_height - t_height) / 2;
        if (x < 0 || y < 0) {
            return;
        }
        $('#large_logo').imgAreaSelect({
            minWidth: t_width,
            minHeight: t_height,
            x1: x,
            y1: y,
            x2: x + t_width,
            y2: y + t_height,
            aspectRatio: t_width + ':' + t_height,
            handles: true,
            onSelectChange: show_picture_preview,
            onSelectBegin: show_picture_preview
        });
    });
}

function show_picture_preview(img, selection){
    $('input#logo_width').val(selection.width);
    $('input#logo_height').val(selection.height);
    $('input#logo_left').val(selection.x1);
    $('input#logo_top').val(selection.y1);
}

//////////// clipboard /////////////////

var copytoclip = 1;
function copy_to_clipboard(theField, isalert){
    var tempval = document.getElementById(theField);
    if (navigator.appVersion.match(/\bMSIE\b/)) {
        tempval.select();
        if (copytoclip == 1) {
            therange = tempval.createTextRange();
            therange.execCommand("Copy");
            if (isalert != false) 
                alert("复制成功。现在您可以粘贴（Ctrl+v）这个地址发送给朋友。");
        }
        return;
    }
    else {
        alert("您使用的浏览器不支持此复制功能，请使用Ctrl+C或鼠标右键。");
        tempval.select();
    }
}


////////////  signup_form /////////////

function show_signup_kids(id){
    Element.hide('signup_kids_0');
    Element.hide('signup_kids_1');
    Element.hide('signup_kids_2');
    Element.hide('signup_kids_3');
    if (id == -1) {
        Element.hide('signup_hide_age');
    }
    else {
        Element.show('signup_kids_' + id);
        Element.show('signup_hide_age');
    }
    if (id == 1 && document.getElementById('user_signup_kids_count').value > 1) {
        return;
    }
    document.getElementById('user_signup_kids_count').value = id;
}

function show_signup_more_kids(id){
    Element.show('signup_kids_' + id);
    document.getElementById('user_signup_kids_count').value = id;
}

function hide_signup_more_kids(id){
    Element.hide('signup_kids_' + id);
    document.getElementById('user_signup_kids_count').value = id - 1;
}

////////////// kids ////////////////////

function show_kid_form(id){
    $('#user_kid_' + id).show();
    $('#user_kid_' + id + '_button').hide();
	$('#user_kids_button').show();
}

////////////  post_expand /////////////

function show_post_expand(action_name, post_id){
    var div_id = 'post_expand_' + post_id;
    if (document.getElementById(div_id).className == action_name) {
        document.getElementById(div_id).className = '';
		$("#" + div_id).hide("slow")
    }
    else {
		jQuery("#" + div_id).load('/ajax/' + action_name + '/' + post_id, {}, function(a, b, c){
			document.getElementById(div_id).className = action_name;
        	jQuery("#" + div_id).show("slow");
		})
        
    }
}



//////////// tools //////////////////

function add_favorite(url, text){
    if (document.all) {
        window.external.addFavorite(url, text);
    }
    else {
        if (window.sidebar) {
            window.sidebar.addPanel(text, url, "");
        }
    }
    return false;
};

function show_loadding(div, message){
    if (!message) 
        message = '正在加载...'
    document.getElementById(div).innerHTML = '<img src="/images/icons/load.gif"/><span class="load_pmt">' + message + '</span>';
}

function trim(str){
    var i = 0;
    var len = str.length;
    if (str == "") 
        return (str);
    j = len - 1;
    flagbegin = true;
    flagend = true;
    while (flagbegin == true && i < len) {
        if (str.charAt(i) == " ") {
            i = i + 1;
            flagbegin = true;
        }
        else {
            flagbegin = false;
        }
    }
    
    while (flagend == true && j >= 0) {
        if (str.charAt(j) == " ") {
            j = j - 1;
            flagend = true;
        }
        else {
            flagend = false;
        }
    }
    
    if (i > j) 
        return ("")
    
    trimstr = str.substring(i, j + 1);
    return trimstr;
}


function getStatusTextCharLengthMax(value){
    return 140;
}

function getStringBytes(value){
    if (value == null) 
        return 0;
	
	s = value;
    //s = s.replace(/[\u4e00-\u9fa5]/g, '__')
	s = s.replace(/[^\x00-\xff]/g, '__')
	return Math.ceil(s.length/2);
}

function updateStatusTextCharCounter(obj, text_pmt){
    var len_max = 140;
    var charCountLeftIndicator = document.getElementById(text_pmt);
    var len = getStringBytes(obj.value);
    var len_remain = len_max - len;
    
    charCountLeftIndicator.innerHTML = len_remain;
    
    updateTextContent(obj)
    
    if(len_remain<0){
    	charCountLeftIndicator.innerHTML=0-len_remain;
    	//debugger;
    	charCountLeftIndicator.previousSibling.data="已超出";
    	charCountLeftIndicator.parentNode.style.color="red";
    }else{
    	charCountLeftIndicator.innerHTML=len_remain;
    	charCountLeftIndicator.previousSibling.data="还可以输入";
    	charCountLeftIndicator.parentNode.style.color="#008800";
    }
};

function updateStatusTextContent(obj){
    updateTextContent(obj);
	if (parseInt(obj.style.height)-obj.scrollHeight != -4)
    	obj.style.height = obj.scrollHeight + 'px';
}

function updateTextContent(obj){
    var len_max = 140;
    var str = obj.value;
    var len = getStringBytes(str);
    if (len > len_max) {
        obj.value = str.substr(0, str.length - (len - len_max + 1));
    }
}

function init_platform_combos(){
    window.dhx_globalImgPath = "/javascripts/combo/imgs/";
}

function show_platform_combos(){
    dhtmlx.skin = "mama_pink";
    
    var age = dhtmlXComboFromSelect("search_post_age_id");
    // var tag = dhtmlXComboFromSelect("search_post_category_id");
    age.setSize(88);
    age.readonly(1);
}

function insert_face(insertStr){
    var obj = document.getElementById('post_content');
    if (document.all) {
        obj.focus();
        var range = document.selection.createRange();
        range.text = insertStr;
    }
    else {
        if (obj.setSelectionRange) {
            var rangeStart = obj.selectionStart;
            var rangeEnd = obj.selectionEnd;
            var temp1 = obj.value.substring(0, rangeStart);
            var temp2 = obj.value.substring(rangeEnd);
            obj.value = temp1 + insertStr + temp2;
			obj.selectionStart=(temp1 + insertStr).length;   
       	 	obj.selectionEnd=(temp1 + insertStr).length
        }
    }
    //Element.hide('smiles_list');
	jQuery("#smiles_list").hide();
}

function insert_topic(obj){
	var rangeStart = obj.selectionStart;
    var rangeEnd = obj.selectionEnd;
    var temp1 = obj.value.substring(0, rangeStart);
    var temp2 = obj.value.substring(rangeEnd);
    var insertStr = "##"
    obj.value = temp1 + insertStr + temp2;
	obj.selectionStart=(temp1 + insertStr).length - 1;   
    obj.selectionEnd=(temp1 + insertStr).length - 1
}

/////////////////////// upload //////////////////////////////

function init_upload_tools(book, uploadid, uploaduid){
    var upload;
    
    upload = new SWFUpload({
        upload_url: "/books/upload_pictures",
        post_params: {
            "book": book,
            "uploadid": uploadid,
            "uploaduid": uploaduid
        },
        
        file_size_limit: "5 MB",
        file_types: "*.jpg;*.png;*.gif;*.jpeg",
        file_types_description: "上传图片",
        file_upload_limit: "20",
        file_queue_limit: "0",
        
        file_dialog_start_handler: fileDialogStart,
        file_queued_handler: fileQueued,
        file_queue_error_handler: fileQueueError,
        file_dialog_complete_handler: complete_file_dialog_complete, //fileDialogComplete,
        upload_start_handler: uploadStart,
        upload_progress_handler: uploadProgress,
        upload_error_handler: uploadError,
        upload_success_handler: uploadSuccess,
        upload_complete_handler: uploadComplete,
        queue_complete_handler: complete_upload_page_pictures,
        button_image_url: "/javascripts/swfupload/button.png",
        button_placeholder_id: "spanButtonPlaceholder",
        button_width: 101,
        button_height: 22,
        
        flash_url: "/javascripts/swfupload/swfupload.swf",
        
        
        custom_settings: {
            progressTarget: "fsUploadProgress",
            cancelButtonId: "btnCancel"
        },
        
        debug: false
    });
    
}

function complete_file_dialog_complete(files_num, files_queue_num){
    try {
        if (this.getStats().files_queued > 0) {
            document.getElementById(this.customSettings.cancelButtonId).disabled = false;
        }
        if (files_queue_num + parseInt(document.getElementById('book_select_posts_count').innerHTML) > 66) {
            alert('对不起！目前宝贝图书最多只能制作66页！');
        }
        else {
            this.startUpload();
        }
    } 
    catch (ex) {
        this.debug(ex);
    }
}

function complete_upload_page_pictures(){
    window.location = '/books/import_confirm/' + document.getElementById('user_book_id').value;
}


function save_book_pages_sort(){
    var book_pages = document.getElementsByClassName('book_sort');
    var book_page_ids = new Array();
    for (var i = 0; i < book_pages.length; i++) {
        book_page_ids.push(book_pages[i].id);
    }
    document.getElementById('book_pages_sort').value = book_page_ids.join(',');
    document.getElementById('book_pages_sort_form').submit();
}

function init_book_pages_order(){
    Sortable.create('user_book', {
        tag: 'li',
        only: 'book_sort',
        constraint: false,
        handle: 'handle'
    });
}

function edit_page_text(id){
    Element.hide('page_content' + id);
    Element.show('page_text_area' + id);
    Element.hide('page_edit_button' + id);
    Element.show('page_save_button' + id);
}

function cancel_page_text(id){
    Element.show('page_content' + id);
    Element.hide('page_text_area' + id);
    Element.show('page_edit_button' + id);
    Element.hide('page_save_button' + id);
}

function save_page_text(id){
    document.getElementById('page_text_form' + id).onsubmit();
}

function select_rate_star(post_id, id){
    new Ajax.Updater('post_rate_view_' + post_id, '/ajax/select_rate_star/' + post_id + '?rate=' + id, {
        asynchronous: true,
        evalScripts: true
    });
}

function show_rate_star(post_id, id){
    var rate_star_words = ['很差', '较差', '还行', '推荐', '力荐'];
    for (var i = 1; i <= id; i++) {
        document.getElementById('rate_star_' + post_id + '_' + i).src = '/images/event/sth.gif';
    }
    document.getElementById('rate_word_' + post_id).innerHTML = rate_star_words[id - 1];
}

function hide_rate_star(post_id, id){
    for (var i = 1; i <= 5; i++) {
        document.getElementById('rate_star_' + post_id + '_' + i).src = '/images/event/nst.gif';
    }
}

/*对于ie下select不能添加border的问题*/
function select_req(c){
    var sc = document.getElementById(c);
    var selects = sc.getElementsByTagName("select");
    var errarr = [];
    for (var i = 0, l = selects.length; i < l; i++) {
        var select = selects[i];
        if (!select[select.selectedIndex].value) {
            errarr.push(select);
        }
    }
    
    if (errarr.length > 0) {
        Element.addClassName(sc, "error");
        TooltipManager.addTooltip(sc, "该项是必选项");
        return false;
    }
    else {
        sc.onmouseout = sc.onmouseover = null;
        Element.removeClassName(sc, "error");
        return true;
    }
}

function small_vote_click(id){
		if ($.trim($('#update_votepost_' + id).text()) == "") {
			$.ajax({
				url: "/ajax/get_post_vote/" + id,
				async: false,
				success: function(html){
					$('#update_votepost_' + id).html(html)
				}
			});
		}
		$('#vpost_' + id).hide('slow');
		$('#vpostdetail_' + id).show('show');
	}
	

    $.confirm = function(params){
        
        if($('#confirmOverlay').length){
            // A confirm is already shown on the page:
            return false;
        }
        
        var buttonHTML = '';
        $.each(params.buttons,function(name,obj){
            
            // Generating the markup for the buttons:
            
            buttonHTML += '<a href="#" class="button '+obj['class']+'">'+name+'<span></span></a>';
            
            if(!obj.action){
                obj.action = function(){};
            }
        });
        
        var markup = [
            '<div id="confirmOverlay">',
            '<div id="confirmBox"><div id="confirmBox_inner">',
            '<h1>',params.title,'</h1>',
            '<p>',params.message,'</p>',
            '<div id="confirmButtons">',
            buttonHTML,
            '<div class="clear"></div></div></div></div></div>'
        ].join('');
        
        $(markup).hide().appendTo('body').fadeIn();
        
        var buttons = $('#confirmBox .button'),
            i = 0;

        $.each(params.buttons,function(name,obj){
            buttons.eq(i++).click(function(){
                
                // Calling the action attribute when a
                // click occurs, and hiding the confirm.
                
                obj.action();
                $.confirm.hide();
                return false;
            });
        });
    }

    $.confirm.hide = function(){
        $('#confirmOverlay').fadeOut(function(){
            $(this).remove();
        });
    }

function mms_confirm(title, text, url)
{
	$.confirm({
            'title'     : title,
            'message'   : text,
            'buttons'   : {
                '确定'   : {
                    'class' : 'button_link',
                    'action': function(){
                        elem.slideUp();
                    }
                },
                '取消'    : {
                    'class' : 'button_link',
                    'action': function(){}  // Nothing to do in this case. You can as well omit the action property.
                }
            }
        });	
}

/////////////////////////////
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

//////////////////////////////////////////////////////////转晒
var forwardshine_dialog = null;
function forwardshine(id, follow_obj){
	var url = "/ajax/new_forward_post/" + id;
	forwardshine_dialog = $.dialog({id: 'dialog1', follow: follow_obj, title: "转晒"});// 初始化一个带有loading图标的空对话框
	forwardshine_dialog.follow_obj = follow_obj;
	jQuery.ajax({
		url: url,
	    success: function (data) {
	        forwardshine_dialog.content(data).follow(follow_obj);// 填充对话框内容
	    }
	});
}

function show_url_box(url, title, width, height){
	var url = url;
	forwardshine_dialog = $.dialog({id: 'dialog1', title: title, width: width, height: height}).lock();// 初始化一个带有loading图标的空对话框
	jQuery.ajax({
		url: url,
	    success: function (data) {
	        forwardshine_dialog.content(data);// 填充对话框内容
	    }
	});
	return forwardshine_dialog;
}

function ajax_box(params){
	params.id = "dialog1"
	forwardshine_dialog = $.dialog(params)
	if (params.hideTitle)
		forwardshine_dialog.hideTitle();
		
	$.ajax({
		url: params.url,
		success: function(data){
			forwardshine_dialog.content(data).follow(params.follow)
		}
	})
}

function hide_box(){
	forwardshine_dialog.close()
}

function show_confirm_box(title, url, callback, follow_obj){
	forwardshine_dialog = $.dialog({id: 'dialog1', title: title, follow: follow_obj, content: title, 
		button: [
			{id: 'ok', value: '确认', focus: true, callback: function(){
					forwardshine_dialog.close();
                    jQuery.ajax({
						url: url,
					    success: function (data) {
					    	callback();
					    	forwardshine_dialog.content(data).follow(follow_obj).time(2000);// 填充对话框内容
					    }
					});

					return false;
				}
			}, 
			{value: '取消'}
		]}).hideTitle();// 初始化一个带有loading图标的空对话框
}

function reset_box(width, height){
	if (forwardshine_dialog){
		forwardshine_dialog.width = width;
		forwardshine_dialog.height = height;
	}
}
