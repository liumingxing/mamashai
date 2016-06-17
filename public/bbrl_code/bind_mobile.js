var win = Ti.UI.createWindow({
  backgroundColor: 'white',
  title: '绑定手机号'
});
var counter = null;
win.addEventListener('close', function(e) {
  if (counter) {
    clearInterval(counter)
  }
})

var scroll = Ti.UI.createScrollView({
  showVerticalScrollIndicator: true,
  showHorizontalScrollIndicator: false,
  width: Ti.UI.FILL,
  bottom: 0,
});

var wrapper1 = Ti.UI.createView({
  width: __l(240),
  top: __l(30),
  height: Ti.UI.SIZE
})
var mobile = Ti.UI.createTextField({
  top: __l(0),
  hintText: "请输入手机号",
  width: __l(240),
  height: __l(40),
  font: {fontSize: __l(16)},
  keyboardType: Titanium.UI.KEYBOARD_PHONE_PAD,
  borderStyle: Titanium.UI.INPUT_BORDERSTYLE_ROUNDED
})

var validate = Ti.UI.createTextField({
  top: __l(56),
  left: __l(0),
  hintText: "请输入验证码",
  width: __l(150),
  height: __l(40),
  font: {fontSize: __l(16)},
  keyboardType: Titanium.UI.KEYBOARD_PHONE_PAD,
  borderStyle: Titanium.UI.INPUT_BORDERSTYLE_ROUNDED
})

var get_validate = Ti.UI.createButton({
  top: __l(56),
  right: __l(0),
  width: __l(80),
  height: Ti.App.is_android ? __l(32) : __l(40),
  title: "获取验证码",
  borderRadius: __l(4),
  font: {fontSize: __l(13)}
})
pre_btn(get_validate);
get_validate.addEventListener("click", function (e) {
  if (!mobile.value || (mobile.value.length != 11) ) {
    show_alert('提示','请输入正确的手机号码')
    return
  }
  get_validate.touchEnabled = false
  get_validate.backgroundImage = "/images/disable_bg.png";

  var count=60;

  counter=setInterval(timer, 1000);

  function recover_validate() {
    clearInterval(counter);
    get_validate.touchEnabled = true
    get_validate.backgroundImage = "/images/bg.png";
    get_validate.title = '重获验证码'
  }

  function timer() {
    count=count-1;
    if (count <= 0)
    {
      clearInterval(counter);
      recover_validate();
      return;
    }
    get_validate.title = '剩余' + count + '秒'
  }

  http_call(Ti.App.mamashai  + "/api/statuses/get_mobile_validate_message?telephone="+mobile.value + '&' + account_str(),
    function (e) {
      var json = JSON.parse(e.responseText)
      if (json.code == -1) {
        show_alert('提示', json.text)
        recover_validate();
      } else {
        show_notice("请等待验证短信")
      }
    })
})

var submit = Ti.UI.createButton({
  top: __l(112),
  width: __l(240),
  title: "绑  定",
  height: Ti.App.is_android ? __l(40) : __l(40),
  color: "white",
  selectedColor: "#eee",
  borderRadius: __l(4),
  backgroundColor: Ti.App.bar_color,
  font: {fontSize: __l(13)}
})
pre_btn(submit);
submit.addEventListener("click", function (e) {
  if (mobile.value.length != 11) {
    show_alert("提示", "请输入正确的电话号码");
    return;
  }
  if (validate.value.length == 0) {
    show_alert("提示", "请输入验证码");
    return;
  }

  http_call(Ti.App.mamashai + "/api/statuses/change_mobile?telephone="+mobile.value+'&code='+validate.value + '&'+account_str(),
    function (e) {
      var json = JSON.parse(e.responseText)
      if (json.code == -1) {
        show_alert(json.text)
      } else {
        require('lib/mamashai_db').db.insert_json("user_bind_mobile", user_id(), mobile.value);
        win.close()
        show_notice(json.text);
      }
    })
})

wrapper1.add(mobile);
wrapper1.add(validate);
wrapper1.add(get_validate);
wrapper1.add(submit);

scroll.add(wrapper1)
win.add(scroll)

add_default_action_bar(win, win.title);

Ti.App.currentTabGroup.activeTab.open(win, {
  animated: true
});
