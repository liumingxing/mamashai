// JavaScript Document
$(function(){
	$.fn.llk = function(options) {
		var settings = {
			iLines : 12,//当前游戏共有多少行
			iColumns : 12,//当前游戏共有多少列
			iTypes: 8,//当前游戏设置多少类型的图标,可以不设置
			successHandle : function(){
				setTimeout(
					function(){
						alert("恭喜你，成功了！");
					},
					((defaultImageHandle.iSteps+3)*defaultImageHandle.iStepInterval)+defaultImageHandle.iDelayInterval
				);
			},
			imageHandle:null,
			debugHandle:null,
			plugins:[]
		};
		
		/**
		//图片url地址生成器。以下参数需要补充，方法需要实现
		var ImageHandle = {
			iImageWidth:52,//图片宽
			iImageHeight:37,//图片高
			iMaxTypes:7,//最多支持的图标数
			initIcon:function($object,iIconIndex){},//初始化图标
			setIconOn:function($object,iIconIndex,isClear){},//将图标拾起
			setIconOff:function($object,iIconIndex){},//放下图标
			clear:function($object,isDelay){}//将图标清空
		}
		*/
		
		//实际图片url地址生成器,方式：每次更新背景图的偏移量（这样就没有）,且附带动画效果
		var defaultImageHandle = {
			iImageWidth:52,
			iImageHeight:37,
			iMaxTypes:7,
			iSteps:4,//动画步骤数
			iStepInterval:50,//每步间间隔时间
			iDelayInterval:0,//连接时间隔时间
			initIcon:function($object,iIconIndex){
				$object.css("background-image","url(skin/default/google_icons.jpg)");
				$object.css("background-repeat","no-repeat");
				if(iIconIndex){
					$object.css("background-position","-"+(this.iImageWidth*this.iSteps)+"px -"+((iIconIndex-1)*this.iImageHeight)+"px");
				}else{
					$object.css("background-position",
						"-"+(this.iImageWidth*(this.iSteps+1))+"px -"+(defaultImageHandle.iMaxTypes*this.iImageHeight)+"px");
				}
			},
			setIconOn:function($object,iIconIndex,isClear){
				var i=0;
				var delay= function(){
					$object.css("background-position",
						"-"+(defaultImageHandle.iImageWidth*(defaultImageHandle.iSteps-i))
							+"px -"+((iIconIndex-1)*defaultImageHandle.iImageHeight)+"px"
					)
					if(i<defaultImageHandle.iSteps){
						i++;
						setTimeout(delay,defaultImageHandle.iStepInterval);
					}else if(isClear&&i==defaultImageHandle.iSteps){
						defaultImageHandle.clear($object,false);
					}
				};
				setTimeout(delay,this.iStepInterval);
			},
			setIconOff:function($object,iIconIndex){
				var i=0;
				var delay= function(){
					$object.css("background-position",
						"-"+(defaultImageHandle.iImageWidth*i)+"px -"+((iIconIndex-1)*defaultImageHandle.iImageHeight)+"px"
					);
					if(i<defaultImageHandle.iSteps){
						i++;
						setTimeout(delay,defaultImageHandle.iStepInterval);
					}
				};
				setTimeout(delay,this.iStepInterval);
			},
			clear:function($object,isDelay){
				setTimeout(
					function(){
						$object.css("background-position",
							"-"+(defaultImageHandle.iImageWidth*(defaultImageHandle.iSteps+1))
								+"px -"+(defaultImageHandle.iMaxTypes*defaultImageHandle.iImageHeight)+"px");
					},
					isDelay?(((defaultImageHandle.iSteps+2)*defaultImageHandle.iStepInterval)+defaultImageHandle.iDelayInterval)
						:(defaultImageHandle.iStepInterval+defaultImageHandle.iDelayInterval)
				);
			}
		};
		
		
		//初始化参数
		if(options){
			jQuery.extend(settings,options);
		}
		if(!settings.imageHandle){
			settings.imageHandle=defaultImageHandle;
		}
		if(!settings.iTypes||settings.iTypes>settings.imageHandle.iMaxTypes){
			settings.iTypes=settings.imageHandle.iMaxTypes
		}
		$(this).each(function(){
			//局部变量
			var $gameMap=$("<div/>"),//当前游戏地图的jquery对象
				oIconMap={},//当前游戏各个行、列的对应关系
				iColumnIndex,//当前列序号
				iLineIndex,//当前行序号
				$this=$(this),
				offset=$this.offset();
			//当前选择图标情况的对象
			var Grap={
				isGrap:false,//是否有被选择的图标
				iLineIndex:0,//被选择的图标所在行序号，从1开始，0表示未被选择
				iColumnIndex:0,//被选择的图标所在列序号，从1开始，0表示未被选择
				iIconIndex:0,//图标的索引号
				$object:null,//被选择的图标的jquery对象
				//选择某对象
				grap:function(iLineIndex,iColumnIndex,iIconIndex,$object){
					this.iLineIndex=iLineIndex;
					this.iColumnIndex=iColumnIndex;
					this.iIconIndex=iIconIndex;
					this.$object=$object;
					this.isGrap=true;
				},
				//取消选择
				cancelGrap:function(){
					this.iLineIndex=0;
					this.iColumnIndex=0;
					this.iIconIndex=false;
					this.isGrap=false;
					this.$object=null;
				}
				
			};
		
			//列被点击时的响应句柄
			var fnColumnClick = function(){
				var $this=$(this),
					iLineIndex = $this.data("iLineIndex"),
					iColumnIndex=$this.data("iColumnIndex");
					iIconIndex=oIconMap[iLineIndex][iColumnIndex];
				if(iIconIndex=="0"){
					return false;
				}else if(!Grap.isGrap){
					//未选中任何东西，则选中
					Grap.grap(iLineIndex,iColumnIndex,iIconIndex,$this);
					settings.imageHandle.setIconOn($this,iIconIndex);
				}else if(iLineIndex==Grap.iLineIndex && Grap.iColumnIndex==iColumnIndex){
					//已经选中了，而且当前选择上的是已经选择的，则取消选择
					Grap.cancelGrap();
					settings.imageHandle.setIconOff($this,iIconIndex);
				}else if(Grap.iIconIndex==iIconIndex){
					//已经选中了，而且当前选择上的是未选择的，且颜色一样，则需要判断一下，两者是否可以合并，
					var path = fnGetPath(
						{iLine:Grap.iLineIndex,iColumn:Grap.iColumnIndex},
						{iLine:iLineIndex,iColumn:iColumnIndex}
					);
					//如果可以合并，两个都合并消灭
					if(path){
						oIconMap[iLineIndex][iColumnIndex]=0;
						oIconMap[Grap.iLineIndex][Grap.iColumnIndex]=0;
						settings.imageHandle.setIconOn($this,iIconIndex,true);
						settings.imageHandle.clear(Grap.$object,true);
						//再判断一下是否全部都合并了，如果全部合并了，则胜利了
						if(fnValidSuccess()){
							settings.successHandle(settings);
						}else {
							for(var iPlugin =0;iPlugin<settings.plugins.length;iPlugin++){
								var plugin = settings.plugins[iPlugin];
								if(plugin&&$.isFunction(plugin.onUnion)){
									var result = plugin.onUnion(oIconMap,settings.iLines,settings.iColumns);
									$gameMap.find("div.column").each(function(){
										var $this = $(this),
											iLineIndex=$this.data("iLineIndex"),
											iColumnIndex =$this.data("iColumnIndex"),
											iIconIndex=oIconMap[iLineIndex][iColumnIndex],
											moveInfo=result[iLineIndex][iColumnIndex],
											timeout=defaultImageHandle.iDelayInterval;
										timeout += (defaultImageHandle.iSteps+2)*defaultImageHandle.iStepInterval;
										timeout += 300*iPlugin;
										if(moveInfo){
											$this.data("iLineIndex",moveInfo.iToLineIndex);
											$this.data("iColumnIndex",moveInfo.iToColumnIndex);
											setTimeout(
												function(){
													if(moveInfo.isAnimate){
														var moveObj={};
														moveObj.left=(moveInfo.iToColumnIndex*settings.imageHandle.iImageWidth+offset.left)+"px";
														moveObj.top=(moveInfo.iToLineIndex*settings.imageHandle.iImageHeight+offset.top)+"px";
														$this.animate(moveObj,300);
													}else{
														$this.css("left",(moveInfo.iToColumnIndex*settings.imageHandle.iImageWidth+offset.left)+"px");
														$this.css("top",(moveInfo.iToLineIndex*settings.imageHandle.iImageHeight+offset.top)+"px");
													}
												},
												timeout
											)
										}
									});
								}
							}
							if($.isFunction(settings.debugHandle)){
								settings.debugHandle(oIconMap,settings.iLines,settings.iColumns);
							}
						}
					}else{
						settings.imageHandle.setIconOff(Grap.$object,Grap.iIconIndex);
					}
					//不管是否合并,都需要取消选择
					Grap.cancelGrap();
				}else{
					//选中的和新选的颜色不合，则将原选中的取消选中，将新选中的设置为选中
					settings.imageHandle.setIconOff(Grap.$object,Grap.iIconIndex);
					Grap.grap(iLineIndex,iColumnIndex,iIconIndex,$this);
					settings.imageHandle.setIconOn($this,iIconIndex);
				}
			};
			var fnValidSuccess = function(){
				for(var iLineIndex=1;iLineIndex<=settings.iLines;iLineIndex++){
					for(var iColumnIndex=1;iColumnIndex<=settings.iColumns;iColumnIndex++){
						if(oIconMap[iLineIndex][iColumnIndex]){
							return false;
						}
					}
				}
				return true;
			}
			//通过起、终点位置取可行性路径的算法
			var fnGetPath = function(oFromPos,oToPos){
				linescan: for(var iLine=0; iLine<=settings.iLines+1; iLine++) {// 垂直扫描  
					var r, c;  
					for(r = Math.min(iLine, oFromPos.iLine); r <= Math.max(iLine, oFromPos.iLine); r++) {  
						if(r == oFromPos.iLine) {  
							continue;  
						}  
						if(oIconMap[r][oFromPos.iColumn]) {           
							continue linescan;  
						}  
					}
					for(c = Math.min(oFromPos.iColumn, oToPos.iColumn); c <= Math.max(oFromPos.iColumn, oToPos.iColumn); c++) {  
						if(c == oFromPos.iColumn || c == oToPos.iColumn) {  
							continue;  
						}  
						if(oIconMap[iLine][c]) {  
							continue linescan;  
						}  
					}  
					for(r = Math.min(iLine, oToPos.iLine); r <= Math.max(iLine, oToPos.iLine); r++) {  
						if(r == oToPos.iLine) {  
							continue;  
						}  
						if(oIconMap[r][oToPos.iColumn]) {  
							continue linescan;  
						}  
					}  
					if(r == Math.max(iLine, oToPos.iLine) + 1) {  
						return [ 
							oFromPos,
							{iLine:iLine, iColumn:oFromPos.iColumn},  
							{iLine:iLine, iColumn:oToPos.iColumn},
							oToPos
						];  
					}  
				}
				columnscan: for(var iColumn=0; iColumn<=settings.iColumns+1; iColumn++) {// 水平扫描  
					var r, c;  
					for(c = Math.min(iColumn,oFromPos.iColumn); c<=Math.max(iColumn,oFromPos.iColumn); c++) {  
						if(c == oFromPos.iColumn) {  
							continue;  
						}  
						if(oIconMap[oFromPos.iLine][c]) {  
							continue columnscan;  
						}  
					}  
					for (r = Math.min(oFromPos.iLine,oToPos.iLine); r<=Math.max(oFromPos.iLine,oToPos.iLine); r++) {  
						if (r == oFromPos.iLine || r == oToPos.iLine) {  
							continue;  
						}  
						if (oIconMap[r][iColumn]) {  
							continue columnscan;  
						}  
					}  
					for (c = Math.min(iColumn, oToPos.iColumn); c <= Math.max(iColumn, oToPos.iColumn); c++) {  
						if (c == oToPos.iColumn) {  
							continue;  
						}  
						if (oIconMap[oToPos.iLine][c]) {  
							continue columnscan;  
						}  
					}  
					if (c == Math.max(iColumn, oToPos.iColumn) + 1) { 
						return [ 
							oFromPos,
							{iLine:oFromPos.iLine, iColumn:iColumn},  
							{iLine:oToPos.iLine, iColumn:iColumn},
							oToPos
						]; 
					}  
				}  
			}
			//图标索引的生成器，确保每个图标生成的个数都是偶数
			var fnIconIndexCreate ={
				arrIconIndex:[],
				createMap:function(){
					//先生成偶数个图片索引号
					var iCount=settings.iLines*settings.iColumns/2;
					for(var i=0;i<iCount;i++){
						var iIconIndex=Math.round(Math.random()*(settings.iTypes-1))+1;
						this.arrIconIndex.push(iIconIndex);
						this.arrIconIndex.push(iIconIndex);
					}
					//将索引打乱
					for(var i=0;i<this.arrIconIndex.length;i++) {
						var randomIndex1=Math.round(Math.random()*(this.arrIconIndex.length-1)),
							randomIndex2=Math.round(Math.random()*(this.arrIconIndex.length-1)),
							iTemp;
						if(randomIndex1!=randomIndex2){
							iTemp=this.arrIconIndex[randomIndex1];
							this.arrIconIndex[randomIndex1]=this.arrIconIndex[randomIndex2];
							this.arrIconIndex[randomIndex2]=iTemp;
						}else if(randomIndex1){
							iTemp=this.arrIconIndex[randomIndex1];
							this.arrIconIndex[randomIndex1]=this.arrIconIndex[0];
							this.arrIconIndex[0]=iTemp;
						}else{
							iTemp=this.arrIconIndex[this.arrIconIndex.length-1];
							this.arrIconIndex[this.arrIconIndex.length-1]=this.arrIconIndex[0];
							this.arrIconIndex[0]=iTemp;
						}
					}
				},
				popItem:function(){
					var arr=this.arrIconIndex.slice(0),
						obj = this.arrIconIndex.pop();
					if(!obj){
						alert(arr.length);
					}
					return obj;
				}
			}
			//初始化
			fnIconIndexCreate.createMap();
			//生成各行各列的图标
			for(var iLineIndex=0;iLineIndex<=settings.iLines+1;iLineIndex++){
				oIconMap[iLineIndex]={};
				for(var iColumnIndex=0;iColumnIndex<=settings.iColumns+1;iColumnIndex++){
					//var iIconIndex=Math.round(Math.random()*2)+1;//图片索引的生成方式需要调整
					var $icon = $("<div/>"),iIconIndex = 0;
					$icon.addClass("column").css("height",settings.imageHandle.iImageHeight).css("width",settings.imageHandle.iImageWidth);
					$icon.css("left",(offset.left+iColumnIndex*settings.imageHandle.iImageWidth)+"px");
					$icon.css("top",(offset.top+iLineIndex*settings.imageHandle.iImageHeight)+"px");
					$icon.data("iLineIndex",iLineIndex).data("iColumnIndex",iColumnIndex);
					if(iLineIndex!=0&&iLineIndex!=settings.iLines+1&&iColumnIndex!=0&&iColumnIndex!=settings.iColumns+1){
						iIconIndex = fnIconIndexCreate.popItem();
					}
					settings.imageHandle.initIcon($icon,iIconIndex);
					$icon.click(fnColumnClick);
					$gameMap.append($icon);
					oIconMap[iLineIndex][iColumnIndex]=iIconIndex;
				}
			}
			$this.append($gameMap).css("height",settings.imageHandle.iImageHeight*(settings.iLines+2)+"px")
				.css("width",settings.imageHandle.iImageWidth *(settings.iColumns+2)+"px");
		});
	};
});