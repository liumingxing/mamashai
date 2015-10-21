$(function(){
	
	$("#amount").keyup(function(){
		var fright_amount = Number($(this).attr("fright_amount"));
		count_money(fright_amount);
	});
	
	$("#order_address_province_id").change(function(){
		var province_id = $(this).val();
		$.post("/tuan/get_cities",{id:province_id, model : "order_address"}, function(data){
			$("#city").html(data);
		})
	});
	
});

function count_money(fright_amount){
	var amount = Number($("#amount").val());
	var per_price = Number($('#per_price').val());
	var fright_money = Number($('#fright').val());
	var sum = amount * per_price
	$("#all_item_money").text("￥"+Math.floor(sum*100)/100);
	if (amount >= fright_amount){
		$("#fright_money").text("免运费");
		$("#all_money").text("￥"+Math.floor((sum)*100)/100);
	}else{
		$("#fright_money").text("￥"+fright_money);
		$("#all_money").text("￥"+Math.floor((sum+fright_money)*100)/100);
	}
}


function get_fright(city_id){
	if(city_id==''){
		$("#fright_money").html("请先选择城市");
	}else{
		$("#fright_money").load("/tuan/get_fright_money",{id:city_id});
	}
}