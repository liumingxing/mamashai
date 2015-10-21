
var PageName = '名词解释';
var PageId = '8302457274954dc2b60582aa1e833ade'
var PageUrl = '名词解释.html'
document.title = '名词解释';
var PageNotes = 
{
"pageName":"名词解释",
"showNotesNames":"False"}
var $shuangdingjing = '';

var $fuwei = '';

var $guguchang = '';

var $yuchanqiYear = '';

var $yuchanqiMonth = '';

var $yuchanqiDay = '';

var $CSUM;

var hasQuery = false;
var query = window.location.hash.substring(1);
if (query.length > 0) hasQuery = true;
var vars = query.split("&");
for (var i = 0; i < vars.length; i++) {
    var pair = vars[i].split("=");
    if (pair[0].length > 0) eval("$" + pair[0] + " = decodeURIComponent(pair[1]);");
} 

if (hasQuery && $CSUM != 1) {
alert('Prototype Warning: The variable values were too long to pass to this page.\nIf you are using IE, using Firefox will support more data.');
}

function GetQuerystring() {
    return '#shuangdingjing=' + encodeURIComponent($shuangdingjing) + '&fuwei=' + encodeURIComponent($fuwei) + '&guguchang=' + encodeURIComponent($guguchang) + '&yuchanqiYear=' + encodeURIComponent($yuchanqiYear) + '&yuchanqiMonth=' + encodeURIComponent($yuchanqiMonth) + '&yuchanqiDay=' + encodeURIComponent($yuchanqiDay) + '&CSUM=1';
}

function PopulateVariables(value) {
    var d = new Date();
  value = value.replace(/\[\[shuangdingjing\]\]/g, $shuangdingjing);
  value = value.replace(/\[\[fuwei\]\]/g, $fuwei);
  value = value.replace(/\[\[guguchang\]\]/g, $guguchang);
  value = value.replace(/\[\[yuchanqiYear\]\]/g, $yuchanqiYear);
  value = value.replace(/\[\[yuchanqiMonth\]\]/g, $yuchanqiMonth);
  value = value.replace(/\[\[yuchanqiDay\]\]/g, $yuchanqiDay);
  value = value.replace(/\[\[PageName\]\]/g, PageName);
  value = value.replace(/\[\[GenDay\]\]/g, '13');
  value = value.replace(/\[\[GenMonth\]\]/g, '10');
  value = value.replace(/\[\[GenMonthName\]\]/g, 'October');
  value = value.replace(/\[\[GenDayOfWeek\]\]/g, 'Thursday');
  value = value.replace(/\[\[GenYear\]\]/g, '2011');
  value = value.replace(/\[\[Day\]\]/g, d.getDate());
  value = value.replace(/\[\[Month\]\]/g, d.getMonth() + 1);
  value = value.replace(/\[\[MonthName\]\]/g, GetMonthString(d.getMonth()));
  value = value.replace(/\[\[DayOfWeek\]\]/g, GetDayString(d.getDay()));
  value = value.replace(/\[\[Year\]\]/g, d.getFullYear());
  return value;
}

function OnLoad(e) {

}

var u17 = document.getElementById('u17');

var u20 = document.getElementById('u20');
gv_vAlignTable['u20'] = 'center';
var u21 = document.getElementById('u21');

var u22 = document.getElementById('u22');
gv_vAlignTable['u22'] = 'center';
var u19 = document.getElementById('u19');

var u16 = document.getElementById('u16');

var u15 = document.getElementById('u15');
gv_vAlignTable['u15'] = 'center';
var u10 = document.getElementById('u10');

u10.style.cursor = 'pointer';
if (bIE) u10.attachEvent("onclick", Clicku10);
else u10.addEventListener("click", Clicku10, true);
function Clicku10(e)
{
windowEvent = e;


if (true) {

	self.location.href="胎儿发育指标.html" + GetQuerystring();

}

}

if (bIE) u10.attachEvent("onmouseover", MouseOveru10);
else u10.addEventListener("mouseover", MouseOveru10, true);
function MouseOveru10(e)
{
windowEvent = e;

if (!IsTrueMouseOver('u10',e)) return;
if (true) {

	MoveWidgetTo('u7', 71,53,'none',300);

}

}
gv_vAlignTable['u10'] = 'top';
var u11 = document.getElementById('u11');

u11.style.cursor = 'pointer';
if (bIE) u11.attachEvent("onclick", Clicku11);
else u11.addEventListener("click", Clicku11, true);
function Clicku11(e)
{
windowEvent = e;


if (true) {

	self.location.href="resources/reload.html#" + encodeURI(PageUrl + GetQuerystring());

}

}

if (bIE) u11.attachEvent("onmouseover", MouseOveru11);
else u11.addEventListener("mouseover", MouseOveru11, true);
function MouseOveru11(e)
{
windowEvent = e;

if (!IsTrueMouseOver('u11',e)) return;
if (true) {

	MoveWidgetTo('u7', 201,53,'none',300);

}

}
gv_vAlignTable['u11'] = 'top';
var u12 = document.getElementById('u12');
gv_vAlignTable['u12'] = 'top';
var u13 = document.getElementById('u13');

var u14 = document.getElementById('u14');

u14.style.cursor = 'pointer';
if (bIE) u14.attachEvent("onclick", Clicku14);
else u14.addEventListener("click", Clicku14, true);
function Clicku14(e)
{
windowEvent = e;


if ((GetSelectedOption('u13')) == ('CRL')) {

	SetPanelState('u16', 'pd0u16','none','',500,'fade','',500);

}
else
if ((GetSelectedOption('u13')) == ('FL')) {

	SetPanelState('u16', 'pd1u16','none','',500,'fade','',500);

}
else
if ((GetSelectedOption('u13')) == ('双顶径')) {

	SetPanelState('u16', 'pd2u16','none','',500,'fade','',500);

}

}

var u0 = document.getElementById('u0');

var u1 = document.getElementById('u1');
gv_vAlignTable['u1'] = 'center';
var u2 = document.getElementById('u2');

var u3 = document.getElementById('u3');
gv_vAlignTable['u3'] = 'center';
var u4 = document.getElementById('u4');
gv_vAlignTable['u4'] = 'top';
var u5 = document.getElementById('u5');

var u6 = document.getElementById('u6');
gv_vAlignTable['u6'] = 'center';
var u7 = document.getElementById('u7');

var u8 = document.getElementById('u8');

var u9 = document.getElementById('u9');
gv_vAlignTable['u9'] = 'center';
var u18 = document.getElementById('u18');
gv_vAlignTable['u18'] = 'center';
if (window.OnLoad) OnLoad();
