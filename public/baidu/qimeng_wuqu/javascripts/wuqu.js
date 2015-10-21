<script type="text/javascript">
var txt_baby_age = document.getElementById("txt_baby_age");
var rdo_learn_english = document.getElementsByName("rdo_learn_english");
var rdo_qimeng_age = document.getElementsByName("rdo_qimeng_age");

var td_main = document.getElementById("td_main");
var tr_ceshi = document.getElementById("tr_ceshi");

var td_question_1 = document.getElementById("td_question_1");
var td_question_2 = document.getElementById("td_question_2");
var td_question_3 = document.getElementById("td_question_3");

var span_answer_1_yes = document.getElementById("span_answer_1_yes");
var span_answer_2_yes = document.getElementById("span_answer_2_yes");
var span_answer_3_yes = document.getElementById("span_answer_3_yes");

var span_answer_1_no = document.getElementById("span_answer_1_no");
var span_answer_2_no = document.getElementById("span_answer_2_no");
var span_answer_3_no = document.getElementById("span_answer_3_no");

var rdo_answer_1 = document.getElementsByName("rdo_answer_1");
var rdo_answer_2 = document.getElementsByName("rdo_answer_2");
var rdo_answer_3 = document.getElementsByName("rdo_answer_1");

var age_0_question = [["英语启蒙2岁以后开始最好，因为过早会影响母语能力","正确","错误"],["英语启蒙应该从认字母背单词开始","正确","错误"],["英文儿歌要妈妈学会唱了教给宝宝唱最好","正确","错误"],["宝宝听原版儿歌看原版动画有助于培养语感","正确","错误"],["宝宝看动画片要把每一句话翻译给宝宝听","正确","错误"],["妈妈英语不好宝宝英语就没办法启蒙","正确","错误"],["宝宝英语启蒙就应该背句型","正确","错误"],["宝宝听英语就该跟读跟唱，能复述才行","正确","错误"],["宝宝亲子读英文原版书要等他有很多单词量","正确","错误"]];
var age_3_question = [["英语启蒙家庭不用管，直接送培训班就行","正确","错误"],["家庭英语环境主要是家长和孩子英语对话，无法对话就无法启蒙","正确","错误"],["英语就要像数学一样坐在教室学","正确","错误"],["英语启蒙要从对话开始","正确","错误"],["找个外教练口语英语就能学好","正确","错误"],["孩子英语启蒙应该从学科英语开始","正确","错误"],["英语启蒙要有系统的教材才行","正确","错误"],["Phonics很管用，越小学习越好","正确","错误"],["自主阅读不是越早开始越好","正确","错误"],["英语启蒙过程中的发音不准不用纠正","正确","错误"],["英语启蒙要等孩子会说之后才能开始阅读","正确","错误"]];
var age_6_question = [["孩子听不懂英语只能从慢的教学片开始","正确","错误"],["大孩子学英语就应该学教材","正确","错误"],["一般孩子刚开始都听不懂书的音频而且会排斥","正确","错误"],["没有从0岁开始英语启蒙已经来不及了","正确","错误"],["要有听力基础才能学习自然拼音Phonics，所以要先给孩子背单词","正确","错误"],["使用一套教材学到高级别英语水平就够了","正确","错误"],["语感启蒙大家都说好，所以大孩子也必须看","正确","错误"],["动画片看中文字幕影响英语思维所以坚决不能用","正确","错误"],["自然拼音很管用，一学就灵","正确","错误"],["看原版动画片不用把每句话都听懂","正确","错误"]];


var age_0_answer = ["错误","错误","错误","正确","错误","错误","错误","错误","错误"];
var age_3_answer = ["错误","错误","错误","错误","错误","错误","错误","错误","正确","正确","错误"];
var age_6_answer = ["错误","错误","正确","错误","错误","错误","错误","错误","错误","正确"];

var age_0_info = ["1岁以内宝宝的听力辨音能力最强，早启蒙事半功倍。","英语启蒙应该从辨音能力开始。","从辨音能力训练来讲，宝宝听原汁原味的儿歌更好。","听原版儿歌看原版动画，是宝宝培养语感的基础。","看原版动画片不要担心宝宝听不懂。","妈妈有正确的英语启蒙理念，宝宝的英语一样可以很棒！","背出来的句型到实际生活中不如动画片和图画书中的对话更管用。","宝宝学英语输入足够才能输出，不用强求。","国外提倡亲子阅读从0岁开始。"];
var age_3_info = ["英语启蒙家庭和社会要互动。","家庭英语环境主要是听力辨音和听力理解能力的积累。","越小的孩子越应该在玩中学习英语。","英语启蒙应先输入后输出，不用从英语对话开始。","除了外教，家庭听力环境更重要。","孩子英语启蒙应先从听力理解和阅读能力培养开始。","英文启蒙不需要教材，语境越好累计越多，才越好。","要先打好宝宝的英语听力基础再学Phonics。","自主阅读之前的亲子阅读基础很重要。","英语启蒙过程中的发音不准不用纠正。","英语启蒙不一定非要等孩子会说之后才开始读。"];
var age_6_info = ["对孩子来说，只要感兴趣的内容有画面，英语语音快慢无所谓。","大孩子学英语教材不重要，兴趣才重要，有兴趣才有内在动力。","学英语，从孩子喜欢的动画片入手会比较容易。","学英语大孩子有大孩子的优势，只要方法对头一样会有成效。","学英语，孤立的单词尤其是和中文含义对应的单词价值不大。","教材级别的高低和孩子的英语能力不完全成正比。","英语学习素材的选择要符合孩子的认知特点。","看带中文字幕的英文动画片是可以的，只要不形成依赖就好。","孤立地学习phonics难以收到持续的效果。","看原版动画片，韵律节奏比具体的单词对语感更重要。"];

var arr = new Array();
var age = 99;
	function show_ceshi()
	{
		// 获得选定的年龄
		for(i = 0;i < rdo_qimeng_age.length;i++)
		{
			if(rdo_qimeng_age[i].checked)
			{
				age = parseInt(rdo_qimeng_age[i].value);
			    break;
			}
		}
		//alert(age);
		
		while(arr.length < 3)
		{
			if (age == 0)
			{
				var num = Math.floor(Math.random() * 9);
				if(arr.toString().indexOf(num + "") == -1)
				{
					arr.push(num);
				}
				tr_ceshi.style.display = "block";
			}
			else if (age == 3)
			{
				var num = Math.floor(Math.random() * 11);
				if(arr.toString().indexOf(num + "") == -1)
				{
					arr.push(num);
				}
				tr_ceshi.style.display = "block";
			}
			else if (age == 6)
			{
				var num = Math.floor(Math.random() * 10);
				if(arr.toString().indexOf(num + "") == -1)
				{
					arr.push(num);
				}
				tr_ceshi.style.display = "block";
			}
			else
			{
				alert("您还没有填写完相关信息哦～");
				break;
			}
		}
		//alert(arr);
		
		switch (age)
		{
			case 0:
			td_question_1.innerHTML = age_0_question[arr[0]][0];
			td_question_2.innerHTML = age_0_question[arr[1]][0];
			td_question_3.innerHTML = age_0_question[arr[2]][0];
			break
			
			case 3:
			td_question_1.innerHTML = age_3_question[arr[0]][0];
			td_question_2.innerHTML = age_3_question[arr[1]][0];
			td_question_3.innerHTML = age_3_question[arr[2]][0];
			break
			
			case 6:
			td_question_1.innerHTML = age_6_question[arr[0]][0];
			td_question_2.innerHTML = age_6_question[arr[1]][0];
			td_question_3.innerHTML = age_6_question[arr[2]][0];
			break
		}
		
	}
	
	function get_info()
	{
		document.getElementById("table_info").style.display = "block";
		
		wrong_count = 0;	//答题错误的个数
		wrong_items = [];
		
		answer_1 = "";
		answer_2 = "";
		answer_3 = "";
		
		// 获得选定的答案 - 第一题
		for(i = 0;i < rdo_answer_1.length;i++)
		{
			if(rdo_answer_1[i].checked)
			{
				//alert(rdo_answer_1[i].value);
				answer_1 = rdo_answer_1[i].value;
			    break;
			}
		}
		// 获得选定的答案 - 第二题
		for(i = 0;i < rdo_answer_2.length;i++)
		{
			if(rdo_answer_2[i].checked)
			{
				answer_2 = rdo_answer_2[i].value;
			    break;
			}
		}
		// 获得选定的答案 - 第三题
		for(i = 0;i < rdo_answer_3.length;i++)
		{
			if(rdo_answer_3[i].checked)
			{
				answer_3 = rdo_answer_3[i].value;
			    break;
			}
		}
		
		
		if (answer_1 != age_0_answer[arr[0]])
		{
			wrong_count ++;
			wrong_items.push(arr[0]);
		}
		if(answer_2 != age_0_answer[arr[1]])
		{
			wrong_count ++;
			wrong_items.push(arr[1]);
		}
		if(answer_3 != age_0_answer[arr[2]])
		{
			wrong_count ++;
			wrong_items.push(arr[2]);
		}

		//alert(age);
		
		var wrong_info = "";
		
		if (wrong_count == 0)
		{
			td_main.innerHTML = "<p class='STYLE5'>恭喜您！您在孩子英语启蒙问题的认识上非常科学和先进。好家长胜过好老师，相信您的孩子一定会在您的辅导下成为英语小达人哦！妈妈晒也有很多的英语育儿高手，一起来切磋交流吧！</p>"
		}
		else if (wrong_count == 1)
		{
			switch (age)
			{
				case 0:
				wrong_info = age_0_info[wrong_items[0]];
				break
				
				case 3:
				wrong_info = age_3_info[wrong_items[0]];
				break
				
				case 6:
				wrong_info = age_6_info[wrong_items[0]];
				break
			}
			td_main.innerHTML = "<p class='STYLE1'>您对孩子英语启蒙问题的见解颇为专业，但略欠火候。<span class='STYLE5'>" + wrong_info + "</span>与孩子一起学习，互相促进，共同进步，才能奠定孩子一生喜欢学习英语的好习惯！</p>";
		}
		else if (wrong_count == 2)
		{
			switch (age)
			{
				case 0:
				wrong_info = age_0_info[wrong_items[0]] + age_0_info[wrong_items[1]];
				break
				
				case 3:
				wrong_info = age_3_info[wrong_items[0]] + age_3_info[wrong_items[1]];
				break
				
				case 6:
				wrong_info = age_6_info[wrong_items[0]] + age_6_info[wrong_items[1]];
				break
			}
			td_main.innerHTML = "<p class='STYLE1'><span class='STYLE5'>" + wrong_info + "</span>您在孩子英语启蒙的问题上还不够专业，祝愿您早日修炼成孩子成长过程中的良师益友和他们的指路明灯！</p>";
		}
		else if (wrong_count == 3)
		{
			switch (age)
			{
				case 0:
				wrong_info = age_0_info[wrong_items[0]] + age_0_info[wrong_items[1]] + age_0_info[wrong_items[2]];
				break
				
				case 3:
				wrong_info = age_3_info[wrong_items[0]] + age_3_info[wrong_items[1]] + age_3_info[wrong_items[2]];
				break
				
				case 6:
				wrong_info = age_6_info[wrong_items[0]] + age_6_info[wrong_items[1]] + age_6_info[wrong_items[2]];
				break
			}
			td_main.innerHTML = "<p class='STYLE1'><span class='STYLE5'>" + wrong_info + "</span>非常遗憾，您在孩子英语启蒙问题的认识上有失偏颇！但没关系，教育孩子，只要用心，就一定能做好，加油！</p>";
		}
	}

	
	function get_wrong_1()
	{
		document.getElementById("td_tab").style.backgroundImage = "url(images/a_r4_c1.gif)"
		
		document.getElementById("td_main").innerHTML = "<p class='STYLE2'>开始学英语就要让孩子认字母，背单词</p><p class='STYLE1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;这是一个比较大也非常普遍的误区，有点类似教孩子中文就一定要用挂图教孩子认字、认词一样，似乎只有认识了字母、单词，才是学到了东西。字和词是死的，而对于一种语言的理解才是最重要的。怎么算理解?</p><p class='STYLE1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;最基本的就是当他听到一句话，能够和特定的经历、状态、场合、动作联系起来，能够反应，这是最重要的。想想小孩子学说话，开始蹦出来的词，都是联系具体的场景学会的。所以英语学习也应如此。</p>";
	}
	
	function get_wrong_2()
	{
		document.getElementById("td_tab").style.backgroundImage = "url(images/a_r4_c5.gif)"
		document.getElementById("td_main").innerHTML = "<p class='STYLE2'>听英语的同时就要求孩子去跟读</p><p class='STYLE1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;很多妈妈急于用教的方式，说一个，就要求孩子跟着读跟着唱。有些外教机构也要求孩子回家跟读。但是在条件不成熟的时候，大人的要求只能让孩子退缩，甚至产生畏惧心理。从孩子的心理来讲，这种做法很容易让孩子对英语失去兴趣。</p><p class='STYLE1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;很多外教要求学生模仿跟读，目的是为了正音。对于从小对英语语音有大量输入的孩子来讲，听外教的语音会是一件很容易的事情。听清楚了自然就能模仿出来。当他准备好了的时候，你想不让他输出都难。</p>";
	}
	
	function get_wrong_3()
	{
		document.getElementById("td_tab").style.backgroundImage = "url(images/a_r4_c8.gif)"
		document.getElementById("td_main").innerHTML = "<p class='STYLE2'>要求孩子像背古诗一样背英语</p><p class='STYLE1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;目前有些家长为了提高孩子的听力水平，要求孩子跟读，背诵电影台词，也有的用各种成人教材给孩子背诵，这些和孩子认知能力不相符的东西，都可能对孩子的英语兴趣产生损害。</p><p class='STYLE1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;一定要等孩子准备好了再读，这是前提。如果一本书读不下来，那就降低难度，换一本简单的来读，而不是要求所有的孩子都读一个难度的书。这才是尊重孩子个体能力差异、因材施教的做法。</p>";
	}
	
	function get_wrong_4()
	{
		document.getElementById("td_tab").style.backgroundImage = "url(images/a_r4_c9.gif)"
		document.getElementById("td_main").innerHTML = "<p class='STYLE2'>要求孩子和家长用英语对话</p><p class='STYLE1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;用英语对话，是很多家长认为能提高孩子英语水平的一个方法，但是我对这种方法一直存有怀疑。首先中国人英语口语表达可能根本不符合老外的口语表达方式。同时对话还可能带给孩子压力。另外一个角度，就是口音的问题。</p><p class='STYLE1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;如果确实需要和孩子说英语，那不如和孩子一起看原汁原味的东西，读绘本就是一个很好的办法。因为亲子阅读是没有人能替代的，是孩子成长必经的阶段。而且，最好为孩子提供原汁原味的英语语音资料。</p>";
	}
	
	function get_wrong_5()
	{
		document.getElementById("td_tab").style.backgroundImage = "url(images/a_r4_c10.gif)"
		document.getElementById("td_main").innerHTML = "<p class='STYLE2'>孩子用英文对话熟练之后才能开始阅读</p><p class='STYLE1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;目前很多家长花大价钱找外教练口语，但是很多孩子还是不能做到和老外无障碍交流。之所以难以和老外自如交流，除去听力辨音能力不高这个瓶颈外，和孩子的英语思维有很大关系。英语思维从何而来?需要的是场景的积累。</p><p class='STYLE1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;有人把读原版书看成是一件门槛很高的事情。实际上，四岁以前进行的亲子阅读，重点进行的就是情境对应训练，记住多少单词不应该被列入考量标准之列。情境对应能力和辨音能力一样，是内化之后形成的能力。</p>";
		
	}
	function get_wrong_6()
	{
		document.getElementById("td_tab").style.backgroundImage = "url(images/a_r4_c11.gif)"
		document.getElementById("td_main").innerHTML = "<p class='STYLE2'>找专门的外教练口语就能说一口流利的英文</p><p class='STYLE1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;在孩子不进行大量听力输入的情况下，在没有任何英语语音和场景积累的情况下，以为有一些单词量就可以直接找外教，并希望依靠和外教谈天气、聊爱好就可以解决孩子的口语问题，是非常不现实的。</p><p class='STYLE1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;重视孩子在家庭中的情境对应积累，多听原版儿歌、多看原版动画片、多听原版故事的音频，这些都是积累英语语音信号、训练韵律节奏和语感的有效途径。孩子的听力辨音能力、听觉记忆能力有了，才有可能听得懂别人说的是什么。</p>";
	}
	
	function feiqi()
	{
		if (age == 0)
		{		
			//alert(arr[0]);
			td_question_1.innerHTML = age_0_question[arr[0]][0];
			td_question_2.innerHTML = age_0_question[arr[1]][0];
			td_question_3.innerHTML = age_0_question[arr[2]][0];
			
			//span_answer_1_yes.innerHTML = age_0_question[arr[0]][1];
			//span_answer_2_yes.innerHTML = age_0_question[arr[1]][1];
			//span_answer_3_yes.innerHTML = age_0_question[arr[2]][1];
			
			//span_answer_1_no.innerHTML = age_0_question[arr[0]][2];
			//span_answer_2_no.innerHTML = age_0_question[arr[1]][2];
			//span_answer_3_no.innerHTML = age_0_question[arr[2]][2];
		}
		if (age == 3)
		{
			td_question_1.innerHTML = age_3_question[arr[0]][0];
			td_question_2.innerHTML = age_3_question[arr[1]][0];
			td_question_3.innerHTML = age_3_question[arr[2]][0];
			
			//span_answer_1_yes.innerHTML = age_3_question[arr[0]][1];
			//span_answer_2_yes.innerHTML = age_3_question[arr[1]][1];
			//span_answer_3_yes.innerHTML = age_3_question[arr[2]][1];
			//
			//span_answer_1_no.innerHTML = age_3_question[arr[0]][2];
			//span_answer_2_no.innerHTML = age_3_question[arr[1]][2];
			//span_answer_3_no.innerHTML = age_3_question[arr[2]][2];
		}
		if (age == 6)
		{
			td_question_1.innerHTML = age_6_question[arr[0]][0];
			td_question_2.innerHTML = age_6_question[arr[1]][0];
			td_question_3.innerHTML = age_6_question[arr[2]][0];
			
			//span_answer_1_yes.innerHTML = age_6_question[arr[0]][1];
			//span_answer_2_yes.innerHTML = age_6_question[arr[1]][1];
			//span_answer_3_yes.innerHTML = age_6_question[arr[2]][1];
			//
			//span_answer_1_no.innerHTML = age_6_question[arr[0]][2];
			//span_answer_2_no.innerHTML = age_6_question[arr[1]][2];
			//span_answer_3_no.innerHTML = age_6_question[arr[2]][2];
		}
	}
</script>