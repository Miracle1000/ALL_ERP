
function frameResize2(){
	document.getElementById("hklist").style.height=P3.document.body.scrollHeight+0+"px";
}

function lockMoneyInput(flg,obj){
	jQuery.ajax({
		url:'../store/commonReturn.asp?act=clearFQ',
		success:function(r){
			jQuery('#hklist').get(0).contentWindow.location.reload();
		}
	});

	var $input = jQuery('#money_hk');
	if($input.size()==0) return;
	if(flg){
		$input.val(jQuery('#moneyall').val());
		$input.attr('readonly',true)
	}else{
		$input.removeAttr('readonly');
	}
}
