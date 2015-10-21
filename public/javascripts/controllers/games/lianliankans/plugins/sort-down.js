var sort_down_plugin = {
	name:"down",
	onUnion:function(oIconMap,iLines,iColumns){
		var //moveList=[],
			fromMap={},//toMap={},
			iLineIndex,
			iColumnIndex,
			iIconIndex,
			iLineEmptyIndex;
			
		for(iLineIndex=0;iLineIndex<=iLines+1;iLineIndex++){
			fromMap[iLineIndex]={};
		}

		for(iColumnIndex=1;iColumnIndex<=iColumns;iColumnIndex++){
			iLineEmptyIndex=iLines;
			for(iLineIndex=iLines;iLineIndex>=1;iLineIndex--){
				iIconIndex=oIconMap[iLineIndex][iColumnIndex];
				if(iIconIndex){
					if(iLineIndex-iLineEmptyIndex){
						var objFromInfo=fromMap[iLineIndex][iColumnIndex],
							objToInfo = fromMap[iLineEmptyIndex][iColumnIndex];//移动的目的地
							
						//moveList.push(objInfo);
						if(objToInfo){
							//指向的目标地存在已有的移动，就需要追溯源头
							fromMap[iLineIndex][iColumnIndex]={
								iFromLineIndex:iLineIndex,
								iFromColumnIndex:iColumnIndex,
								
								iToLineIndex:iLineEmptyIndex,
								iToColumnIndex:iColumnIndex,
								
								iSourceLineIndex:objToInfo.iSourceLineIndex,
								iSourceColumnIndex:objToInfo.iSourceColumnIndex,
								
								iIconIndex:iIconIndex,
								strForward:"top",
								isAnimate:true
							};
							//将来自源头的移动目标处理为新的地址
							var objSourceInfo=fromMap[objToInfo.iSourceLineIndex][objToInfo.iSourceColumnIndex];
							objSourceInfo.iToLineIndex=iLineIndex;
							objSourceInfo.iToColumnIndex=iColumnIndex;
						}else {
							//指向的目标地不存在已有的移动，就不需要追溯源头
							fromMap[iLineIndex][iColumnIndex]={
								iFromLineIndex:iLineIndex,
								iFromColumnIndex:iColumnIndex,
								
								iToLineIndex:iLineEmptyIndex,
								iToColumnIndex:iColumnIndex,
								
								iSourceLineIndex:iLineEmptyIndex,
								iSourceColumnIndex:iColumnIndex,
								
								iIconIndex:iIconIndex,
								strForward:"top",
								isAnimate:true
							};
							fromMap[iLineEmptyIndex][iColumnIndex]={//to的源头
								iFromLineIndex:iLineEmptyIndex,
								iFromColumnIndex: iColumnIndex,
								
								iToLineIndex:iLineIndex,
								iToColumnIndex:iColumnIndex,
								
								iSourceLineIndex:iLineEmptyIndex,
								iSourceColumnIndex:iColumnIndex,
								
								iIconIndex:iIconIndex,
								strForward:"top",
								isAnimate:true
							};
						}
						//toMap[iLineIndex][iColumnEmptyIndex]=moveList.length;
						oIconMap[iLineEmptyIndex][iColumnIndex]=iIconIndex;
						oIconMap[iLineIndex][iColumnIndex]=0;
					}
					iLineEmptyIndex--;
				}
			}
		}
		return fromMap;
	}
};