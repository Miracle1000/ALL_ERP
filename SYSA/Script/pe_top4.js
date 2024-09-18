

// 一个简单的测试是否IE浏览器的表达式
isIE = (document.all ? true : false);

// 得到IE中各元素真正的位移量，即使这个元素在一个表格中
function getIEPosX(elt) { return getIEPos(elt,"Left"); }
function getIEPosY(elt) { return getIEPos(elt,"Top"); }
function getIEPos(elt,which) {
 iPos = 0
 while (elt!=null) {
  iPos += elt["offset" + which]
  elt = elt.offsetParent
 }
 return iPos
}
function ask() { 
document.all.date.action = "savelistadd13.asp"; 
} 
// -->
function yhvalueKeyUp(obj){
	obj.value=obj.value.replace(/[^\d\.]/g,'');
	checkDot('yhvalue',jQuery('#yh1:checked').size()>0?window.sysConfig.moneynumber:window.sysConfig.discountDotNum);
}

jQuery(function(){
	jQuery('.yhtype').click(function(e,f){
		var $o = jQuery('#yhvalue');
		var v = jQuery(this).val();
		if(v=='0'){
			$o.removeAttr('dataType');
			$o.val(FormatNumber(f?$o.val():0,window.sysConfig.moneynumber));
		}else if(v=='1'){
			$o.attr({
				dataType:"Range",
				min:0,
				max:window.sysConfig.discountMaxLimit,
				msg:"折扣必须控制在0-"+window.sysConfig.discountMaxLimit+"之间"
			});
			$o.val(FormatNumber(f?$o.val():1,window.sysConfig.discountDotNum));
		}
		jQuery("#yhvalue").next('span').html('');
		$o.trigger('select');
	});

	jQuery(':radio:checked[name="yhtype"]').trigger('click',true);
});
