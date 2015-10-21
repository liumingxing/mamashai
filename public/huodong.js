var win = Ti.UI.createWindow({
	title: '有奖活动',
	backButtonTitle : '返回',
	barColor : Ti.App.bar_color,
	backgroundColor : '#fff'
})
pre(win)


var picture = Ti.UI.createImageView({
	left: 0,
	right: 0,
	top: 0,
	width: Ti.App.platform_width,
	height: __l(140)*Ti.App.platform_width/__l(320),
	image: "http://www.mamashai.com/upload/calendaradv/3/logo/ad1.jpg"
});
win.add(picture)

var bottom = Ti.UI.createImageView({
		top: __l(140)*Ti.App.platform_width/__l(320),
		left: 0,
		right: 0,
		width: Ti.App.platform_width,
		height: __l(9),
		hires: true,
		image : './images/adv_bottom.png'
})
win.add(bottom)

var wrapper = Ti.UI.createScrollView({
	top: __l(140)*Ti.App.platform_width/__l(320) + __l(10),
	left: 0,
	right: 0,
	bottom: 0,
	contentHeight: 'auto'
})
win.add(wrapper)

var label_1_title = Ti.UI.createLabel({
	top: 0,
	left : __l(10),
	height : __l(20),
	font : {
		fontSize : __l(13),
		fontWeight: 'bold'
	},
	textAlign: 'left',
	color: Ti.App.bar_color,
	text : '活动日期：'
})
var label_1 = Ti.UI.createLabel({
	top: 0,
	left : __l(80),
	height : __l(20),
	font : {
		fontSize : __l(13)
	},
	textAlign: 'left',
	color: Ti.App.bar_color,
	text : '本活动已经结束'
})
wrapper.add(label_1_title)
wrapper.add(label_1)

var label_2_title = Ti.UI.createLabel({
	top: __l(30),
	left : __l(10),
	height : __l(20),
	font : {
		fontSize : __l(13),
		fontWeight: 'bold'
	},
	textAlign: 'left',
	color: Ti.App.bar_color,
	text : '公布日期：'
})
var label_2 = Ti.UI.createLabel({
	top: __l(30),
	left : __l(80),
	height : __l(20),
	font : {
		fontSize : __l(13)
	},
	textAlign: 'left',
	color: 'black',
	text : '2013年4月22日',
})
wrapper.add(label_2_title)
wrapper.add(label_2)

var label_3_title = Ti.UI.createLabel({
	top: __l(60),
	left : __l(10),
	height : __l(20),
	font : {
		fontSize : __l(13),
		fontWeight: 'bold'
	},
	textAlign: 'left',
	color: Ti.App.bar_color,
	text : '奖品介绍：'
})
var label_3 = Ti.UI.createLabel({
	top: __l(60),
	left : __l(80),
	height : __l(20),
	font : {
		fontSize : __l(13)
	},
	textAlign: 'left',
	color: 'black',
	text : '宝宝春游防走失背包 （10份）'
})

var gift = Ti.UI.createButton({
	top: __l(60),
	right : __l(10),
	height: __l(20),
	title : '详细介绍',
	selectedColor: '#c66',
	color: Ti.App.bar_color,
	font:{
		fontSize: __l(12)
	}
})
if (!Ti.App.is_android){
	gift.style = Titanium.UI.iPhone.SystemButtonStyle.PLAIN
}
gift.addEventListener("click", function(e){
	Titanium.App.fireEvent("open_url", {
		url : "http://a.m.tmall.com/i12589789986.htm?ali_trackid=2:mm_13429391_0_0:1363854363_3k3_1354778399&spm=2014.12129701.1.0"
	})
})

wrapper.add(label_3_title)
wrapper.add(label_3)
wrapper.add(gift)

var label_4_title = Ti.UI.createLabel({
	top: __l(94),
	left : __l(10),
	height : __l(14),
	font : {
		fontSize : __l(13),
		fontWeight: 'bold'
	},
	textAlign: 'left',
	color: Ti.App.bar_color,
	text : '参加方式：'
})
var label_4 = Ti.UI.createLabel({
	top: __l(94),
	left : __l(80),
	height: Ti.UI.SIZE,
	font : {
		fontSize : __l(13)
	},
	textAlign: 'left',
	color: 'black',
	text : '亲们只要邀请新浪微博3位好友，一起体验《宝宝日历》就有机会被选中成为#十大邀请达人#啦！'
})
wrapper.add(label_4_title)
wrapper.add(label_4)


var label_5_title = Ti.UI.createLabel({
	top: __l(156),
	left : __l(10),
	height : __l(14),
	font : {
		fontSize : __l(13),
		fontWeight: 'bold'
	},
	textAlign: 'left',
	color: Ti.App.bar_color,
	text : '获奖名单：'
})

var wrapper_5 = Ti.UI.createView({
	top: __l(156),
	left : __l(80),
	right : __l(6),
	height: Ti.UI.SIZE,
	font : {
		fontSize : __l(13)
	},
	layout: 'horizontal'
})

wrapper.add(label_5_title)
wrapper.add(wrapper_5)

var users = [['长勒蟹钳额子路', 156542], ['果儿妈咪20111102', 225683], ['粗心肥妈', 260302], ['关亚楠', 437479], ['吹着空调吃火锅', 453787], ['NICI部落', 194355], ['王小睿', 368855], ['潘芷仪麻麻', 437667], ['茉小宝', 179968], ['Yumi_zyy', 207973]]

for(var i=0; i<users.length; i++){
  var user = users[i]
  var user_btn = Ti.UI.createButton({
	bottom: __l(3),
	right : __l(8),
	height: __l(14),
	font : {
		fontSize : __l(13)
	},
	color: Ti.App.bar_color,
	selectedColor: '#c66',
	style: Titanium.UI.iPhone.SystemButtonStyle.PLAIN,
	title : user[0],
	id: user[1]
  })
  user_btn.addEventListener("click", function(e) {
  		var UserWin = require('/user')
		var win = new UserWin({
			title : e.source.title,
			backgroundColor : '#fff',
			barImage : '/images/hua.png',
			barColor : Ti.App.bar_color,
			id : e.source.id
		})
		
		win.backButtonTitle = '返回'
		pre(win);
		Ti.App.currentTabGroup.activeTab.open(win, {
			animated : true
		});
  })
  wrapper_5.add(user_btn)
}


Ti.App.currentTabGroup.activeTab.open(win, {
	animated : true
});

//微博好友列表
function weibo_invite(){
	var win = Ti.UI.createWindow({
		title : '邀请微博好友',
		backButtonTitle : '返回',
		barColor : Ti.App.bar_color,
		backgroundColor : '#fff'
	})
	var actionBar = null;

var tableview = Ti.UI.createTableView({
	top : 0,
	bottom : 0,
	left: 0,
	width: Ti.App.platform_width
});
win.add(tableview);

var get_more_row = Ti.UI.createTableViewRow({
	height : Ti.UI.SIZE,
	selectedBackgroundColor : '#eee',
	tag : 'get_more',
	textAlign: "center",
	name: 'get_more'
});

var get_more_row_center = Ti.UI.createView({
	top : 0,
	bottom : 0,
	width : __l(160),
	height : __l(64)
})

var get_more_title = Ti.UI.createLabel({
	top : __l(18),
	bottom : __l(12),
	left : __l(26),
	right : __l(10),
	textAlign : 'left',
	height : Ti.UI.SIZE,
	font : {
		fontSize : __l(22)
	},
	width: __l(90),
	color: "#333",
	text : '下一页'
});

var navActInd = Titanium.UI.createActivityIndicator({
	left : __l(2),
	top : __l(8),
	width : __l(12),
	style : Titanium.UI.iPhone.ActivityIndicatorStyle.DARK
});

if (!Ti.App.is_android){
	get_more_row_center.add(navActInd);
	get_more_row.navActInd = navActInd;
}

get_more_row_center.add(get_more_title)
get_more_row.add(get_more_row_center);
get_more_row.addEventListener("click", function(e){
	navActInd.show();
	page += 1;
	var url = "https://api.weibo.com/2/friendships/friends/bilateral.json?count=50&access_token=" + token + "&uid=" + uid + "&page=" + page
	xhr.open('GET', url)
	xhr.send()
})


// Create a Button.
var done = Ti.UI.createButton({
	title : '邀请'
});

// Listen for click events.
done.addEventListener('click', function() {
	if(!tableview.data || tableview.data[0].length == 0) {
		show_notice("对不起，没有粉丝可邀请");
		return;
	}

	var count = 0
	var data = tableview.data[0];
	var result = ""
	for(var i = 0; i < data.rowCount; i++) {
		var row = data.rows[i];
		if(row.value == 1) {
			result += "@" + row.filter + "，";
			count += 1
		}
	}
	if(result == "") {
		show_notice("请选择粉丝");
		return;
	}

	if (count < 3){
		show_notice("请选择至少3个好友");
		return;
	}

	var WritePost = require("write_post")
	var win_write = new WritePost({
		title : "邀请微博好友",
		backgroundColor : '#fff',
		text : "#10大邀请达人#@妈妈晒，" + result + "快给你的手机装个宝宝日历，养育要点和记录结合，很贴心！iphone: http://t.cn/zOCDlTe，安卓: http://t.cn/zWjHQiN。",
		from : "huodong",
		from_id : 1,
		need_sina: true
	});
	win_write.backButtonTitle = '返回'
	pre(win_write)
	win_write.addEventListener("close", function(e){
		win.close()
	})
	Ti.App.currentTabGroup.activeTab.open(win_write, {
		animated : true
	});

});
var token = Ti.App.Properties.getString("token", '');

var page = 1;
var xhr = null;
var uid = null;
var account_xhr = Ti.Network.createHTTPClient({
	timeout: Ti.App.timeout,
	onerror: function(){
		hide_loading();
	},
	onload : function() {
		var json = JSON.parse(this.responseText)
		uid = json.uid
		
		xhr = Ti.Network.createHTTPClient({
			timeout: Ti.App.timeout,
			onerror : function() {
				hide_loading()
				show_notice("获取好友失败")
			},
			onload : function() {
				hide_loading();
				
				var pre_length = get_row_count(tableview);
				
				if (get_row_count(tableview) > 0)
					tableview.deleteRow(get_row_count(tableview) - 1);
					
				var json = JSON.parse(this.responseText)
					
				var CheckBox = require("lib/checkbox").CheckBox

				for(var i = 0; i < json.users.length; i++) {
					var user = json.users[i];
					var row = Ti.UI.createTableViewRow({
						//selectedBackgroundColor : "white",
						filter : user.screen_name,
						value : 0,
						
						height : Ti.UI.SIZE,
						color: '#333',
						selectedBackgroundColor: '#ccc'
					});

					var user_logo = Ti.UI.createImageView({
						top : __l(5),
						bottom : __l(5),
						left : __l(5),
						width : __l(30),
						height : __l(30),
						defaultImage : "./images/default.gif",
						image : user.profile_image_url,
						hires : true
					});

					var label = Ti.UI.createLabel({
						text : user.screen_name,
						top : __l(5),
						left : __l(44),
						bottom : __l(5),
						color : '#666666',
						font : {
							fontSize : __l(15)
						},
						height : 'auto',
						width : __l(200)
					});
					
					var check = new CheckBox({
							top : 0,
							height : 44,
							width : 44,
							right : 20,
							row: row
					})	
					
					check.view.addEventListener("click", function(e){
						if (e.source.value == 1)
							e.source.row.value = 1;
						else
							e.source.row.value = 0;
					})
					
					row.add(user_logo)

					row.add(label)

					row.add(check.view)

					tableview.appendRow(row)					
				}

				hide_loading();

				navActInd.hide();
				
				if(json.total_number > get_row_count(tableview)) {
					tableview.appendRow(get_more_row)
					tableview.scrollToIndex(pre_length-1)
				}
				
			}
		})

		var url = "https://api.weibo.com/2/friendships/friends/bilateral.json?count=50&access_token=" + token + "&uid=" + uid + "&page=" + page
		xhr.open('GET', url)
		xhr.send()
	}
})
account_xhr.open("GET", "https://api.weibo.com/2/account/get_uid.json?access_token=" + token)
account_xhr.send();
show_loading();

					if (!Ti.App.is_android){
						win.setRightNavButton(done);
					}
					else{
						var ActionBarView = require('ActionBarView');
							var actionBar = new ActionBarView({
							tabs : [
									{
										text : '  返回',
										id : 'back',
										isBack : true,
										__width: __l(70), 
										align : 'center',
										no_sep : true
									},
									{
										text: win.title||"",
										isLabel: true,
										__width: Ti.App.platform_width - __l(154),
										align : 'center',
										no_sep : true
									},
									{
										text : ' 邀请 ',
										id : 'send',
										isButton : true,
										__width: __l(80),
										align : 'right'
									}
								]
							});
									
							actionBar.addEventListener(
								'ActionBar.NavigationTab:Click',
								function(e){
									if (e.tabId == "back")
										win.close();
									else
										done.fireEvent("click")
								}
							);				
							add_action_bar(win, actionBar)
					}

	Ti.App.currentTabGroup.activeTab.open(win, {
	animated : true
});				
}