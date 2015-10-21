function openLayer(mark){
	var id = 'test_con';
	var divid = id + mark;
	var divbox = document.getElementById(divid);
	var closeid = divid+'_close';
	var closebox = document.getElementById(closeid);
	
	var i = 1;
	var element;
	while(element = document.getElementById(id + i)){
		if (element){
			i != mark && (element.style.display = 'none');
			i++;
		}else{
			break;	
		}
	}
	
	divbox.style.display = 'block';
	closebox.onclick = function(){
		divbox.style.display = 'none';
	}
}
