/**
 * @author wang
 */
function hexFromRGB (r, g, b) {
	var hex = [
	           r.toString(16),
	           g.toString(16),
	           b.toString(16)
	           ];
	$.each(hex, function (nr, val) {
		if (val.length == 1) {
			hex[nr] = '0' + val;
		}
	});
	return hex.join('').toUpperCase();
}

function refreshSwatch() {
	var red = $("#red").slider("value")
	,green = $("#green").slider("value")
	,blue = $("#blue").slider("value")
	,hex = hexFromRGB(red, green, blue);
	$("#image_show").css("background-color", "#" + hex);
}

jQuery(function($) {
	$("#info_image").blur(function(){
	  	$("#image_show").css("background-image","url("+$(this).val()+")");
	});
	
	$("#red, #green, #blue").slider({
		orientation: 'horizontal',
		range: "min",
		max: 255,
		value: 127,
		slide: refreshSwatch,
		change: refreshSwatch
	});
	$("#red").slider("value", 255);
	$("#green").slider("value", 140);
	$("#blue").slider("value", 60);

	
	var $map=$("#gameMap"),
		$next=$("#next"),
		$result=$("#result"),
		$replay=$("#replay"),
		$gameTitle=$("#gameTitle");
	var successHandle = function(levelInfo){
		$result.hide();
		$next.hide();
		$replay.hide();
		$map.fadeOut("normal",function(){
			if(levelInfo.nextIndex){
				$next.show().click(function(){
					$result.fadeOut("normal",function(){
						replay(levelInfos[levelInfo.nextIndex]);
					});
				});
			}else{
				$gameTitle.show();
			}
			$result.fadeIn("normal");
		});
	};
	var levelInfos=[
		{name:"第一关 练手",iLines:6,iColumns:4,nextIndex:1,successHandle :successHandle},
		{name:"第二关 重力",iLines:8,iColumns:6,nextIndex:2,successHandle :successHandle,plugins:[sort_down_plugin]},
		{name:"第三关 飓风",iLines:8,iColumns:6,nextIndex:3,successHandle :successHandle,plugins:[sort_down_plugin,sort_left_plugin]},
		{name:"第四关 眩晕",iLines:10,iColumns:8,successHandle :successHandle,plugins:[sort_right_plugin,sort_down_plugin,sort_left_plugin,sort_up_plugin]}
	];
	
	$result.hide();
	$replay.hide();
	var currentLevel=null,levelIndex;
	var replay=function(levelInfo){
		$map.fadeOut("normal",function(){
			$map.empty().fadeIn("normal").llk(levelInfo);
		});
	}
	for(levelIndex in levelInfos){
		var levelInfo = levelInfos[levelIndex];
		var $li=$("<li/>"),$a=$("<a href='#'>"+levelInfo.name+"</a>");
		$a.data("info",levelInfo);
		$a.click(function(){
			var levelInfo = $(this).data("info");
			currentLevel=levelInfo;
			replay(levelInfo);
			$replay.click(function(){
				replay(currentLevel);
			});
			$replay.show();
			$gameTitle.hide();
		});
		$li.html($a);
		$gameTitle.append($li);
	}
});