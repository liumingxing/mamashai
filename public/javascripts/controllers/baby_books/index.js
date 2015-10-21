if (typeof BookApp === "undefind") 
    var BookApp = {};
(function($){
    $(function(){
        BookApp = {
            tab: function(t){
                $(t).addClass('current').siblings().removeClass("current");
                $("#" + $(t).attr("id") + "_content").css("display", "");
                $("#" + $(t).siblings().attr("id") + "_content").css("display", "none");
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
                        $("#mms_text_prev_btn").click(BookApp.changePage);
                        $("#mms_text_next_btn").click(BookApp.changePage);
                        $("#mms_text_goto_btn").change(BookApp.changePage);
                    })
                    break;
                }
            }
        };
        $("#mms_image_prev_btn").click(BookApp.changePage);
        $("#mms_image_next_btn").click(BookApp.changePage);
        $("#mms_text_prev_btn").click(BookApp.changePage);
        $("#mms_text_next_btn").click(BookApp.changePage);
        $("#mms_image_goto_btn").change(BookApp.changePage);
        $("#mms_text_goto_btn").change(BookApp.changePage);
        $("#mms_text_stuff_search_btn").click(BookApp.changePage);
        $("#mms_text_stuff_search_keyword").val('');        
        $("#mms_image_goto_btn").val(1);
        $("#mms_text_goto_btn").val(1);
        
    });
})(jQuery);

