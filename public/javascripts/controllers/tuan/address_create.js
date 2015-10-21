$(function(){
	
	$(".mms_input_amount").change(function(){
		var amount = Number($(this).val());
		var remain_amount = $(this).attr("remain_amount")
		var city_id = $("#order_address_city_id").val();
		if(remain_amount!='' && amount > Number(remain_amount)){
			amount = remain_amount;
			$(this).val(remain_amount);
		}
		
		var tuan_id = $(this).attr("tuan_id");
		var price = Number($(this).attr("price"));
		$("#item_money_"+tuan_id).text(Math.round(price*amount*100)/100);
		$.post("/tuan/update_cart/"+tuan_id,{amount:amount},function(data){
			$("#total_money").text("￥"+data);
		});
	});
	
	$(".mms_input_amount").keyup(function(){
		var amount = $(this).val();
		if (!(/^\d+(\.\d+)?$/).test(amount)||amount=='0'){
			$(this).val(1);
		}
	});
	
	$("#order_address_province_id").change(function(){
		var province_id = $(this).val();
		$.post("/tuan/get_cities",{id:province_id, model : "order_address"}, function(data){
			$("#city").html(data);
		});
	});
	
	
});

function get_fright(city_id){
	if(city_id==''){
		$("#fright_money").html("请先选择城市");
	}else{
		$.post("/tuan/get_fright_money",{id:city_id},function(data){
			if(/\d+/.test(data)){
				var total_money = Number($("#total_money_hidden").val());
	        	$("#fright_money").html("￥"+data);
				$("#total_money").html("<span class='red'>￥"+(Number(data)+total_money)+"</span>");
	        }else{
	            $("#fright_money").html(data);
	        }
			
		});
	}
}
