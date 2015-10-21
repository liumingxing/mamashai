$(function(){
	$("#bank_form").submit(function(){
		$("#dialog_bank").dialog({
			height: 310,
			width: 400,
			modal: true,
			resizable: false
		});
	});
	
	$(".problem_button").click(function(){
		window.location.href = "/tuan/my_balance"
	});
	
});
