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