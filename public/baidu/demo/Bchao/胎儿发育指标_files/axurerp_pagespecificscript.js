
var PageName = '胎儿发育指标';
var PageId = '2ec1173d327d46d5843672146a848b4f'
var PageUrl = '胎儿发育指标.html'
document.title = '胎儿发育指标';
var PageNotes = 
{
"pageName":"胎儿发育指标",
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

var u80 = document.getElementById('u80');
gv_vAlignTable['u80'] = 'top';
var u81 = document.getElementById('u81');

var u82 = document.getElementById('u82');
gv_vAlignTable['u82'] = 'top';
var u83 = document.getElementById('u83');

var u84 = document.getElementById('u84');
gv_vAlignTable['u84'] = 'center';
var u85 = document.getElementById('u85');

var u86 = document.getElementById('u86');
gv_vAlignTable['u86'] = 'top';
var u87 = document.getElementById('u87');
gv_vAlignTable['u87'] = 'top';
var u88 = document.getElementById('u88');

var u89 = document.getElementById('u89');
gv_vAlignTable['u89'] = 'center';
var u90 = document.getElementById('u90');
gv_vAlignTable['u90'] = 'top';
var u91 = document.getElementById('u91');
gv_vAlignTable['u91'] = 'top';
var u92 = document.getElementById('u92');

var u10 = document.getElementById('u10');

u10.style.cursor = 'pointer';
if (bIE) u10.attachEvent("onclick", Clicku10);
else u10.addEventListener("click", Clicku10, true);
function Clicku10(e)
{
windowEvent = e;


if (true) {

	self.location.href="resources/reload.html#" + encodeURI(PageUrl + GetQuerystring());

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

	self.location.href="名词解释.html" + GetQuerystring();

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

var u13 = document.getElementById('u13');
gv_vAlignTable['u13'] = 'top';
var u14 = document.getElementById('u14');

u14.style.cursor = 'pointer';
if (bIE) u14.attachEvent("onclick", Clicku14);
else u14.addEventListener("click", Clicku14, true);
function Clicku14(e)
{
windowEvent = e;


if (((GetSelectedOption('u38')) == ('年')) || (((GetSelectedOption('u38')) == ('年')) || (((GetSelectedOption('u38')) == ('年')) || (((GetWidgetFormText('u22')) == ('')) || (((GetWidgetFormText('u23')) == ('')) || ((GetWidgetFormText('u24')) == (''))))))) {

	SetPanelVisibility('u17','','fade',500);

}

if (((GetSelectedOption('u38')) != ('年')) && (((GetSelectedOption('u38')) != ('年')) && (((GetSelectedOption('u38')) != ('年')) && (((GetWidgetFormText('u22')) != ('')) && (((GetWidgetFormText('u23')) != ('')) && ((GetWidgetFormText('u24')) != (''))))))) {

	SetPanelVisibility('u17','hidden','fade',500);

}

if (((GetSelectedOption('u38')) != ('年')) && (((GetSelectedOption('u39')) != ('月')) && (((GetSelectedOption('u40')) != ('日')) && ((IsValueNumeric(GetWidgetFormText('u22'))) && ((IsValueNumeric(GetWidgetFormText('u23'))) && (IsValueNumeric(GetWidgetFormText('u24')))))))) {

	SetPanelState('u51', 'pd1u51','none','',500,'fade','',500);

	SetPanelState('u93', 'pd1u93','none','',500,'fade','',500);

	MoveWidgetBy('u93',0,90,'none',500);

SetGlobalVariableValue('$shuangdingjing', GetWidgetFormText('u22'));

SetWidgetRichText('u66', '<p style="text-align:center;"><span style="font-family:Arial;font-size:13px;font-weight:normal;font-style:normal;text-decoration:none;color:#333333;">' + (GetGlobalVariableValue('$shuangdingjing')) + '</span></p>');

SetGlobalVariableValue('$fuwei', GetWidgetFormText('u23'));

SetWidgetRichText('u72', '<p style="text-align:center;"><span style="font-family:Arial;font-size:13px;font-weight:normal;font-style:normal;text-decoration:none;color:#333333;">' + (GetGlobalVariableValue('$fuwei')) + '</span></p>');

SetGlobalVariableValue('$guguchang', GetWidgetFormText('u24'));

SetWidgetRichText('u78', '<p style="text-align:center;"><span style="font-family:Arial;font-size:13px;font-weight:normal;font-style:normal;text-decoration:none;color:#333333;">' + (GetGlobalVariableValue('$guguchang')) + '</span></p>');

SetWidgetRichText('u84', '<p style="text-align:center;"><span style="font-family:Arial;font-size:13px;font-weight:normal;font-style:normal;text-decoration:none;color:#333333;">500</span></p>');

}

}

var u15 = document.getElementById('u15');
gv_vAlignTable['u15'] = 'center';
var u16 = document.getElementById('u16');

var u17 = document.getElementById('u17');

var u18 = document.getElementById('u18');
gv_vAlignTable['u18'] = 'top';
var u19 = document.getElementById('u19');
gv_vAlignTable['u19'] = 'top';
var u20 = document.getElementById('u20');
gv_vAlignTable['u20'] = 'top';
var u21 = document.getElementById('u21');
gv_vAlignTable['u21'] = 'top';
var u22 = document.getElementById('u22');

if (bIE) u22.attachEvent("onblur", LostFocusu22);
else u22.addEventListener("blur", LostFocusu22, true);
function LostFocusu22(e)
{
windowEvent = e;


if (IsValueNotNumeric(GetWidgetFormText('u22'))) {

	SetPanelVisibility('u45','','fade',500);

}
else
if (IsValueNumeric(GetWidgetFormText('u22'))) {

	SetPanelVisibility('u45','hidden','fade',500);

}

}

var u23 = document.getElementById('u23');

if (bIE) u23.attachEvent("onblur", LostFocusu23);
else u23.addEventListener("blur", LostFocusu23, true);
function LostFocusu23(e)
{
windowEvent = e;


if (IsValueNotNumeric(GetWidgetFormText('u23'))) {

	SetPanelVisibility('u47','','fade',500);

}
else
if (IsValueNumeric(GetWidgetFormText('u23'))) {

	SetPanelVisibility('u47','hidden','fade',500);

}

}

var u24 = document.getElementById('u24');

if (bIE) u24.attachEvent("onblur", LostFocusu24);
else u24.addEventListener("blur", LostFocusu24, true);
function LostFocusu24(e)
{
windowEvent = e;


if (IsValueNotNumeric(GetWidgetFormText('u24'))) {

	SetPanelVisibility('u49','','fade',500);

}
else
if (IsValueNumeric(GetWidgetFormText('u24'))) {

	SetPanelVisibility('u49','hidden','fade',500);

}

}

var u25 = document.getElementById('u25');
gv_vAlignTable['u25'] = 'top';
var u26 = document.getElementById('u26');
gv_vAlignTable['u26'] = 'top';
var u27 = document.getElementById('u27');
gv_vAlignTable['u27'] = 'top';
var u28 = document.getElementById('u28');
gv_vAlignTable['u28'] = 'top';
var u29 = document.getElementById('u29');

var u100 = document.getElementById('u100');
gv_vAlignTable['u100'] = 'center';
var u101 = document.getElementById('u101');
gv_vAlignTable['u101'] = 'top';
var u102 = document.getElementById('u102');

var u103 = document.getElementById('u103');
gv_vAlignTable['u103'] = 'center';
var u104 = document.getElementById('u104');

var u105 = document.getElementById('u105');
gv_vAlignTable['u105'] = 'center';
var u30 = document.getElementById('u30');
gv_vAlignTable['u30'] = 'top';
var u31 = document.getElementById('u31');

if (bIE) u31.attachEvent("onblur", LostFocusu31);
else u31.addEventListener("blur", LostFocusu31, true);
function LostFocusu31(e)
{
windowEvent = e;


if (((GetSelectedOption('u31')) != ('年')) && (((GetSelectedOption('u32')) != ('月')) && ((GetSelectedOption('u33')) != ('日')))) {

	SetPanelVisibility('u17','hidden','fade',500);

}

}

var u32 = document.getElementById('u32');

if (bIE) u32.attachEvent("onblur", LostFocusu32);
else u32.addEventListener("blur", LostFocusu32, true);
function LostFocusu32(e)
{
windowEvent = e;


if (((GetSelectedOption('u31')) != ('年')) && (((GetSelectedOption('u32')) != ('月')) && ((GetSelectedOption('u33')) != ('日')))) {

	SetPanelVisibility('u17','hidden','fade',500);

}

}

var u33 = document.getElementById('u33');

if (bIE) u33.attachEvent("onblur", LostFocusu33);
else u33.addEventListener("blur", LostFocusu33, true);
function LostFocusu33(e)
{
windowEvent = e;


if (((GetSelectedOption('u31')) != ('年')) && (((GetSelectedOption('u32')) != ('月')) && ((GetSelectedOption('u33')) != ('日')))) {

	SetPanelVisibility('u17','hidden','fade',500);

}

}

var u34 = document.getElementById('u34');
gv_vAlignTable['u34'] = 'top';
var u35 = document.getElementById('u35');

var u36 = document.getElementById('u36');
gv_vAlignTable['u36'] = 'top';
var u37 = document.getElementById('u37');
gv_vAlignTable['u37'] = 'top';
var u38 = document.getElementById('u38');

if (bIE) u38.attachEvent("onblur", LostFocusu38);
else u38.addEventListener("blur", LostFocusu38, true);
function LostFocusu38(e)
{
windowEvent = e;


if (((GetSelectedOption('u38')) != ('年')) && (((GetSelectedOption('u39')) != ('月')) && ((GetSelectedOption('u40')) != ('日')))) {

	SetPanelVisibility('u17','hidden','fade',500);

SetGlobalVariableValue('$yuchanqiYear', GetSelectedOption('u38'));

}

}

var u39 = document.getElementById('u39');

if (bIE) u39.attachEvent("onblur", LostFocusu39);
else u39.addEventListener("blur", LostFocusu39, true);
function LostFocusu39(e)
{
windowEvent = e;


if (((GetSelectedOption('u38')) != ('年')) && (((GetSelectedOption('u39')) != ('月')) && ((GetSelectedOption('u40')) != ('日')))) {

	SetPanelVisibility('u17','hidden','fade',500);

SetGlobalVariableValue('$yuchanqiMonth', GetSelectedOption('u39'));

}

}

var u93 = document.getElementById('u93');

var u94 = document.getElementById('u94');

var u95 = document.getElementById('u95');
gv_vAlignTable['u95'] = 'center';
var u96 = document.getElementById('u96');
gv_vAlignTable['u96'] = 'top';
var u97 = document.getElementById('u97');

var u98 = document.getElementById('u98');
gv_vAlignTable['u98'] = 'center';
var u99 = document.getElementById('u99');

var u40 = document.getElementById('u40');

if (bIE) u40.attachEvent("onblur", LostFocusu40);
else u40.addEventListener("blur", LostFocusu40, true);
function LostFocusu40(e)
{
windowEvent = e;


if (((GetSelectedOption('u38')) != ('年')) && (((GetSelectedOption('u39')) != ('月')) && ((GetSelectedOption('u40')) != ('日')))) {

	SetPanelVisibility('u17','hidden','fade',500);

SetGlobalVariableValue('$yuchanqiDay', GetSelectedOption('u40'));

}

}

var u41 = document.getElementById('u41');

u41.style.cursor = 'pointer';
if (bIE) u41.attachEvent("onclick", Clicku41);
else u41.addEventListener("click", Clicku41, true);
function Clicku41(e)
{
windowEvent = e;


if (true) {

	SetPanelState('u29', 'pd1u29','none','',500,'swing','right',500);

}

}

var u42 = document.getElementById('u42');
gv_vAlignTable['u42'] = 'center';
var u43 = document.getElementById('u43');
gv_vAlignTable['u43'] = 'top';
var u44 = document.getElementById('u44');
gv_vAlignTable['u44'] = 'top';
var u45 = document.getElementById('u45');

var u46 = document.getElementById('u46');
gv_vAlignTable['u46'] = 'top';
var u47 = document.getElementById('u47');

var u48 = document.getElementById('u48');
gv_vAlignTable['u48'] = 'top';
var u49 = document.getElementById('u49');

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
var u50 = document.getElementById('u50');
gv_vAlignTable['u50'] = 'top';
var u51 = document.getElementById('u51');

var u52 = document.getElementById('u52');

var u53 = document.getElementById('u53');
gv_vAlignTable['u53'] = 'center';
var u54 = document.getElementById('u54');
gv_vAlignTable['u54'] = 'top';
var u55 = document.getElementById('u55');

var u56 = document.getElementById('u56');

var u57 = document.getElementById('u57');

var u58 = document.getElementById('u58');
gv_vAlignTable['u58'] = 'top';
var u59 = document.getElementById('u59');

var u60 = document.getElementById('u60');
gv_vAlignTable['u60'] = 'center';
var u61 = document.getElementById('u61');

var u62 = document.getElementById('u62');
gv_vAlignTable['u62'] = 'top';
var u63 = document.getElementById('u63');

var u64 = document.getElementById('u64');
gv_vAlignTable['u64'] = 'top';
var u65 = document.getElementById('u65');

var u66 = document.getElementById('u66');
gv_vAlignTable['u66'] = 'center';
var u67 = document.getElementById('u67');

var u68 = document.getElementById('u68');
gv_vAlignTable['u68'] = 'top';
var u69 = document.getElementById('u69');

var u70 = document.getElementById('u70');
gv_vAlignTable['u70'] = 'top';
var u71 = document.getElementById('u71');

var u72 = document.getElementById('u72');
gv_vAlignTable['u72'] = 'center';
var u73 = document.getElementById('u73');

var u74 = document.getElementById('u74');
gv_vAlignTable['u74'] = 'top';
var u75 = document.getElementById('u75');

var u76 = document.getElementById('u76');
gv_vAlignTable['u76'] = 'top';
var u77 = document.getElementById('u77');

var u78 = document.getElementById('u78');
gv_vAlignTable['u78'] = 'center';
var u79 = document.getElementById('u79');

if (window.OnLoad) OnLoad();
