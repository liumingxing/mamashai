// 表情
$(function(){
    $('#insert_post_smiles').toggle(function(){
		$('#smiles_list').show();
        if (document.getElementById('post_form_pic').style.display == "" || (document.getElementById('post_form_video') && document.getElementById('post_form_video').style.display == "")) {
            var otherIndex = Math.max(parseInt(document.getElementById('post_form_pic').style.zIndex), parseInt(document.getElementById('post_form_video') && document.getElementById('post_form_video').style.zIndex)) || 0;
            document.getElementById('smiles_list').style.zIndex = parseInt(otherIndex) + 1;
        }
        else {
            document.getElementById('smiles_list').style.zIndex = 0;
        }
    }, function(){
        $('#smiles_list').hide();
    });
});

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
        }
    }
    $('#smiles_list').hide();
}

// 视频
function insert_post_video(){
	alert(1);
    if (document.getElementById('post_content') && document.getElementById('post_content').value == '') {
        document.getElementById('post_content').value = '晒视频';
    }
    $('#post_form_video').toggle();
    $('#post_form_pic').hide();
    if (document.getElementById('smiles_list').style.display == "") {
        var smileIndex = document.getElementById('smiles_list').style.zIndex || 0;
        document.getElementById('post_form_video').style.zIndex = parseInt(smileIndex) + 1;
    }
    else {
        document.getElementById('post_form_video').style.zIndex = 0;
    }
    
    document.getElementById('post_logo').value = '';
    document.getElementById('post_video_link').value = video_pmt;
}

function vvideo(obj){
	alert(11);
    obj = document.getElementById(obj);
    var value = obj.val();
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
    
        alert("请输入视频flash地址，不是页面地址，支持视频来源:优酷、土豆、新浪、QQ、56网、酷6");
        obj.value = "";
        return false;
    }
    Element.hide('post_form_video');
    return true;
}

//  提示

function show_ddrivetip(obj){
    var id = obj.id;
    if (id == 'tip_follow_users') {
        ddrivetip('我对哪些人感兴趣，可以直接关注她！无须得到对方确认，我就是她粉丝啦！可以及时看到她的晒品！');
    }
    if (id == 'tip_fans_users') {
        ddrivetip('哪些人对我感兴趣，可以关注我成为我的粉丝！这样，他们会及时看到我的晒品呢。每增加1个粉丝获1个积分。');
    }
    if (id == 'tip_my_posts') {
        ddrivetip('我晒出来的东东，关联的博客，发布的提问，都是我的晒品啦。关注我的人将及时分享它们：）');
    }
    if (id == 'tip_toggle_question') {
        ddrivetip('有一肚子疑问？来这里提问吧！悬赏积分，让其他有经验的妈妈爸爸快点帮帮我！回答有机会获得悬赏积分。');
    }
    if (id == 'tip_toggle_share') {
        ddrivetip('在输入框内写出我想晒的：晒宝贝晒经验自由晒？都可以！');
    }
    if (id == 'post_content' && document.getElementById('post_content').value == '' && !document.getElementById('post_score')) {
        ddrivetip('在输入框内写出我想晒的：晒宝贝晒经验自由晒？都可以！');
    }
    if (id == 'post_content' && document.getElementById('post_content').value == '' && document.getElementById('post_score')) {
        ddrivetip('有一肚子疑问？来这里提问吧！悬赏积分，让其他有经验的妈妈爸爸快点帮帮我！回答有机会获得悬赏积分。');
    }
    if (id == 'post_content' && document.getElementById('post_content').value == '' && document.getElementById('spot_name')) {
        ddrivetip('适宜孩子的地点：饮食？玩乐？出行？教育？晒出来，大家分享，大家受益！');
    }
    if (id == 'tip_post_logo') {
        ddrivetip('上传我喜欢的图片！支持jpg、jpeg、png、gif、bmp 格式，大小不超过5M');
    }
    if (id == 'tip_post_video') {
        ddrivetip('输入我发布于优酷、土豆、新浪、QQ、Youtube、酷6、56网的视频flash地址，即可插入视频！');
    }
}

function init_ddrivetip(id){
    if (document.getElementById(id)) {
        //Event.observe(id, 'mouseover', show_ddrivetip);
        document.getElementById(id).onmouseout = hideddrivetip;
    }
}

function ddrivetip(thetext, thewidth, thecolor){
    if (ns6 || ie) {
        if (typeof thewidth != "undefined") 
            tipobj.style.width = thewidth + "px";
        if (typeof thecolor != "undefined" && thecolor != "") 
            tipobj.style.backgroundColor = thecolor;
        tipobj.innerHTML = thetext;
        enabletip = true;
        return false;
    }
}

document.onmousemove = positiontip;

Event.observe(window, "load", function(){
    for (var i = 0; i < ddrivetips_array.length; i++) {
        init_ddrivetip(ddrivetips_array[i]);
    }
    is_init_tips = true;
});

