$(function(){
	$(".mms_input_amount").change(function(){
		var amount = Number($(this).val());
		var remain_amount = $(this).attr("remain_amount")
		if(remain_amount!='' && amount > Number(remain_amount)){
			amount = remain_amount;
			$(this).val(remain_amount);
		}
		
		var tuan_id = $(this).attr("tuan_id");
		var price = Number($(this).attr("price"));
		$("#item_money_"+tuan_id).text(Math.round(price*amount*100)/100);
		$.post("/tuan/update_cart_no_fright/"+tuan_id,{amount:amount},function(data){
			$("#total_money").text("￥"+data);
		});
	});
	
	$("#coupon").change(function(){
		$.post("/tuan/update_cart_coupon/", {use:$("#coupon").attr("checked"), c_id:$("#coupon").val()},function(data){
			$("#total_money").text("￥"+data);
		});
	})
	
	$(".mms_input_amount").keyup(function(){
		var amount = $(this).val();
		if (!(/^\d+(\.\d+)?$/).test(amount)||amount=='0'){
			$(this).val(1);
		}
	});
	
});
