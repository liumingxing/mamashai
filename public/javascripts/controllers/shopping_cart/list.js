(function($){
    $(function(){
        var removeItemCallBack=function(me){
            return function(data){
                me.parents('tr').remove();
                $('#mms_tool_tip').empty().append(data);
                var money= $('#mms_tool_tip .money').text();
                $('#mms_label_money').empty().append(money);
                $('#mms_label_money').trigger("changeMoney");
            }
        };
        
        var removeItem = function(){
            var me = $(this);
            var item_id=$(this).attr('item_id');
            var product_id=$(this).attr('product_id');
            $.post('/shopping_cart/destroy/'+item_id+'_'+product_id,{
                _method: 'delete'
            },removeItemCallBack(me));
        };

        var changeAmountCallBack=function(data){
            $('#mms_tool_tip').empty().append(data);
            var money= $('#mms_tool_tip .money').text();
            $('#mms_label_money').empty().append(money);
            $('#mms_label_money').trigger("changeMoney");
        };

        var changeAmount = function(){
            var me = $(this);
            var item_id=$(this).attr('item_id');
            var product_id=$(this).attr('product_id');
            
            $.post('/shopping_cart/change_item_amount/'+item_id+'_'+product_id,{
                _method: 'put',
                amount: me.val()
            },changeAmountCallBack);
            
        }
        
        $('.mms_alink_del').click(removeItem);
        $('.mms_input_amount').change(changeAmount);
        $('#mms_label_money').tooltip({
            events:{
                def: "changeMoney, ",
                position: 'top center',
                delay: 20
            }
        });
        $('body').click(function(){
            $('#mms_label_money').tooltip().hide();
        });
    });
})(jQuery)


