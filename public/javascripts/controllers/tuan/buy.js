$(function(){
	
	$("#order_amount").keyup(function(){
		var fright_amount = Number($(this).attr("fright_amount"));
		count_money(fright_amount);
	});
	
	$("#info_receiver_province_id").change(function(){
		var province_id = $(this).val();
		$.post("/tuan/get_cities",{id:province_id, model : "info"}, function(data){
			$("#city").html(data);
		})
	});
	
	
});

function count_money(fright_amount){
	var amount = Number($("#order_amount").val());
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
function validate_number(){
	var amount = $("#order_amount").val();
	if (!(/^\d*$/).test(amount)){
		alert("只可以输入数字");
	}
}
