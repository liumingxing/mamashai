<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta id="viewport" name="viewport" content="width=device-width; initial-scale=1.0; minimum-scale=1.0; maximum-scale=1.0">
<title>预产期计算器</title>
<link rel="stylesheet" type="text/css" href="css/index.css" />

<script src="http://app.baidu.com/static/appstore/monitor.st"></script>
</head>

<body onload="healthtime()">
<div class="box">
<FORM id=health name=health onSubmit="return Datejudgment()" method=get>
<div class="input_form">
    <div>
        <span>末次月经：</span>
        <select name="year" id="input1">
                    <option value=2012>2012</option>
                    <option value=2013>2013</option>
        </select>
        <span>年</span>
        <select name="month" id="input2">
                    <option value=1>1</option>
                    <option value=2>2</option>
                    <option value=3>3</option>
                    <option value=4>4</option>
                    <option value=5>5</option>
                    <option value=6>6</option>
                    <option value=7>7</option>
                    <option value=8>8</option>
                    <option value=9>9</option>
                    <option value=10>10</option>
                    <option value=11>11</option>
                    <option value=12>12</option>
        </select>
        <span>月</span>
        <select name="day" id="input20">
                    <option value=1>1</option>
                    <option value=2>2</option>
                    <option value=3>3</option>
                    <option value=4>4</option>
                    <option value=5>5</option>
                    <option value=6>6</option>
                    <option value=7>7</option>
                    <option value=8>8</option>
                    <option value=9>9</option>
                    <option value=10>10</option>
                    <option value=11>11</option>
                    <option value=12>12</option>
                    <option value=13>13</option>
                    <option value=14>14</option>
                    <option value=15>15</option>
                    <option value=16>16</option>
                    <option value=17>17</option>
                    <option value=18>18</option>
                    <option value=19>19</option>
                    <option value=20>20</option>
                    <option value=21>21</option>
                    <option value=22>22</option>
                    <option value=23>23</option>
                    <option value=24>24</option>
                    <option value=25>25</option>
                    <option value=26>26</option>
                    <option value=27>27</option>
                    <option value=28>28</option>
                    <option value=29>29</option>
                    <option value=30>30</option>
                    <option value=31>31</option>
                </select>
        <span>日<br/>
        周期</span>
        <select name="mweek" id="input3">
                    <option value=26>26</option>
                    <option value=27>27</option>
                    <option value=28 selected=true>28</option>
                    <option value=29>29</option>
                    <option value=30>30</option>
                </select>
        <span>天</span>
        <span class='calc'><a href="javascript:void(0)" onclick="return Datejudgment()">计算</a></span>
    </div>
    <div class="clear"></div>
</div>
<div class='content'>
    <div class="result_form">
        <div>
            <span>准妈妈，您的预产期是</span>
            <span id='yuchana' class='yuchan_field'> </span>
            <span>年</span>
            <span id='yuchanb' class='yuchan_field'> </span>
            <span>月</span>
            <span id='yuchanc' class='yuchan_field'> </span>
            <span>日</span>
        </div>
        <div>
            <span>现为孕</span>
            <span id='yuchan2' class='yuchan_field'> </span>
            <span>周</span>
            <span id='ji' class='yuchan_field'> </span>
            <span>天，距宝宝出生</span>
            <span id='countDown' class='yuchan_field'> </span>
            <span>天</span>
        </div>
    </div>    

    <div class="content_menu">
        <a class="menu" id="menu0" href="javascript:void(0)" onclick='menu0()'>胎儿图像</a>
        <a class="menu" id="menu1" href="javascript:void(0)" onclick='menu1()'>胎儿发育</a>
        <a class="menu" id="menu2" href="javascript:void(0)" onclick='menu2()'>身体变化</a>
        <a class="menu" id="menu3" href="javascript:void(0)" onclick='menu3()'>孕期营养</a>
    </div>
    <div class="content_text">
            <div class="content_font" id="content_font">
                
            </div>
            <div class="content_zhou">
                <a href="javascript:void(0)" onclick="Lastweek()" hidefocus="true">上一周</a>
                <a href="javascript:void(0)" onclick="Nextweek()"  hidefocus="true">下一周</a>
            </div>
    </div>
</div>
</FORM>
</div>
</body>
</html>
<script language="javascript" src="js/index.js"></script>
