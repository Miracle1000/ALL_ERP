
function yhvalueKeyUp(obj){
	obj.value=obj.value.replace(/[^\d\.]/g,'');
	checkDot('yhvalue',jQuery('#yh1:checked').size()>0?window.sysConfig.moneynumber:window.sysConfig.discountDotNum);
}

jQuery(function(){
	jQuery('.yhtype').click(function(e,f){
		var $o = jQuery('#yhvalue');
		var v = jQuery(this).val();
		$o.trigger('select');
		if(v=='0'){
			$o.removeAttr('dataType');
			if(f!=true) $o.val(FormatNumber(0,window.sysConfig.moneynumber));
		}else if(v=='1'){
			$o.attr({
				dataType:"Range",
				min:0,
				max:window.sysConfig.discountMaxLimit,
				msg:"折扣必须控制在0-"+window.sysConfig.discountMaxLimit+"之间"
			});
			if(f!=true) $o.val(FormatNumber(1,window.sysConfig.discountDotNum));
		}
		jQuery("#yhvalue").next('span').html('');
	});

	jQuery(':radio:checked[name="yhtype"]').trigger('click',true);
});
