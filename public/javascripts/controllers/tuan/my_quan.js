function show_prompt_quans(quan_id){
    var email = prompt("请输入您的邮箱:","");
    if (email != null && email != "") {
        location.href = "/tuan/quan_email/" + quan_id+"?email="+email;
    }
}