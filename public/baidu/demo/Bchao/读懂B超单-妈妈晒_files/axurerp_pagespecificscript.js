
var PageName = '读懂B超单-妈妈晒';
var PageId = '2ec1173d327d46d5843672146a848b4f'
var PageUrl = '读懂B超单-妈妈晒.html'
document.title = '读懂B超单-妈妈晒';
var PageNotes = 
{
"pageName":"读懂B超单-妈妈晒",
"showNotesNames":"False"}
var $shuangdingjing = '';

var $fuwei = '';

var $guguchang = '';

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
    return '#shuangdingjing=' + encodeURIComponent($shuangdingjing) + '&fuwei=' + encodeURIComponent($fuwei) + '&guguchang=' + encodeURIComponent($guguchang) + '&CSUM=1';
}

function PopulateVariables(value) {
    var d = new Date();
  value = value.replace(/\[\[shuangdingjing\]\]/g, $shuangdingjing);
  value = value.replace(/\[\[fuwei\]\]/g, $fuwei);
  value = value.replace(/\[\[guguchang\]\]/g, $guguchang);
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
gv_vAlignTable['u80'] = 'center';
var u81 = document.getElementById('u81');
gv_vAlignTable['u81'] = 'top';
var u82 = document.getElementById('u82');

var u83 = document.getElementById('u83');
gv_vAlignTable['u83'] = 'center';
var u84 = document.getElementById('u84');

var u85 = document.getElementById('u85');
gv_vAlignTable['u85'] = 'center';
var u10 = document.getElementById('u10');

u10.style.cursor = 'pointer';
if (bIE) u10.attachEvent("onclick", Clicku10);
else u10.addEventListener("click", Clicku10, true);
function Clicku10(e)
{
windowEvent = e;


if (true) {

}

}

if (bIE) u10.attachEvent("onmouseover", MouseOveru10);
else u10.addEventListener("mouseover", MouseOveru10, true);
function MouseOveru10(e)
{
windowEvent = e;

if (!IsTrueMouseOver('u10',e)) return;
if (true) {

	MoveWidgetTo('u7', 71,53,'swing',300);

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

	SetPanelState('u12', 'pd0u12','none','',500,'fade','',500);

}

}

if (bIE) u11.attachEvent("onmouseover", MouseOveru11);
else u11.addEventListener("mouseover", MouseOveru11, true);
function MouseOveru11(e)
{
windowEvent = e;

if (!IsTrueMouseOver('u11',e)) return;
if (true) {

	MoveWidgetTo('u7', 201,53,'swing',300);

}

}
gv_vAlignTable['u11'] = 'top';
var u12 = document.getElementById('u12');

var u13 = document.getElementById('u13');
gv_vAlignTable['u13'] = 'top';
var u14 = document.getElementById('u14');
gv_vAlignTable['u14'] = 'top';
var u15 = document.getElementById('u15');

if (bIE) u15.attachEvent("onblur", LostFocusu15);
else u15.addEventListener("blur", LostFocusu15, true);
function LostFocusu15(e)
{
windowEvent = e;


if (((GetSelectedOption('u15')) != ('年')) && (((GetSelectedOption('u16')) != ('月')) && ((GetSelectedOption('u17')) != ('日')))) {

	SetPanelVisibility('u23','hidden','fade',500);

}

}

var u16 = document.getElementById('u16');

if (bIE) u16.attachEvent("onblur", LostFocusu16);
else u16.addEventListener("blur", LostFocusu16, true);
function LostFocusu16(e)
{
windowEvent = e;


if (((GetSelectedOption('u15')) != ('年')) && (((GetSelectedOption('u16')) != ('月')) && ((GetSelectedOption('u17')) != ('日')))) {

	SetPanelVisibility('u23','hidden','fade',500);

}

}

var u17 = document.getElementById('u17');

if (bIE) u17.attachEvent("onblur", LostFocusu17);
else u17.addEventListener("blur", LostFocusu17, true);
function LostFocusu17(e)
{
windowEvent = e;


if (((GetSelectedOption('u15')) != ('年')) && (((GetSelectedOption('u16')) != ('月')) && ((GetSelectedOption('u17')) != ('日')))) {

	SetPanelVisibility('u23','hidden','fade',500);

}

}

var u18 = document.getElementById('u18');

u18.style.cursor = 'pointer';
if (bIE) u18.attachEvent("onclick", Clicku18);
else u18.addEventListener("click", Clicku18, true);
function Clicku18(e)
{
windowEvent = e;


if (((GetSelectedOption('u15')) == ('年')) || (((GetSelectedOption('u16')) == ('月')) || (((GetSelectedOption('u17')) == ('日')) || (((GetWidgetFormText('u28')) == ('')) || (((GetWidgetFormText('u29')) == ('')) || ((GetWidgetFormText('u30')) == (''))))))) {

	SetPanelVisibility('u23','','fade',500);

	BringToFront("u23");

}
else
if (((GetSelectedOption('u15')) != ('年')) && (((GetSelectedOption('u16')) != ('月')) && (((GetSelectedOption('u17')) != ('日')) && (((GetWidgetFormText('u28')) != ('')) && (((GetWidgetFormText('u29')) != ('')) && ((GetWidgetFormText('u30')) != (''))))))) {

	SetPanelState('u35', 'pd1u35','none','',500,'fade','',500);

	MoveWidgetBy('u78',0,120,'none',500);

SetGlobalVariableValue('$shuangdingjing', GetWidgetFormText('u28'));

SetWidgetRichText('u50', '<p style="text-align:center;"><span style="font-family:Arial;font-size:13px;font-weight:normal;font-style:normal;text-decoration:none;color:#333333;">' + (GetGlobalVariableValue('$shuangdingjing')) + '</span></p>');

SetGlobalVariableValue('$fuwei', GetWidgetFormText('u29'));

SetWidgetRichText('u56', '<p style="text-align:center;"><span style="font-family:Arial;font-size:13px;font-weight:normal;font-style:normal;text-decoration:none;color:#333333;">' + (GetGlobalVariableValue('$fuwei')) + '</span></p>');

SetGlobalVariableValue('$guguchang', GetWidgetFormText('u30'));

SetWidgetRichText('u62', '<p style="text-align:center;"><span style="font-family:Arial;font-size:13px;font-weight:normal;font-style:normal;text-decoration:none;color:#333333;">' + (GetGlobalVariableValue('$guguchang')) + '</span></p>');

SetWidgetRichText('u68', '<p style="text-align:center;"><span style="font-family:Arial;font-size:13px;font-weight:normal;font-style:normal;text-decoration:none;color:#333333;">500</span></p>');

}

}

var u19 = document.getElementById('u19');
gv_vAlignTable['u19'] = 'center';
var u20 = document.getElementById('u20');

u20.style.cursor = 'pointer';
if (bIE) u20.attachEvent("onclick", Clicku20);
else u20.addEventListener("click", Clicku20, true);
function Clicku20(e)
{
windowEvent = e;


if (true) {

	NewTab("http://www.mamashai.com/yunzhou/index" + "", "");

}

}

var u21 = document.getElementById('u21');
gv_vAlignTable['u21'] = 'center';
var u22 = document.getElementById('u22');

var u23 = document.getElementById('u23');

var u24 = document.getElementById('u24');
gv_vAlignTable['u24'] = 'top';
var u25 = document.getElementById('u25');
gv_vAlignTable['u25'] = 'top';
var u26 = document.getElementById('u26');
gv_vAlignTable['u26'] = 'top';
var u27 = document.getElementById('u27');
gv_vAlignTable['u27'] = 'top';
var u28 = document.getElementById('u28');

var u29 = document.getElementById('u29');

var u30 = document.getElementById('u30');

var u31 = document.getElementById('u31');
gv_vAlignTable['u31'] = 'top';
var u32 = document.getElementById('u32');
gv_vAlignTable['u32'] = 'top';
var u33 = document.getElementById('u33');
gv_vAlignTable['u33'] = 'top';
var u34 = document.getElementById('u34');
gv_vAlignTable['u34'] = 'top';
var u35 = document.getElementById('u35');

var u36 = document.getElementById('u36');

var u37 = document.getElementById('u37');
gv_vAlignTable['u37'] = 'center';
var u38 = document.getElementById('u38');
gv_vAlignTable['u38'] = 'top';
var u39 = document.getElementById('u39');

var u40 = document.getElementById('u40');

var u41 = document.getElementById('u41');

var u42 = document.getElementById('u42');
gv_vAlignTable['u42'] = 'top';
var u43 = document.getElementById('u43');

var u44 = document.getElementById('u44');
gv_vAlignTable['u44'] = 'center';
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
gv_vAlignTable['u50'] = 'center';
var u51 = document.getElementById('u51');

var u52 = document.getElementById('u52');
gv_vAlignTable['u52'] = 'top';
var u53 = document.getElementById('u53');

var u54 = document.getElementById('u54');
gv_vAlignTable['u54'] = 'top';
var u55 = document.getElementById('u55');

var u56 = document.getElementById('u56');
gv_vAlignTable['u56'] = 'center';
var u57 = document.getElementById('u57');

var u58 = document.getElementById('u58');
gv_vAlignTable['u58'] = 'top';
var u59 = document.getElementById('u59');

var u60 = document.getElementById('u60');
gv_vAlignTable['u60'] = 'top';
var u61 = document.getElementById('u61');

var u62 = document.getElementById('u62');
gv_vAlignTable['u62'] = 'center';
var u63 = document.getElementById('u63');

var u64 = document.getElementById('u64');
gv_vAlignTable['u64'] = 'top';
var u65 = document.getElementById('u65');

var u66 = document.getElementById('u66');
gv_vAlignTable['u66'] = 'top';
var u67 = document.getElementById('u67');

var u68 = document.getElementById('u68');
gv_vAlignTable['u68'] = 'center';
var u69 = document.getElementById('u69');

var u70 = document.getElementById('u70');
gv_vAlignTable['u70'] = 'top';
var u71 = document.getElementById('u71');
gv_vAlignTable['u71'] = 'top';
var u72 = document.getElementById('u72');
gv_vAlignTable['u72'] = 'top';
var u73 = document.getElementById('u73');

var u74 = document.getElementById('u74');
gv_vAlignTable['u74'] = 'center';
var u75 = document.getElementById('u75');
gv_vAlignTable['u75'] = 'top';
var u76 = document.getElementById('u76');
gv_vAlignTable['u76'] = 'top';
var u77 = document.getElementById('u77');

var u78 = document.getElementById('u78');

var u79 = document.getElementById('u79');

if (window.OnLoad) OnLoad();
