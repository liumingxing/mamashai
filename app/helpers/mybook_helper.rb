module MybookHelper
  def share_this_to
    %Q{
      <ul>
        <li><a href="javascript:postToWb()" title="分享到腾讯微博"><img src='http://v.t.qq.com/share/images/s/weiboicon16.png'/></a></li>
        <li><a href="javascript:void((function(s,d,e,r,l,p,t,z,c){var%20f='http://v.t.sina.com.cn/share/share.php?',u=z||d.location,p=['url=',e(u),'&title=',e(t||d.title),'&source=',e(r),'&sourceUrl=',e(l),'&content=',c||'gb2312','&pic=',e(p||'')].join('');function%20a(){if(!window.open([f,p].join(''),'mb',['toolbar=0,status=0,resizable=1,width=440,height=430,left=',(s.width-440)/2,',top=',(s.height-430)/2].join('')))u.href=[f,p].join('');};if(/Firefox/.test(navigator.userAgent))setTimeout(a,0);else%20a();})(screen,document,encodeURIComponent,'新浪-博客','http://blog.sina.com.cn','','分享妈妈晒的图书： 《#{@book.book_name}》','http://#{@book.book_site}','utf-8'));" title="分享到新浪微博"><img src="/images/mybook/ts_r14_c5.jpg"   border=0></a></li>
        <li><a href="javascript:u='http://share.xiaonei.com/share/buttonshare.do?link='+location.href+'&title='+encodeURIComponent(document.title);window.open(u,'xiaonei','toolbar=0,resizable=1,scrollbars=yes,status=1,width=626,height=436');void(0)" title="分享到人人"><img src="/images/mybook/ts_r14_c6.jpg"   border=0></a></li>
        <li><a href="javascript:(function(){window.open('http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url='+ encodeURIComponent(location.href)+ '&title='+encodeURIComponent(document.title),'_blank');})()" title="分享到QQ空间"><img src="/images/mybook/ts_r14_c10.jpg"  border=0></a></li>
        <li><a href="javascript:d=document;t=d.selection?(d.selection.type!='None'?d.selection.createRange().text:''):(d.getSelection?d.getSelection():'');void(kaixin=window.open('http://www.kaixin001.com/~repaste/repaste.php?&rurl='+escape(d.location.href)+'&rtitle='+escape('分享妈妈晒的图书： 《#{@book.book_name}》_妈妈晒')+'&rcontent='+escape('分享妈妈晒的图书： 《#{@book.book_name}》_妈妈晒'),'kaixin'));kaixin.focus();" title="分享到开心"><img src="/images/mybook/ts_r14_c13.jpg"  border=0></a></li>
        <li><a href="javascript:void((function(s,d,e,r,l,p,t,z,c){var f='http://t.sohu.com/third/post.jsp?',u=z||d.location,p=['&url=',e(u),'&title=',e(t||d.title),'&content=',c||'gb2312','&pic=',e(p||'')].join('');function%20a(){if(!window.open([f,p].join(''),'mb',['toolbar=0,status=0,resizable=1,width=660,height=470,left=',(s.width-660)/2,',top=',(s.height-470)/2].join('')))u.href=[f,p].join('');};if(/Firefox/.test(navigator.userAgent))setTimeout(a,0);else%20a();})(screen,document,encodeURIComponent,'','','','','','utf-8'));" title="分享到搜狐微博"><img src="/images/mybook/ts_r14_c15.jpg"  border=0></a></li>
        <li><a href="http://www.douban.com/recommend/?url=http://#{@book.book_site}&title=#{@book.book_name}_妈妈晒;window.open(u,'douban','toolbar=0,resizable=1,scrollbars=yes,status=1,width=450,height=330');void(0)" title="分享到豆瓣"><img src="/images/mybook/ts_r14_c18.jpg"  border=0></a></li>
      </ul>
      <script>
      function postToWb(){
        var _t = encodeURI(document.title);
        var _url = encodeURIComponent(document.location);
        var _assname = encodeURI("mamashai12");
        var _appkey = encodeURI("381d81492d84439dba93a857df2d793e");
        var _pic = encodeURI('http://www.mamashai.com#{@book.logo.url}');
        var _site = 'http://www.mamashai.com/mybook/show/#{@book.id}';
        var _u = 'http://v.t.qq.com/share/share.php?url='+_url+'&appkey='+_appkey+'&site='+_site+'&pic='+_pic+'&title='+_t+'&assname='+_assname;
        window.open( _u,'', 'width=700, height=680, top=0, left=0, toolbar=no, menubar=no, scrollbars=no, location=yes, resizable=no, status=no' );
      }
      </script>
    }
  end
end
