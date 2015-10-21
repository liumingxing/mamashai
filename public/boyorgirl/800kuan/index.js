// JavaScript Document
$(function(){
	//清除下拉选项
	var clearPops = function() {
		$('.pop_select').remove();
	};

	var makeSelect = function ($baseElement, begin, length, dir) {
		clearPops();
		var $pop_select = $('<div class="pop_select"></div>');
		while( length > 0 ) {
			var i = begin;
			var $btn = $('<a href="#">'+i+'</a>').click(function(){
				$baseElement.val( $(this).text() );
				clearPops();
				return false;
			});
			$pop_select.append( $btn );

			if( dir == 'decrease' ) {
				begin--;
			} else {
				begin++;
			}
			length--;
		}
		return $pop_select;
	};



	$('.t_year').click(function(){
		var o = $(this);
		var $pop = makeSelect( o, 2011, 3, 'decrease' );
		var offset = o.offset();
		$pop.hide().appendTo('body').css({	
				left: offset.left,
				top: offset.top + o.height(),
				width: o.width() + parseInt( o.css('padding-left') ),
				height: 60
			}).fadeIn('fast');
	});
	$('.t_yeara').click(function(){
		var o = $(this);
		var $pop = makeSelect( o, 1992, 27, 'decrease' );
		var offset = o.offset();
		$pop.hide().appendTo('body').css({	
				left: offset.left,
				top: offset.top + o.height(),
				width: o.width() + parseInt( o.css('padding-left') ),
				height: 200
			}).fadeIn('fast');
	});

	
	$('.t_month').click(function(){
		var o = $(this);
		var $pop = makeSelect( o, 1, 12, 'increase' );
		var offset = o.offset();
		$pop.hide().appendTo('body').css({	
				left: offset.left,
				top: offset.top + o.height(),
				width: o.width() + parseInt( o.css('padding-left') )
			}).fadeIn('fast');
	});
	$('.t_montha').click(function(){
		var o = $(this);
		var $pop = makeSelect( o, 1, 12, 'increase' );
		var offset = o.offset();
		$pop.hide().appendTo('body').css({	
				left: offset.left,
				top: offset.top + o.height(),
				width: o.width() + parseInt( o.css('padding-left') )
			}).fadeIn('fast');
	});

	$('.t_day').click(function(){
		var o = $(this);
		var $pop = makeSelect( o, 1, 31, 'increase' );
		var offset = o.offset();
		$pop.hide().appendTo('body').css({	
				left: offset.left,
				top: offset.top + o.height(),
				width: o.width() + parseInt( o.css('padding-left') ),
				height: 200
			}).fadeIn('fast');
	});
	$('.t_daya').click(function(){
		var o = $(this);
		var $pop = makeSelect( o, 1, 31, 'increase' );
		var offset = o.offset();
		$pop.hide().appendTo('body').css({	
				left: offset.left,
				top: offset.top + o.height(),
				width: o.width() + parseInt( o.css('padding-left') ),
				height: 200
			}).fadeIn('fast');
	});
});
function healthtime()
{
date = new Date();
var countyear = date.getFullYear();
var countmonth = date.getMonth();
var countday = date.getDate();
document.cal.m1.value = countmonth+1;
document.cal.y1.value = countyear;
document.cal.da1.value = countday;
document.cal.m.value = countmonth+1;
document.cal.y.value = countyear-19;
document.cal.da.value = countday;
}