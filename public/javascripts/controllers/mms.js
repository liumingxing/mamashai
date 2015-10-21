//jQuery.noConflict();

(function($){
    try {
        document.execCommand('BackgroundImageCache', false, true);
    } catch(e){}
    


    //MMS Util
    $.extend({
	/*
	  该方法用于继承和合并对象
	*/
	mix: function(r, s, ov, wl, mode, merge) {

	    if (!s||!r) {
		return r || $;
	    }
	    
	    if (mode) {
		switch (mode) {
		case 1: // proto to proto
		    return $.mix(r.prototype, s.prototype, ov, wl, 0, merge);
		case 2: // object to object and proto to proto
		    $.mix(r.prototype, s.prototype, ov, wl, 0, merge);
		    break; // pass through 
		case 3: // proto to static
		    return $.mix(r, s.prototype, ov, wl, 0, merge);
		case 4: // static to proto
		    return $.mix(r.prototype, s, ov, wl, 0, merge);
		default:  // object to object is what happens below
		}
	    }
	    
	    
	    var arr = merge && $.isArray(r), i, l, p;
	    
	    if (wl && wl.length) {
		for (i = 0, l = wl.length; i < l; ++i) {
		    p = wl[i];
		    if (p in s) {
			if (merge && $.isObject(r[p], true)) {
			    $.mix(r[p], s[p]);
			} else if (!arr && (ov || !(p in r))) {
			    r[p] = s[p];
			} else if (arr) {
			    r.push(s[p]);
			}
		    }
		}
	    } else {
		for (i in s) { 
		    // if (s.hasOwnProperty(i) && !(i in FROZEN)) {
		    // check white list if it was supplied
		    // if the receiver has this property, it is an object,
		    // and merge is specified, merge the two objects.
		    if (merge && $.isObject(r[i], true)) {
			$.mix(r[i], s[i]); // recursive
			// otherwise apply the property only if overwrite
			// is specified or the receiver doesn't have one.
		    } else if (!arr && (ov || !(i in r))) {
			r[i] = s[i];
			// if merge is specified and the receiver is an array,
			// append the array item
		    } else if (arr) {
			r.push(s[i]);
		    }
		    // }
		}
		
		if ($.browser.msie) {
		    $._iefix(r, s);
		}
	    }
	    
	    return r;
	},
	isObject:function(o, failfn) {
	    return (o && (typeof o === OBJECT || (!failfn && $.isFunction(o)))) || false;
	},
	_iefix : function(r, s) {
	    var fn = s.toString;
	    if ($.isFunction(fn) && fn != Object.prototype.toString) {
		r.toString = fn;
	    }
	},
	ie6:$.browser.version==="6.0",
	ns: function() {
	    var a = arguments, o = null, i, j, d;
	    for (i = 0; i < a.length; i = i + 1) {
		d = ("" + a[i]).split(".");
		o = window;
		for (j = 0; j < d.length; j = j + 1) {
		    o[d[j]] = o[d[j]] || {};
		    o = o[d[j]];
		}
	    }
	    return o;
	},
	emptyFn:function(){},
	/*该方法用于类式继承*/
	inherit:function(sub, sup) {
	    var f = function(){};
	    f.prototype = sup.prototype;
	    sub.superClass_ = sup.prototype;
	    sub.prototype = new f();
	    //debugger;
	    sub.prototype.constructor = sub;
	}
    });



    $.ns("MMS","MMS.ui");
    MMS.util={
	//视口的大小
        viewport: function() {
            return {
                width: $(window).width(), height: $(window).height()
            }
        },
        //让元素居中，参数为jQuery对象
        center: function(obj) {
            var l=$(window).width()/2-obj.outerWidth()/2+$(window).scrollLeft();
            var t=$(window).height()/2-obj.outerHeight()/2+$(window).scrollTop();
            obj.css({ left: l, top: t });
        }
    };
    MMS.CONFIG={
	AJAX01:"正在传输数据...",
	AJAX02:"数据传送成功",
	AJAX03:"数据传送失败，请稍候",
	AJAX04:"/images/layer/rel_interstitial_loading.gif",
	AJAX05:"/images/layer/sprite.png",
	SHINE01:"转晒成功！",
	SHINE02:"您确定要删除吗？",
	SHINE03:"删除成功！",
	SHINE04:"报名成功",
	SHINE05:"您已经报过名了",
	DIALOG01:"确定吗？",
	DIALOG02:"警告！",
	DIALOG03:"确定",
	DIALOG04:"取消",
	LETTER01:"信的内容不能为空",
	LETTER02:"信内容超过了300个字",
	LETTER03:"昵称不能为空",
	RECOMMAND01:"推荐成功！",
	RULE01:"只能输入数字",
	RULE02:"请输入正确的email地址",
	RULE03:"该项为必填项",
	RULE04:"请输入正确的手机号"
    }



    MMS.ui.Panel =function(ele,opt){
	this.init(ele,opt);
    };
    MMS.ui.Panel.prototype=(function(){

	return {
	    useIframe: null,
            draggable: false,
            resizable: false,
	    innerClass:"mms_panel",
	    outerClass:"mms_panel_c",
	    headClass:"mms_hd",
	    bodyClass:"mms_bd",
	    footClass:"mms_ft",
	    panelClass:"mms_panel",
	    state:"hide",
	    rendered:false,
	    autoShow:false,
	    //执行默认的初始化的动作
	    init:function(ele,opt){
		//debugger;
		
		if(!ele)alert("请指明元素的id");
		//配置配置属性的复制
		$.extend(true,this,opt||{});
		//绑定事件
		this.bindEvent();
		//设置化dom元素
		if(typeof ele === "string" && $('#'+ele).length>0){
		    var domEle=document.getElementById(ele);
		    this.element=$('#'+ele);
		    this.head=$("."+this.headClass,domEle);
		    this.body=$("."+this.bodyClass,domEle);
		    this.foot=$("."+this.footClass,domEle);
		    //this.rendered=true;
		}else{ 
		    this.createElement().attr("id",ele);//动态的生成element
		}
		if(this.element.parent().find('.'+this.outerClass).length>0){
		    this.panel=this.element.parent().eq(0);
		}else{
		    this.createPanel().attr("id",ele+'_c');//动态的生成panel
		}
		//生成UI
		this.buildUI();
		//进行一些初始化的配置工作
		
		this.config();

	    },
	    config:function(){
		$(this).trigger("onInitConfig");
		
		this.width&&this.setWidth(this.width);
		this.height&&this.setHeight(this.height);
		this.position&&this.setPosition(this.position);
		this.zIndex&&this.setzIndex(this.zIndex);
	        
		this.headContent&&this.setHead(this.headContent);
		this.bodyContent&&this.setBody(this.bodyContent);
		this.footContent&&this.setFoot(this.footContent);
		
	    },
	    buildUI:function(){
		this.panel.append(this.element);
		//this.element.append(this.panel);
		return this;
	    },
	    createPanel:function(){
		var panel=$(document.createElement("div")).addClass(this.outerClass).css({display:"none",position:"absolute"});
		this.panel=panel;
		
		return panel;
	    },
	    setPanelClass:function(c){
		this.panel[0].className=c;
	    },
	    createElement:function(){
		var element=$(document.createElement("div")).addClass(this.innerClass);
		this.element=element;
		return element;
	    },
	    setElementClass:function(c){
		this.element[0].className=c;
	    },
	    _createIframe:function(){
		//debugger;
		var iframe=$(document.createElement("iframe"))
		    .attr({src:"about:blank",frameborder:"0",width:this.panel.width(),height:this.panel[0].offsetHeight})
		    .css({position:"absolute",opacity:"0",left:this.panel.css("left"),top:this.panel.css("top")});
		this.useIframe=iframe;
	    },
	    bindEvent:function(){
		var that=this;
		$(this).bind('onInitConfig',this.onInitConfig || $.emptyFn);
		$(this).bind('onChangeHead',this.onChangeHead || $.emptyFn);
		$(this).bind('onChangeBody',this.onChangeBody || $.emptyFn);
		$(this).bind('onChangeFoot',this.onChangeFoot || $.emptyFn);
		$(this).bind('onBeforeShow',this.onBeforeShow || $.emptyFn);
		$(this).bind('onBeforeRender',this.onBeforeRender || $.emptyFn);
		$(this).bind('onHide',this.onHide || $.emptyFn);
		$(this).bind('onDestroy',this.onDestroy || $.emptyFn);
		//this.autoHide&&$(document).bind('click',function(e){that.autoHidden(e);});
	    },
	    
	    getPanel:function(){
		return this.panel;
	    },
	    getElement:function(){
		return this.element;
	    },
	    setPosition:function(pos){
		this.panel.css(pos);
		return this;
	    },
	    setWidth:function(wv){
		this.element.css("width",wv);
		return this;
	    },
	    getWidth:function(){
		return this.element.css("width");
	    },
	    setHeight:function(hv){
		this.element.css("height",hv);
		return this;
	    },
	    getHeight:function(){
		return this.element.css("height");
	    },
	    setzIndex:function(zIn){
		this.panel.css("zIndex",zIn);
		return this;
	    },
	    getzIndex:function(){
		return this.panel.css("zIndex");
	    },
	    _fixCenter:function(){
		MMS.util.center(this.panel);
		$.ie6&&MMS.util.center(this.useIframe);
	    },
	    createHead:function(){
		if(!this.head)this.head=$(document.createElement("div")).addClass(this.headClass);
	    },
	    createBody:function(){
		if(!this.body)this.body=$(document.createElement("div")).addClass(this.bodyClass);
	    },
	    createFoot:function(){
		if(!this.foot)this.foot=$(document.createElement("div")).addClass(this.footClass);
	    },
	    setHead:function(h){
		this.createHead();
		this.head.html(h);
		this._renderHead();
		$(this).trigger("onChangeHead");
		return this;
	    },
	    appendHead:function(ah){
		this.head.append(ah);
		return this;
	    },
	    setBody:function(c){
		this.createBody();
		this.body.html(c);
		this._renderBody();
		$(this).trigger("onChangeBody");
		return this;
	    },
	    appendBody:function(ab){
		this.body.append(ab);
		return this;
	    },
	    setFoot:function(f){
		this.createFoot();
		this.foot.html(f);
		this._renderFoot();
		$(this).trigger("onChangeFoot");
		return this;
	    },
	    appendFoot:function(af){
		this.createFoot();
		this.foot.append(af);
		return this;
	    },
	    _renderHead:function(){
		//如果已经有head，但是还没有存在于dom中
		if(this.head && $("."+this.headClass,this.element[0]).length==0){
		    this.element.prepend(this.head);
		}
	    },
	    _renderBody:function(){
		if(this.body && $("."+this.bodyClass,this.element[0]).length==0){
		    if(this.foot){
			this.foot.before(this.body);
		    }else{
			this.element.append(this.body);
		    }
		}
	    },
	    _renderFoot:function(){
		if(this.foot && $("."+this.footClass,this.element[0]).length==0){
		    this.element.append(this.foot);
		}
	    },
	    _renderIframe:function(){
		this._createIframe();
		this.panel.before(this.useIframe);
	    },
	    render:function(parentNode){
		if(parentNode){
		    $(this).trigger("onBeforeRender");
		    $(parentNode).append(this.panel);
		    
		    this._renderHead();
		    this._renderFoot();
		    this._renderBody();
		    if(this.autoShow)this.show();
		}else{
		    if(this.autoShow)this.show();
		}
		
	    },	
	    show:function(){
		//this.panel.fadeIn("slow");
		var that=this;
		$(this).trigger("onBeforeShow");
		this.panel.css("display","block");
		this.panel.find("*").show();
		this.state="show";
		$.ie6&&this._renderIframe();
		this.fixCenter&&this._fixCenter();
		if(this.fixCenter)$(window).bind('scroll resize',function(){that._fixCenter()});
		return this;
	    },
	    hide:function(){
		//this.panel.fadeOut("slow");
		this.useIframe&&this.useIframe.hide();
		this.panel.css("display","none");
		this.state="hide";
		if(this.fixCenter)$(window).unbind('scroll resize');
		$(this).trigger("onHide");
		return this;
	    },
	    getState:function(){
		return this.state;
	    },
	    unbindEvent:function(){
		$(this).unbind();
		$(window).unbind('scroll resize');
	    },
	    destroy:function(){
		this.unbindEvent();
		//this.panel.fadeOut("slow");
		this.panel.empty().remove();
		$(this).trigger("onDestroy");
	    }

	};
    })();




    MMS.ui.Dialog=function (ele,opt){
	//this.init(ele,opt);
	//this.init(ele,opt);
	//MMS.ui.Panel.call(this,ele,opt);
	MMS.ui.Dialog.superClass_.init.call(this,ele,opt);
	//goog.ui.Component.call(this, opt_domHelper);

    };
    $.inherit(MMS.ui.Dialog,MMS.ui.Panel);
    /*MMS.ui.Dialog.prototype=(function(){
      return {*/
    MMS.ui.Dialog.prototype.constructor=MMS.ui.Dialog;
    MMS.ui.Dialog.prototype.modal=false;
    MMS.ui.Dialog.prototype.buttons=null;
    MMS.ui.Dialog.prototype.close=true;
    MMS.ui.Dialog.prototype.closeClass="mms_panel_close";
    MMS.ui.Dialog.prototype.config=function(){

	MMS.ui.Dialog.superClass_.config.apply(this);
	//debugger;
	this.buttons&&this.setButtons(this.buttons);
	this.close&&this._createClose();
	this.modal&&this._createModal();
	//debugger;
    };
    MMS.ui.Dialog.prototype.setButtons=function(buttons){
	//var $tempDiv=$(document.createElement("div"));
	this.foot&&this.foot.empty();
	for(var i=0,l=buttons.length;i<l;i++){
	    //$tempDiv.append(this._createButton(buttons[i],i));
	    this.appendFoot(this._createButton(buttons[i],i));
	}
	//this.setFoot($tempDiv.html);
    };
    MMS.ui.Dialog.prototype._createIframe=function(){
	//debugger;
	var iframe=$(document.createElement("iframe"))
	    .attr({src:"about:blank",frameborder:"0",width:$(document).width(),
		   height:$(document).height()})
	    .css({position:"absolute",left:0,top:0,background:"#000",opacity:0});
	this.useIframe=iframe;
    };
    MMS.ui.Dialog.prototype._renderIframe=function(){
	if(!this.useIframe){
	    this._createIframe();
	    this.modalele&&this.modalele.before(this.useIframe);
	}else{
	    this.useIframe.show();
	}
    };
    MMS.ui.Dialog.prototype._createButton=function(button,i){
	var $button=$(document.createElement("button"));
	button.text&&$button.text(button.text);
	button.handler&&$button.bind("click",button.handler);
	$button.attr("id",this.panel.attr("id")+'_button-'+i);
	//$button.attr("type","button");
	return $button;
    };
    MMS.ui.Dialog.prototype._createClose=function(){
	var $close=$(document.createElement("a")),that=this;
	$close.attr("href","javascript:void(0);").addClass(this.closeClass)
	    .bind("click",function(){that.hide();});
	this.closeele=$close;
	//debugger;
	this.element.append($close);
    };
    MMS.ui.Dialog.prototype._createModal=function(){
	var $modal=$(document.createElement("div"));
	$modal.css({position:"absolute",left:0,top:0,width:$(document).width(),
	    	    height:$(document).height(),background:"#000",opacity:0.5,display:"none",zIndex:1});
	this.modalele=$modal;
	$(document.body).prepend($modal);
    };
    MMS.ui.Dialog.prototype.show=function(){
	MMS.ui.Dialog.superClass_.show.call(this);
		//this.modalele.fadeIn("slow");
		this.modalele&&this.modalele.fadeIn("slow");
		this.closeele&&this.closeele[0].focus();
    };
    MMS.ui.Dialog.prototype.hide=function(){
	//debugger;
	MMS.ui.Dialog.superClass_.hide.call(this);
	//this.modalele.fadeOut("slow");
	this.modalele&&this.modalele.fadeOut("slow");
    };
    MMS.ui.Dialog.prototype.destroy=function(){
	MMS.ui.Dialog.superClass_.destroy.call(this);
	this.modalele.remove();
    };
    // MMS.ui.Dialog.prototype.
    /*	};
        })();*/
    MMS.ui.MessageBox=(function(){

	var dialogInstance=null,count=0;
	
	return {
	    getDialog:function(content,fun,type){
		//debugger;
		
		var opt={
		    modal:true,
		    autoShow:true,
		    headContent:"&nbsp",
		    buttons:[],
		    fixCenter:true,
		    width:"220px",
		    innerClass:"mms_panel_message"
		};
		if(type=='alert'){
		    opt.headContent=MMS.CONFIG.DIALOG02;
		    opt.buttons=[{text:MMS.CONFIG.DIALOG03,handler:function(){fun.call(this,dialogInstance);dialogInstance&&dialogInstance.hide();}}];
		    opt.bodyContent='<span class="mms_icon mms_alert">&nbsp;</span><span>'+content+'</span>';
		}else if(type=='confirm'){
		    
		    //opt.headContent=MMS.CONFIG.DIALOG01;
		    opt.buttons=[{text:MMS.CONFIG.DIALOG03,handler:function(){fun.call(this,dialogInstance);dialogInstance&&dialogInstance.hide();}},{text:MMS.CONFIG.DIALOG04,handler:function(){fun.call(this);dialogInstance&&dialogInstance.hide();}}];
		    opt.bodyContent='<span class="mms_icon mms_confirm">&nbsp;</span><span>'+content+'</span>';
		}else if(type=='prompt'){
		    opt.headContent=MMS.CONFIG.DIALOG01;
		    opt.buttons=[{text:MMS.CONFIG.DIALOG03,handler:function(){fun.call(this,dialogInstance);dialogInstance&&dialogInstance.hide();}},{text:MMS.CONFIG.DIALOG04,handler:function(){fun.call(this);dialogInstance&&dialogInstance.hide();}}];
		    opt.bodyContent='<span class="mms_icon mms_prompt">&nbsp;</span><span>'+content+'<input type="text" id="prompt_input_id"/></span>';
		}
		//debugger;

		if(dialogInstance==null){	

		    dialogInstance=new MMS.ui.Dialog('mms_'+type,opt);

		    dialogInstance.render(document.body);

		    return;
		}
		//dialogInstance
		dialogInstance.setHead(opt.headContent);
		dialogInstance.setButtons(opt.buttons);
		dialogInstance.setBody(opt.bodyContent);
		dialogInstance.show();
	    },
	    alert:function(msg,fun){
		this.getDialog(msg, fun, "alert");
	    },
	    confirm:function(msg,fun){
		
		this.getDialog(msg, fun, "confirm");
	    },
	    prompt:function(msg,fun){
		this.getDialog(msg, fun, "prompt");
	    }	
	};
    })();





    /*ajax全局事件，在ajax交互时用于指定当前所处的状态*/


    /*ajax全局事件的封装*/
    $(function(){
	/*create ajax loading element*/
	var ajaxPanel=new MMS.ui.Dialog("ajax_dialog",{
	    fixCenter:true,
	    close:false,
	    zIndex:10000,
	    innerClass:"mms_panel_load",
	    modal:true
	});
	//预加载图片
	var img=new Image();
	img.src=MMS.CONFIG.AJAX04;
	
	ajaxPanel.setBody(MMS.CONFIG.AJAX04);
	
	ajaxPanel.render(document.body);
	$(document).ajaxStart(function(){

	   // ajaxPanel.setBody('<img src="'+MMS.CONFIG.AJAX04+'">');
	   // ajaxPanel.show();
	});
	
	$(document).ajaxSuccess(function(e,xhr,opt){
	    if(opt.pullContent){//加载数据时的提示信息
		//ajaxPanel.hide();			//lmx注释掉 11.1.6
	    }else{//保存数据时的提示信息<span class="load_ok">转晒成功</span>
		//debugger;
		//opt.successMsg?ajaxPanel.setBody('<span class="load_ok">'+opt.successMsg+'</span>')
		//    :ajaxPanel.setBody('<span class="load_ok">'+MMS.CONFIG.AJAX02+'</span>');		
	    }

	});
	$(document).ajaxError(function(e,xhr,opt){
	    opt.errorMsg?ajaxPanel.setBody(opt.errorMsg)
		:ajaxPanel.setBody(MMS.CONFIG.AJAX03);
	});
	$(document).ajaxStop(function(){setTimeout(function(){ajaxPanel.hide()},1500);});
	
    });



    //dom加载完成才执行该方法，必须的
    $(function(){
	
	MMS.tools=(function(){
	    //该方法用于当textarea输入不符合要求时，改变背景
	    var changeColorTextarea=function(A) {
		var B = $("#" + A)[0];
		for (var i = 0; i < 3; i++) {
		    setTimeout(function() {
		        B.style.backgroundColor = "#fee9e9";
		    },
		               i * 300 + 1);
		    setTimeout(function() {
		        B.style.backgroundColor = "#ffffff";
		    },
		               i * 300 + 151)
		}
	    };
	    //
	    var sendInfo=function(button,textarea/*输入框id*/,maxlength,callback,successMsg){
		//禁用按钮
		//button.disabled="diabled";
		//判断textarea输入是否符合要求
		var value=$('#'+textarea).val();
		//debugger;
		if(value.length>maxlength){
		    
		    changeColorTextarea(textarea);
		}else{
		    //禁用按钮
		    $(button).attr("disabled",true);
		    $.ajax({
		    	url:button.form.action,
		    	successMsg:successMsg,
		    	data:$(button.form).serialize(),
		    	success:function(data){
		    	    //debugger;
		    	    callback.call(null,data);
		    	}
		    });	
		}
	    };
	    //定位光标的位置
	    var setCaretTo=function(obj, _) {
		if (obj.createTextRange) {
		    var A = obj.createTextRange();
		    A.move("character", _);
		    A.select();
		} else {
		    obj.focus();
		    obj.setSelectionRange(_, _);
		}
	    };
	    //表单的验证规则
	    var validationopt={
		onlynumber:{
		    errmessage: MMS.CONFIG.RULE01,
		    test: function(a) {
			return ! $.trim(a.value) || /^[0-9]+$/.test($.trim(a.value));
		    }
		},
		email:{
		    errmessage:MMS.CONFIG.RULE02,
		    test:function(a){
			return ! $.trim(a.value) || /^([\w]+)(\.[\w]+)*@([\w\-]+\.){1,5}([A-Za-z]){2,4}$/i.test($.trim(a.value));
		    }
		},
		required:{
		    errmessage:MMS.CONFIG.RULE03,
		    test:function(a){
			//debugger;
			return $.trim(a.value).length>0;
		    }
		},
		mobilePhoneNumber:{
		    errmessage:MMS.CONFIG.RULE04,
		    test:function(obj){
			return !obj.value.length || /^((\(\d{2,3}\))|(\d{3}\-))?1[3,8,5]{1}\d{9}$/.test(obj.value);
		    }
		}
	    };
	    //用于弹窗框中表单的验证
	    var formvalidation=function(form,opt){
		var eles=form.elements,errObj=[];
		for(var i=0;i<eles.length;i++){
		    var field=eles[i],errMsg=[];
		    //debugger;
		    for(var rule in opt){
			var reg=new RegExp("(^|\\s)" + rule + "(\\s|$)");
			if(reg.test(field.className) && !opt[rule].test(field)){
			    errMsg.push(opt[rule].errmessage);
			    errObj.push(field);
			}	
		    }
		    if(errMsg.length>0){
			$(field).find("+ div").children().html(errMsg[0]);
		    }else{
			$(field).find("+ div").children().html("");
		    }
		}
		if(errObj.length>0)return false;
		else return true;
	    };
	    
	    
	    //弹出框
	    var tooldialog=new MMS.ui.Dialog("mms_tooldialog",{
		fixCenter:true,
		modal:true,
		close:false
	    });
	    tooldialog.render(document.body);
	    //弹窗成功后的回调函数
	    var cb=function(savebutton,textarea,leftcount,successMsg){
		//初始化时，计算可以输入的字数
		updateStatusTextCharCounter($("#"+textarea)[0],leftcount);
		//定位光标到最前面
		setCaretTo($("#"+textarea)[0],0);
		//为转晒按钮绑定事件
		$("#"+savebutton).click(function(){
		    sendInfo(this,textarea,210,function(){tooldialog.hide();},successMsg);
		});
	    }
	    var sendlettercallback=function(send_button){
		//debugger;//error_msg
		$('#'+send_button).click(function(){
		    //debugger;
		    var mpc=$.trim(document.getElementById("message_post_content").value);
		    var mpun =$.trim(document.getElementById("message_post_user_name").value);
		    var errmsg="";
		    mpc.length<1&&(errmsg=MMS.CONFIG.LETTER01);
		    mpc.length>300&&(errmsg=MMS.CONFIG.LETTER02);
		    mpun.length<1&&(errmsg=MMS.CONFIG.LETTER03);
		    //errmsg.length>0&&$("#error_msg").html(errmsg);
		    if(errmsg.length>0){
			$("#error_msg").html(errmsg);
			return false;
		    }
		    //var flag=false;
		    $.ajax({
			url:"/ajax/create_message",
			data:$('#send_letter_id').serialize(),
			global:false,
			success:function(data){
			    var d=eval('('+data+')');
			    //debugger;
			    if(d.error){
				$("#error_msg").html(d.error);
				return false;
			    }else{
				$("#error_msg").html("");
				tooldialog.setPanelClass("mms_panel_load");
				tooldialog.setBody('<span class="load_ok">发送成功</span>');
				tooldialog._fixCenter();
				setTimeout(function(){tooldialog.hide();},2000);
			    }
			    //return false;
			}
		    });				
		});
		return false;
	    }

	    var signupcallback=function(signupbutton){
		$("#"+signupbutton).click(function(){
		    
		    if(formvalidation(this.form,validationopt)){
			var that=this;
			var ajaxopt={
			    url:that.form.action,
			    data:$(that.form).serialize(),
			    //global:false,
			    successMsg:MMS.CONFIG.SHINE04,
			    success:function(data){
				var o=eval('('+data+')');
				if(o.error){
				    this.successMsg=MMS.CONFIG.SHINE05;
				}
				tooldialog.hide();
			    }
			}
			
			$.ajax(ajaxopt);
		    }
		});
		
	    };
	    //public
	    return {
		hidedialog:function(){tooldialog.hide();},
		//转晒
		forwardshine:function(url){
		    $.ajax({
			url: url,
			pullContent:true,
			success:function(data) {
			    //tooldialog.setPanelClass("mms_panel");
			    tooldialog.setBody(data);
				tooldialog.show();
			    cb("forward_shine_button","forward_post_content","forward_text_left",MMS.CONFIG.SHINE01);
			}
		    });
		},
		deleteshine:function(url){
		    //debugger;
		    
		    MMS.ui.MessageBox.confirm(MMS.CONFIG.SHINE02,function(cdialog){
			var self=this;
			if(self.innerHTML==MMS.CONFIG.DIALOG03){
			    $.ajax({
				url: url,
				successMsg:MMS.CONFIG.SHINE03,
				success:function(data){
				    var data=url.match(/\/(\d+)$/),
				    pw=$("#post_wapper_"+data[1]);
				    pw.fadeOut("slow",function(){pw.remove();});
				}
			    });				
			}
		    });
		},
		delete_item:function(url,id_pre){
		    //debugger;
		    
		    MMS.ui.MessageBox.confirm(MMS.CONFIG.SHINE02,function(cdialog){
			var self=this;
			if(self.innerHTML==MMS.CONFIG.DIALOG03){
			    $.ajax({
				url: url,
				successMsg:MMS.CONFIG.SHINE03,
				success:function(data){
				    var data=url.match(/\/(\d+)$/),
				    pw=$("#"+id_pre+data[1]);
				    pw.fadeOut("slow",function(){pw.remove();});
				}
			    });				
			}
		    });
		},
		sendletter:function(url){
		    $.ajax({
			url: url,
			pullContent:true,
			success:function(data) {
			    tooldialog.setPanelClass("mms_panel");
			    tooldialog.setBody(data);
			    tooldialog.show();
			    sendlettercallback("send_button");
			}
		    });					
		},
		recommond:function(url){
		    $.ajax({
			url:url,
			pullContent:true,
			success:function(data){
			    tooldialog.setBody(data);
			    tooldialog.show();
			    cb("recommand_button","post_content","recommand_text_left",MMS.CONFIG.RECOMMAND01);
			}
		    });
		},
		signUp:function(url){
		    $.ajax({
			url:url,
			pullContent:true,
			success:function(data){
			    tooldialog.setBody(data);
			    tooldialog.show();
			    signupcallback("signup_button");
			    //cb("recommand_button","post_content","recommand_text_left",MMS.CONFIG.RECOMMAND01);
			}
		    });				
		}
	    }
	})();	
	
    });
})(jQuery);


