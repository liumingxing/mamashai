$(function(){
    $.extend(MMS_CallBacks,{
	create_article_good : function(data,textStatus, XMLHttpRequest,trigger){
            if(/\d+/.test(data)){
	        trigger.parents('.haoping').find('strong[container=count]').html(data);
            }else{
                $.pnotify(data);
            }
	}
    });
});
