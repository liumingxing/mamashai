            if (typeof BookApp === "undefind") 
                var BookApp = {};
(function($){
    $(function(){
        // 初始化一个page_form对象保存所有当前编辑页的数据
        // 初始化各个按钮
        // 选择当前图书的第一页
        // ajax请求选择页的数据
        // 新建图书页的时候把 page_form reset
        
        BookApp = {
            crop_img_container: null,
            bookEditArea: $("#edit_book_id"),
            bookPageList: $("#mms_pages"),
            current_page_html: {},
            current_page_image: {},
            current_page_sys: {},
            bookDialog: function(opt){
                var opt = opt || {};
                return new MMS.ui.Dialog("book_dialog", {
                    width: "239px",
                    close: true,
                    fixCenter: true,
                    modal: true,
                    buttons: null
                });
            }(),
            delBookPage: function(obj){
                $(obj).parents(".books_page").fadeOut("slow", function(){
                    $(this).remove();
                    BookApp.calpages();
                });
            },
            delPic: function(obj){
                $(obj).parents(".picture_eidt").fadeOut("slow", function(){
                    $(this).remove();
                });
            },
            newPage: function(){
                var children = $("#mms_sortable").children();
                var si = children.length;
                
                var newPage = $("#mms_sortable").append('<div class="books_page" page_id="mms_new_page">\
<div class="pic"><a href="javascript:void(0)"><img src="/images/baby_books/layout/layout' + $("#edit_book_id").data("current_page_layout_id") + '.png"></a></div>\
<div class="title"><span class="cover">第' +
                                                        (si + 1) +
                                                        '页</span><span onclick="BookApp.delBookPage(this);" style="display: none;" class="delete"><a href="javascript:void(0)"><img src="/images/books/del_01.gif"></a></span></div>\
</div>');
                
                
                $('#mms_pages div.pic').removeClass('current');
                $('#mms_sortable');
                newPage.find('.pic:last').addClass('current');
                BookApp.savePage();
            },
            newPageDialog: function(){
                var save = function(){
                    BookApp.savePage();
                    $("#mms_dialog").dialog("close");
                    $('#edit_book_id').data('current_page_id', 'mms_new_page');
                    BookApp.listLayout();
                };
                var not_save = function(){
                    $("#mms_dialog").dialog("close");
                    $('#edit_book_id').data('current_page_id', 'mms_new_page');
                    BookApp.listLayout();
                };
                var cancel = function(){
                    $("#mms_dialog").dialog("close");
                };
                
                if ($('#edit_book_id').data('is_not_saved') == 'is_not_saved') {
                    BookApp.ternary_dialog({
                        title: '妈妈晒宝贝图书',
                        msg: "当前编辑的宝贝图书页尚未保存，是否保存？",
                        one: save,
                        two: not_save,
                        three: cancel
                    });
                }
                else {
                    $('#edit_book_id').data('current_page_id', 'mms_new_page');
                    BookApp.listLayout();
                }
            },
            sortBookpage: function(c){
                c.sortable({
                    tolerance: 'pointer',
                    revert: true,
                    stop: function(event, ui){
                        BookApp.calpages();
                    },
                    update: function(){
                        $.post("/baby_books/sort_pages/" + $('#edit_book_id').attr('book_id'), $("#mms_sortable").sortable("serialize", {
                            attribute: 'serialize_id',
                            key: "page_id[]"
                        }));
                    }
                });
            },
            showOrHideDelIcon: function(o){
                var show = function(){
                    $(this).find(".delete").show();
                };
                var hide = function(){
                    $(this).find(".delete").hide();
                };
                o.unbind('hover');
                o.hover(show, hide);
            },
            //重新计算页数
            calpages: function(){
                $.each($("#mms_sortable .cover"), function(i, o){
                    $(o).html("第" + (i + 1) + "页");
                });
            },
            previewPage: function(){
                var preview_page_id = $('#mms_pages div.current').parent().attr('page_id');
                $.get('/baby_books/show_preview_page/' + preview_page_id, function(data){
                    $("#mms_dialog").empty();
                    $("#mms_dialog").append(data);
                    $("#mms_dialog").dialog({
                        title: "预览本页",
                        modal: true,
                        width: 900,
                        height: 700,
                        position: 'center',
                        close: null,
                        buttons: null
                    });
                });
            },
            editMp3: function(){
                var mp3 = $("#mms_mp3_btn").attr('mp3');
                if (mp3 == '') {
                    mp3 = 'http://'
                }
                $("#mms_dialog").empty();
                $("#mms_dialog").append('<div style="margin:10px;">请输入背景音乐的网址（只限mp3格式）：<br/><br/> <input type="text" id="book_mp3_input" style="width:250px;" value="' + mp3 + '"/></div>');
                $("#mms_dialog").dialog({
                    title: "添加背景音乐",
                    modal: true,
                    width: 350,
                    height: 200,
                    position: 'center',
                    close: null,
                    buttons: {
                        "保存": function(){
                            var oPage = {};
                            oPage['book_id'] = $('#edit_book_id').attr('book_id');
                            oPage['mp3'] = $('#book_mp3_input').attr('value');
                            $.post('/baby_books/update_mp3', oPage, function(data){
				$("#mms_mp3_btn").attr('mp3',oPage['mp3']);
                                $("#mms_dialog").dialog("close");
                            });
                        },
                        "取消": function(){
                            $("#mms_dialog").dialog("close");
                        }
                    }
                });
            },
            sharePage: function(){
                if ($('#edit_book_id').data('current_page_id') == 'mms_no_page') {
                    alert('当前没有编辑任何页');
                    return;
                };
                var share_page_id = $('#edit_book_id').data('current_page_id');
                $.get('/baby_books/pub_page_post/' + share_page_id, function(data){
                    
                });
            },
            savePage: function(){
                var oPage = {};
                oPage['book_id'] = $('#edit_book_id').attr('book_id');
                oPage['layout_id'] = $('#edit_book_id').data('current_page_layout_id');
                var page = $('#edit_book_id > div');
                var container_offset = page.offset();
                var p_w = 148 / page.width();
                var p_h = 210 / page.height();
                
                if (page != undefined) {
                    oPage['page_id'] = $('#edit_book_id').data('current_page_id');
                    var image_url = page.css('background-image');
                    oPage['bg_html_image'] = image_url;
                    oPage['bg_color'] = page.css('background-color');
                    oPage['boxs'] = [];
                    page.children('div[tp]').each(function(i, el){
                        var box = $(el);
                        oBox = {};
                        oBox['tp'] = box.attr('tp');
                        oBox['w'] = parseInt(box.width() * p_w);
                        oBox['h'] = parseInt(box.height() * p_h);
                        oBox['font_size'] = box.attr('font_size');
                        oBox['font_weight'] = box.attr('font_weight');
                        oBox['font_color'] = box.css('color');
                        oBox['bg_color'] = box.css('background-color');
                        var offset = box.offset();
                        var left = offset.left;
                        var top = offset.top;
                        oBox['x'] = parseInt((left - container_offset.left) * p_w);
                        oBox['y'] = parseInt((top - container_offset.top) * p_h);
                        oBox['layer'] = 1;
                        switch (oBox['tp']) {
                        case 'image':
                            oBox['original_src'] = box.children('img').attr('original_src');
                            oBox['src'] = box.children('img').attr('src');
                            break;
                        case 'text':
                            oBox['content'] = box.html();
                            break;
                        case 'mixed':
                            oBox['content'] = box.html();
                            break;
                        case 'sys':
                            oBox['attr_name'] = box.attr('attr_name');
                            oBox['attr_value'] = box.html();
                            break;
                        }
                        oPage['boxs'].push(oBox);
                    });
                    if (oPage['page_id'] != 'mms_new_page') {
                        oPage['_method'] = 'put';
                        $.post('/baby_book_pages/' + oPage['page_id'], oPage,function(data){
                            var result = data.split("==>>");
                            var page_id = $.trim(result[0]);
                            var thumb_url = $.trim(result[1]);
                            $('#mms_pages div[page_id=' + page_id + '] img').attr('src', thumb_url+"?"+new Date().getTime().toString());         
                        });
                    }
                    else {
                        $.post('/baby_book_pages/create', oPage, function(data){
                            var result = data.split("==>>");
                            var page_id = $.trim(result[0]);
                            var thumb_url = $.trim(result[1]);
                            $('#mms_pages div[page_id=mms_new_page]').attr('layout_id', $("#edit_book_id").data("current_page_layout_id"));
                            $('#mms_pages div[page_id=mms_new_page]').attr('id', "mms_page_" + page_id);
                            $('#mms_pages div[page_id=mms_new_page]').attr('page_id', page_id);
                            $('#edit_book_id').data('current_page_id', page_id);
                            
                            $("div[page_id]").unbind('click');
                            $("div[page_id]").click(BookApp.editPage);
                            $('#mms_pages div[page_id=' + page_id + '] img').attr('src', thumb_url);         
                        });
                    };
                    $('#edit_book_id').data('is_not_saved', 'is_saved');
                }
                else {
                    alert('当前没有编辑任何页');
                }
            },
            selectLayout: function(layout_id){
                var bg_image, bg_pdf_image, bg_html_image
                var page_id = $('#edit_book_id').data('current_page_id');
                $('#edit_book_id').data('layout_selected', true);
                if (page_id == 'mms_no_page') {
                    alert('当前没有编辑任何页');
                    return;
                };
                if ($('#edit_book_id > div').length > 0) {
                    $('#edit_book_id > div').children('div[tp=text]').each(function(i, data){
                        BookApp.current_page_html[i] = $(data).html();
                    });
                    $('#edit_book_id > div').children('div[tp=image]').each(function(i, data){
                        BookApp.current_page_image[i] = $(data).html();
                    });
                    $('#edit_book_id > div').children('div[tp=sys]').each(function(i, data){
                        var attr_name = $(data).attr('attr_name');
                        BookApp.current_page_sys[attr_name] = $(data).html();
                    });
                    bg_image = $('#edit_book_id > div').css('background-image');
                    bg_pdf_image = $('#edit_book_id > div').attr('bg_pdf_image');
                    bg_html_image = $('#edit_book_id > div').attr('bg_html_image');
                };
                $("#edit_book_id").data("current_page_layout_id", layout_id);
                $.get('/baby_book_layouts/' + layout_id + '/select', function(data){
                    var layout = $(data);
                    if (page_id != 'mms_new_page') {
                        layout.children('div[tp=text]').each(function(i, box){
                            if (BookApp.current_page_html[i] != undefined) {
                                $(box).empty();
                                $(box).append(BookApp.current_page_html[i]);
                            }
                        });
                        layout.children('div[tp=image]').each(function(i, box){
                            if (BookApp.current_page_image[i] != undefined) {
                                $(box).empty();
                                $(box).append(BookApp.current_page_image[i]);
                            }
                        });
                        layout.children('div[tp=sys]').each(function(i, box){
                            var attr_name = $(box).attr('attr_name');
                            if (BookApp.current_page_sys[attr_name] != undefined) {
                                $(box).empty();
                                $(box).append(BookApp.current_page_sys[attr_name]);
                            }
                        });
                    };
                    
                    $('#edit_book_id').empty();
                    $('#edit_book_id').append(layout);
                    BookApp.initDropBox();
                    $('#edit_book_id').data('is_not_saved', 'is_not_saved');
                    $("#mms_dialog").dialog("close");
                    
                    $('#edit_book_id > div').attr('bg_html_image', bg_html_image);
                    $('#edit_book_id > div').attr('bg_pdf_image', bg_pdf_image);
                    $('#edit_book_id > div').css('background-image', bg_image);
                    // need fix
                    var src = "/images/baby_books/layout/layout" + layout_id + ".png";
                    $('#mms_pages div[page_id=' + page_id + '] img').attr('src', src);
                    
                    //如果是新创建页就再选择背景
                    if ($('#edit_book_id').data('current_page_id') == 'mms_new_page') {
                        BookApp.listBackground();
                    };
                })
            },
            listLayout: function(){
                if ($('#edit_book_id').data('current_page_id') == 'mms_no_page') {
                    alert('当前没有编辑任何页');
                    return;
                };
                $("#mms_dialog").empty();
                $('#edit_book_id').data('layout_selected', false);
                $.get('/baby_book_layouts/list/' + $('#edit_book_id').data('current_page_id'), function(data){
                    $("#mms_dialog").append(data);
                    $("#mms_dialog").dialog({
                        title: "选择布局",
                        modal: true,
                        position: 'center',
                        width: 460,
                        height: 400,
                        close: function(){
                            if ($('#edit_book_id').data('current_page_id') == 'mms_new_page' && $('#edit_book_id').data('layout_selected') == false) {
                                var is_continue = confirm('新建页面必须选择一个布局，继续创建页面选择确定，放弃创建页面选择取消。');
                                if (is_continue) {
                                    BookApp.listLayout();
                                }
                            };
                            $('#mms_dialog').unbind('dialogclose');
                        },
                        buttons: null
                    });
                    $('img[layout_id]').click(function(){
                        BookApp.selectLayout($(this).attr('layout_id'));
                    });
                    $("#mms_layout_tabs").tabs();
                });
            },
            selectBackground: function(bg_image, bg_pdf_image){
                if ($('#edit_book_id').data('current_page_id') == 'mms_no_page') {
                    alert('当前没有编辑任何页');
                    return;
                };
                $('#edit_book_id > div').css("background-image", 'url(' + bg_image + ')');
                $('#edit_book_id > div').data("bg_pdf_image", bg_pdf_image);
                $('#edit_book_id > div').data("bg_html_image", bg_image);
                $('#edit_book_id').data('is_not_saved', 'is_not_saved');
                $('#edit_book_id').data('selected_background', true);
                
                //如果是新创建页就立刻左侧创建页
                //  已经移到dialog的close event function中判断
                if ($('#edit_book_id').data('current_page_id') == 'mms_new_page') {
                    BookApp.newPage();
                };
                
                $("#mms_dialog").dialog("close");
            },
            listBackground: function(){
                var page_id = $('#edit_book_id').data('current_page_id');
                if ($("#mms_pages div[page_id=" + page_id + "]").attr("is_coverpage") == "true") {
                    alert('封面封底页不能选择背景。');
                    return;
                };
                
                $("#mms_dialog").empty();
                var theme_id = $('#mms_pages').attr('theme_id');
                $('#edit_book_id').data('selected_background', false);
                $.get('/baby_book_themes/list_thumbs/' + theme_id, function(data){
                    $("#mms_dialog").append(data);
                    $("#mms_dialog").dialog({
                        title: "选择背景",
                        modal: true,
                        position: 'center',
                        width: 430,
                        height: 400,
                        close: function(){
                            if ($('#edit_book_id').data('current_page_id') == 'mms_new_page' && $('#edit_book_id').data('selected_background') == false) {
                                $('#edit_book_id').data('is_not_saved', 'is_saved');
                                $('#edit_book_id > div').css("background-image", 'url()');
                                $('#edit_book_id > div').data("bg_pdf_image", '');
                                $('#edit_book_id > div').data("bg_html_image", '');
                                BookApp.newPage();
                            };
                            $('#mms_dialog').unbind('dialogclose');
                        },
                        buttons: null
                    });
                    $('img[bg_image]').click(function(){
                        BookApp.selectBackground($(this).attr('bg_image'), $(this).attr('bg_pdf_image'));
                    });
                });
            },
            show_picture_cropper: function(img_src, img_container, pic_id){
                BookApp.crop_img_container = img_container;
                $.get('/baby_books/show_picture_cropper?img=' + img_src + '&width=' + img_container.width() + '&height=' + img_container.height() + '&pic_id=' + pic_id + '&page_id=' + $('#edit_book_id').data('current_page_id'), function(data){
                    $("#mms_dialog").empty();
                    $("#mms_dialog").append($(data));
                    $("#mms_dialog").dialog({
                        title: '裁剪图片',
                        position: 'center',
                        modal: true,
                        width: 590,
                        height: 620,
                        buttons: null
                    });
                });
            },
            display_crop_picture: function(img_src){
                $("#mms_dialog").dialog("close");
                BookApp.crop_img_container.html("<img src='" + img_src + "' style='width:" + BookApp.crop_img_container.width() + "px;height:" + BookApp.crop_img_container.height() + "px;' />");
            },
            initDropBox: function(){
                $("div[tp^='image']").css('overflow', 'hidden');
                $("div[tp^='text']").css('overflow', 'hidden');
                
                //定义可以放置拖拽图片的东西
                //debugger;
                $("div[tp^='image']").droppable({
                    accept: '.scpic',
                    drop: function(event, ui){
                        img_src = ui.draggable.find('.pic img').attr('original_src');
                        pic_id = ui.draggable.find('.pic img').attr('pic_id');
                        $(this).html("<img src='" + img_src + "' />");
                        $('#edit_book_id').data('is_not_saved', 'is_not_saved');
                        BookApp.show_picture_cropper(img_src, $(this), pic_id);
                    }
                });
                
                
                //定义可以放置拖拽文字的东西
                $("div[tp^='text']").droppable({
                    accept: '.text_edit',
                    drop: function(event, ui){
                        $(this).html(ui.draggable.find('.text').text());
                        $('#edit_book_id').data('is_not_saved', 'is_not_saved')
                    }
                });
                $("div[tp^='sys'][attr_name='name']").click(function(){
                    BookApp.editText($(this));
                });
                $("div[tp^='sys'][attr_name='author2']").click(function(){
                    BookApp.editText($(this));
                });
                $("div[tp^='sys'][attr_name='author1']").click(function(){
                    BookApp.editText($(this));
                });
                $("div[tp^='text']").click(function(){
                    BookApp.editText($(this));
                });
                $("div[tp^='sys'][attr_name='author2']").click(function(){
                    BookApp.editText($(this));
                });
                $('#edit_book_id > div').css('margin', 'auto');
                $('#edit_book_id > div').css('border', '1px solid');
                
            },
            editText: function(edit_area){
                $("#mms_dialog").empty();
                var org_text = $.trim(edit_area.html());
                var text;
                if ($.browser.msie) {
                    text = org_text.replace(/< *[bB][rR] *\/?>/g, '\r\n');
                }
                else {
                    text = org_text.replace(/< *[bB][rR] *\/?>/g, '\n');
                }
                $("#mms_dialog").append($("<textarea class='mms_text_area' />").append(text));
                $("#mms_dialog").append("<br /><input type='checkbox' id='mms_as_post_chk' /> 发为晒品");
                $("#mms_dialog").dialog({
                    title: '编辑文字',
                    modal: true,
                    position: 'center',
                    width: 450,
                    height: 390,
                    buttons: {
                        "确定": function(){
                            edit_area.empty();
                            var area_text = $("#mms_dialog textarea").get(0).value;
                            if($("#mms_as_post_chk").attr('checked')){
                                $.post("/home/create_post",{'post':{'is_book':true,
                                                                    'long_content':area_text}})
                            }
                            area_text = area_text.replace('<', '&lt;');
                            area_text = area_text.replace('<', '&gt;');
                            if ($.browser.msie) {
                                area_text = area_text.replace(/\r\n/g, "<br />");
                            }
                            else {
                                area_text = area_text.replace(/\n/g, "<br />");
                            }
                            edit_area.append(area_text);
                            $("#mms_dialog").dialog("close");
                            $('#edit_book_id').data('is_not_saved', 'is_not_saved');
                        },
                        "取消": function(){
                            $("#mms_dialog").dialog("close");
                        }
                    }
                });
            },
            dragPic: function(){
                var $piccon = $("#pic_con_id");
                var $textcon = $("text_con_id");
                //定义可以拖拽的图片
                $('.picture_eidt', $piccon).draggable({
                    revert: 'invalid', // when not dropped, the item will revert back to its initial position
                    cursor: 'move',
                    zIndex: 1000,
                    helper: 'clone'
                });
                
                
            },
            ternary_dialog: function(opt){
                $("#mms_dialog").empty();
                $("#mms_dialog").append("<p>" + opt["msg"] + "</p>")
                $("#mms_dialog").dialog({
                    title: opt['title'],
                    modal: true,
                    width: 260,
                    height: 150,
                    position: 'center',
                    buttons: {
                        '取消': opt['three'],
                        '不保存': opt['two'],
                        '保存': opt['one']
                    }
                });
            },
            editPage: function(){
                var me = this;
                var edit = function(me){
                    var page_id = $(me).attr('page_id');
                    if (page_id == undefined) {
                        $("#mms_pages").children().find('.pic').removeClass('current');
                        $(me).find('.pic').addClass('current');
                    }
                    else {
                        var page = $(me);
                        $('#edit_book_id').data({
                            current_page_id: page_id
                        });
                        
                        $('#edit_book_id').load('/baby_book_pages/' + page_id, function(){
                            BookApp.initDropBox();
                            $("#mms_pages").children().find('.pic').removeClass('current');
                            page.find('.pic').addClass('current');
                        });
                    }
                    BookApp.current_page_image = null;
                    BookApp.current_page_html = null;
                    BookApp.current_page_sys = null;
                    BookApp.current_page_image = {};
                    BookApp.current_page_html = {};
                    BookApp.current_page_sys = {};
                };
                var save = function(){
                    BookApp.savePage();
                    $("#mms_dialog").dialog("close");
                    var page_id = $(me).attr('page_id');
                    var c_page_id = $('#edit_book_id').data('current_page_id');
                    if (page_id != c_page_id) 
                        edit(me);
                };
                var not_save = function(){
                    var page_id = $("#edit_book_id").data("current_page_id");
                    var layout_id = $('#mms_pages div[page_id=' + page_id + ']').attr('layout_id');
                    var src = "/images/baby_books/layout/layout" + layout_id + ".png";
                    $('#mms_pages div[page_id=' + page_id + '] img').attr('src', src);
                    edit(me);
                    $("#mms_dialog").dialog("close");
                };
                var cancel = function(){
                    $("#mms_dialog").dialog("close");
                };
                if ($('#edit_book_id').data('is_not_saved') == 'is_not_saved') {
                    BookApp.ternary_dialog({
                        title: '妈妈晒宝贝图书',
                        msg: "当前编辑的宝贝图书页尚未保存，是否保存？",
                        one: save,
                        two: not_save,
                        three: cancel
                    });
                }
                else {
                    edit(this);
                }
            },
            tab: function(t){
                $(t).addClass('current').siblings().removeClass("current");
                $("#" + $(t).attr("id") + "_content").css("display", "");
                $("#" + $(t).siblings().attr("id") + "_content").css("display", "none");
                //addClass('current');
            },
            removeCurrentPage: function(){
                if ($('#edit_book_id').data('current_page_id') == undefined || $('#edit_book_id').data('current_page_id') == 'mms_no_page' || $('#edit_book_id  > div').length > 1) {
                    alert('当前没有编辑任何页');
                    return;
                }
                if ($('#edit_book_id').data('current_page_id') == 'mms_new_page') {
                    $('#edit_book_id > div').remove();
                    $('#edit_book_id').data('current_page_id', 'mms_no_page');
                    $('#mms_pages div[page_id=mms_new_page]').remove();
                }
                else {
                    var page_id = $('#edit_book_id').data('current_page_id')
                    if ($('#mms_pages div[page_id=' + page_id + ']').attr("is_coverpage") != "true") {
                        $.post('/baby_book_pages/' + page_id, {
                            _method: 'delete'
                        }, function(){
                            $('#edit_book_id > div').remove();
                            $('#edit_book_id').data('current_page_id', 'mms_no_page');
                            $('#mms_pages div[page_id=' + page_id + ']').remove();
                        });
                    }
                    else {
                        alert('封面封底页不能删除')
                    }
                }
            },
            changePage: function(){
                switch ($(this).attr("id")) {
                case "mms_image_prev_btn":
                    var page = parseInt($("#sc_pic_content").attr("page"));
                    var page_count = parseInt($("#sc_pic_content").attr("page_count"));
                    if (page > 1) {
                        $("#mms_images_stuff_box").load("/baby_books/list_images_stuff", {
                            page: page - 1
                        }, function(){
                            $("#sc_pic_content").attr("page", page - 1);
                            BookApp.dragPic();
                            $("#mms_image_goto_btn").val(page-1);
                            $("#mms_images_stuff_page_counter").empty();
                            $("#mms_images_stuff_page_counter").append(page - 1 + "/" + page_count);
                        })
                    }
                    break;
                case "mms_image_next_btn":
                    var page = parseInt($("#sc_pic_content").attr("page"));
                    var page_count = parseInt($("#sc_pic_content").attr("page_count"));
                    if (page < page_count) {
                        $("#mms_images_stuff_box").load("/baby_books/list_images_stuff", {
                            page: page + 1
                        }, function(){
                            $("#sc_pic_content").attr("page", page + 1);
                            BookApp.dragPic();
                            $("#mms_image_goto_btn").val(page+1);
                            $("#mms_images_stuff_page_counter").empty();
                            $("#mms_images_stuff_page_counter").append(page + 1 + "/" + page_count);
                        })
                    }
                    break;
                case "mms_text_prev_btn":
                    var page = parseInt($("#mms_text_goto_btn").val());
                    var page_count =  $("#mms_text_goto_btn").children().length;
                    if (page > 1) {
                        $.post("/baby_books/list_texts_stuff", {
                            page: page - 1,
                            keyword: $("#mms_text_stuff_search_keyword").val()
                        }, function(data){
                            $("#mms_texts_stuff_box").next().remove();
                            $("#mms_texts_stuff_box").remove();
                            $("#sc_text_content").append(data);
                            BookApp.dragPic();
                            $("#mms_text_prev_btn").click(BookApp.changePage);
                            $("#mms_text_next_btn").click(BookApp.changePage);
                            $("#mms_text_goto_btn").change(BookApp.changePage);                            
                        })
                    }
                    break;
                case "mms_text_next_btn":
                    var page = parseInt($("#mms_text_goto_btn").val());
                    var page_count =  $("#mms_text_goto_btn").children().length;
                    if (page < page_count) {
                        $.post("/baby_books/list_texts_stuff", {
                            page: page + 1,
                            keyword: $("#mms_text_stuff_search_keyword").val()
                        }, function(data){
                            $("#mms_texts_stuff_box").next().remove();
                            $("#mms_texts_stuff_box").remove();
                            $("#sc_text_content").append(data);
                            BookApp.dragPic();
                            $("#mms_text_prev_btn").click(BookApp.changePage);
                            $("#mms_text_next_btn").click(BookApp.changePage);
                            $("#mms_text_goto_btn").change(BookApp.changePage);
                        })
                    }
                    break;
                case "mms_text_goto_btn":
                    var page = parseInt($(this).val());
                    var page_count = parseInt($("#sc_text_content").attr("page_count"));
                    $.post("/baby_books/list_texts_stuff", {
                        page: page,
                        keyword: $("#mms_text_stuff_search_keyword").val()
                    }, function(data){
                        $("#mms_texts_stuff_box").next().remove();
                        $("#mms_texts_stuff_box").remove();
                        $("#sc_text_content").append(data);
                        BookApp.dragPic();
                        $("#mms_text_prev_btn").click(BookApp.changePage);
                        $("#mms_text_next_btn").click(BookApp.changePage);
                        $("#mms_text_goto_btn").change(BookApp.changePage);
                    })
                    break;
                case "mms_image_goto_btn":
                    var page = parseInt($(this).val());
                    var page_count = parseInt($("#sc_pic_content").attr("page_count"));
                    $("#mms_images_stuff_box").load("/baby_books/list_images_stuff", {
                        page: page 
                    }, function(){
                        $("#sc_pic_content").attr("page", page );
                        BookApp.dragPic();
                        $("#mms_images_stuff_page_counter").empty();
                        $("#mms_images_stuff_page_counter").append(page  + "/" + page_count);
                    })
                    break;
                case "mms_text_stuff_search_btn":
                    var page = 1;
                    var page_count = parseInt($("#sc_text_content").attr("page_count"));
                    $.post("/baby_books/list_texts_stuff", {
                        page: page,
                        keyword: $("#mms_text_stuff_search_keyword").val()
                    }, function(data){
                        $("#mms_texts_stuff_box").next().remove();
                        $("#mms_texts_stuff_box").remove();
                        $("#sc_text_content").append(data);
                        BookApp.dragPic();
                        $("#mms_text_prev_btn").click(BookApp.changePage);
                        $("#mms_text_next_btn").click(BookApp.changePage);
                        $("#mms_text_goto_btn").change(BookApp.changePage);
                    })
                    break;
                }
            },
            openSortPagesDlg: function(){
                $("#mms_dialog").empty();
                var data = [];

                var pages = $("#mms_sortable div.books_page");
                var length = pages.length;
                var part_amount = parseInt(length / 8);
                var page_range = 0;
                var page_num = 1;
                data.push("<div class='mms_baby_books_info'>");
                data.push("<span class='info_text'>用鼠标拖动图片排列宝贝图书的顺序</span>");
                data.push("</div>");
                data.push("<ul class='mms_babybook_page_range' >");
                for(var i=0; i <= length; i++){
                    var page_group = pages.splice(0,8);
                    if(page_group.length > 0){
                        
                        page_range += 1
                        data.push("<li>");
                        data.push(page_range);
                        data.push(" - ");
                        page_range += 7
                        data.push(page_range);
                        data.push("页</li>");
                    }
                }                
                data.push("</ul>");
                data.push("<ul id='mms_babybook_pages_sortables' class='mms_babybook_pages'>");
                pages = $("#mms_sortable div.books_page");
                var is_not_saved=false;
                $.each(pages,function(){
                    if($(this).attr('page_id')=='mms_new_page'){
                        is_not_saved=true;
                        return;
                    }
                    var html = [];
                    html.push("<li class='mms_babybook_page' layout_id='"+ $(this).attr('layout_id') +"' serialize_id='page_id_"+ $(this).attr('page_id') + "' page_id='"+ $(this).attr('page_id') +"'> ");                 
                    html.push("<img src='" + $('img',this).attr('src') +"' />");
                    html.push("<span >第" + page_num +"页</span>");
                    page_num+=1;
                    html.push("</li>");
                    data.push(html.join(''));
                });
                if(is_not_saved){                    
                    alert('有页面尚未完全保存，请稍候再排序');
                    return;
                }
                
                data.push("</ul>")
                $("#mms_dialog").append(data.join(''));
                $("#mms_dialog").dialog({
                    title: "拖动页面图片即可排序",
                    modal: true,
                    width: 900,
                    height: 700,
                    position: 'center',
                    close: null,
                    buttons: {
                        "不保存" : function(){
                            $("#mms_dialog").empty();                            
                            $("#mms_dialog").dialog("close");
                        },
                        "保存" : function(){
                            $.post("/baby_books/sort_pages/" + $('#edit_book_id').attr('book_id'), $("#mms_babybook_pages_sortables").sortable("serialize", {
                                attribute: 'serialize_id',
                                key: "page_id[]"
                            }));
                            var o_pages = $("#mms_sortable div.books_page");
                            var n_pages = $("#mms_babybook_pages_sortables li");
                            var current_page_id = $('#edit_book_id').data('current_page_id');                                                
                            $.each(n_pages,function(index,v){
                                var serialize_id = $(this).attr('serialize_id');
                                var page_id = $(this).attr('page_id');
                                var layout_id = $(this).attr('layout_id');
                                var img_src = $('img', this).attr('src');                                                                     var o_page = $(o_pages[index]);
                                o_page.attr('serialize_id',serialize_id);
                                o_page.attr('layout_id',layout_id);
                                o_page.attr('page_id',page_id);
                                if(page_id == current_page_id){
                                    o_page.find('div.pic').addClass("current");
                                }else{
                                    o_page.find('div.pic').removeClass("current");                                    
                                }
                                o_page.find('img').attr('src',img_src);
                            });                            
                            $("#mms_dialog").empty();                            
                            $("#mms_dialog").dialog("close");
                        }
                    }
                });
                $('#mms_babybook_pages_sortables').sortable({
                    tolerance: 'pointer',
                    items: 'li',
                    revert: true,
                    stop: function(event, ui){
                        $.each($('span','#mms_babybook_pages_sortables li'),function(index,val)                        {
                            $(this).empty();
                            var page_num=index+1;
                            $(this).html("第" + page_num + "页");
                        });
                    }
                });
            },
            initEvent: function(){
                $("#sel_layout_id").click(function(){
                    BookApp.listLayout();
                });
                $("#sel_bg_id").click(function(){
                    BookApp.listBackground();
                });
                //图书列表排序
                BookApp.sortBookpage($("#mms_sortable"));
                //拖动素材库中的内容
                BookApp.dragPic();
                //新增页
                $("#add_bookpage_id").click(function(){
                    BookApp.newPageDialog();
                });
                $("div[page_id]").click(BookApp.editPage);
                $("#mms_save_page_btn").click(BookApp.savePage);
                $("#mms_preview_btn").click(BookApp.previewPage);
                $("#mms_share_page_btn").click(BookApp.sharePage);
                $("#mms_mp3_btn").click(BookApp.editMp3);
                
                if ($("#mms_pages div.books_page").length >= 1) {
                    $("#mms_pages div.books_page:eq(0)").trigger('click');
                    var pages_size = $("#mms_pages div.books_page").length;
                    $("#mms_book_pager").append("1/" + pages_size);
                }
                else {
                    $('#edit_book_id').data('current_page_id', 'mms_no_page');
                }
                
                $("#mms_rm_current_page_btn").click(BookApp.removeCurrentPage);
                
                //是否显示删除的图标
                BookApp.showOrHideDelIcon($("#mms_pages .books_page"));
                
                $("#mms_image_prev_btn").click(BookApp.changePage);
                $("#mms_image_next_btn").click(BookApp.changePage);
                $("#mms_text_prev_btn").click(BookApp.changePage);
                $("#mms_text_next_btn").click(BookApp.changePage);
                $("#mms_image_goto_btn").change(BookApp.changePage);
                $("#mms_text_goto_btn").change(BookApp.changePage);
                $("#mms_text_stuff_search_btn").click(BookApp.changePage);
                $("#mms_image_goto_btn").val(1);
                $("#mms_text_goto_btn").val(1);
                $("#mms_text_stuff_search_keyword").val('');
                
                $("#mms_sort_pages_btn").click(BookApp.openSortPagesDlg);
                
                $("<div id='mms_dialog' style='display:none'>").appendTo('body')
            },
            init: function(){
                BookApp.initEvent();
            }
        };
        
        BookApp.init();
        
    });
})(jQuery);
