function inq(form){
var  y=form.y.value;
var  m=form.m.value;
var  da=form.da.value;
var  y1=form.y1.value;
var  m1=form.m1.value;
var  da1=form.da1.value;
  if (m==""||da==""){
   document.getElementById("abc").style.display="";
   document.getElementById("abc").innerHTML="<br><br>"; 
  }
  if (m>12||m<1){alert("月应在1与12之间。");} 
 if (da>31||da<1){alert("日应在1与31之间。");}
 if ((m==4||m==6||m==9||m==11)&&da>30){   alert(m+"月只有30天。");}
  if (y%4!=0&&m==2&&da>28){alert(y+"年是平年，2月只有28天。");}
 if (m==2&&da>29){ alert(y+"年是闰年，2月只有29天。");}

  if (m1>12||m1<0){alert("月应在1与12之间。");}
 if (da1>31||da1<1){alert("日应在1与31之间。");}
 if ((m1==4||m1==6||m1==9||m1==11)&&da1>30){   alert(m+"月只有30天。");}
  if (y1%4!=0&&m1==2&&da1>28){alert(y+"年是平年，2月只有28天。");}
 if (m1==2&&da1>29){ alert(y+"年是闰年，2月只有29天。");}
  var returnAge;
            var birthYear = y;   
            var birthMonth =m;   
            var birthDay = da;   
       
            d = new Date();   
            var nowYear = d.getFullYear();   
            var nowMonth = d.getMonth() + 1;   
            var nowDay = d.getDate();   
       
            if(nowYear == birthYear){   
                returnAge = 0; 
            } else {   
                var ageDiff = nowYear - birthYear ;   
                if(ageDiff > 0){   
                    if(nowMonth == birthMonth){   
                        var dayDiff = nowDay - birthDay;
                        if(dayDiff > 0){   
                            returnAge = ageDiff;   
                        } else {   
                            returnAge = ageDiff - 1;   
                        }   
                    } else {   
                        var monthDiff = nowMonth - birthMonth; 
                        if(monthDiff < 0) {   
                            returnAge = ageDiff - 1;   
                        } else {   
                            returnAge = ageDiff ;   
                        }   
                    }   
                } else {   
                    returnAge =-1;
                    alert("出生日期输入错误 晚于今天");
                }   
              
			if(ageDiff==18 || m1==1 || m1==3 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}
			
			if(ageDiff==19 || m1==2 || m1==4 || m1==5 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}
			
			if(ageDiff==20 || m1==1 || m1==2 || m1==3 || m1==10){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}
			
			if(ageDiff==21 || m1==1){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==22 || m1==2 || m1==5 || m1==8 || m1==11){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==23 || m1==3 || m1==6 || m1==8 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}
			
			if(ageDiff==24 || m1==2 || m1==5 || m1==8 || m1==9 || m1==10 || m1==11 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}
			
			if(ageDiff==25 || m1==1 || m1==4 || m1==5 || m1==7){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}
			
			if(ageDiff==26 || m1==6 || m1==8){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==27 || m1==1 || m1==3 || m1==5 || m1==6 || m1==11){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}
			
			if(ageDiff==28 || m1==2 || m1==4 || m1==5 || m1==6 || m1==11 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}
			
			if(ageDiff==29 || m1==1 || m1==3 || m1==4 || m1==10 || m1==11){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}
			
			if(ageDiff==30 || m1==1 || m1==11 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==31 || m1==1 || m1==3 || m1==5 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==32 || m1==1 || m1==3 || m1==5 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==33 || m1==2 || m1==4 || m1==8 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==34 || m1==1 || m1==2 || m1==3 || m1==11 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==35 || m1==1 || m1==2 || m1==4 || m1==8 || m1==11 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==36 || m1==2 || m1==3 || m1==9 || m1==10 || m1==11 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==37 || m1==1 || m1==3 || m1==4 || m1==6 || m1==8 || m1==10 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==38 || m1==2 || m1==4 || m1==5 || m1==7 || m1==9 || m1==11){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==39 || m1==1 || m1==3 || m1==4 || m1==8 || m1==10){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==40 || m1==2 || m1==4 || m1==6 || m1==7 || m1==9 || m1==11){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==41 || m1==2 || m1==4 || m1==6 || m1==9 || m1==11){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}
			
			if(ageDiff==42 || m1==1 || m1==3 || m1==5 || m1==7 || m1==10 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==43 || m1==2 || m1==4 || m1==6 || m1==8){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==44 || m1==3 || m1==7 || m1==9 || m1==11 || m1==12){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
			
			if(ageDiff==45 || m1==1 || m1==4 || m1==5 || m1==6 || m1==8 || m1==10){
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：男孩"
			}else{
				document.getElementById("abc").innerHTML="根据生男生女清宫图，你怀的可能是：女孩"
			}
		}
}// JavaScript Document