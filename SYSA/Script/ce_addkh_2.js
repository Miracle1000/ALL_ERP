
function changeYHType(v){
	Calculation(3);
	var $o = jQuery('#yhvalue');
	$o.trigger('select');
	if(v==0){
		$o.removeAttr('dataType');
	}else if(v==1){
		$o.attr({
			dataType:"Range",
			min:0,
			max:window.sysConfig.discountMaxLimit,
			msg:"折扣必须控制在0-"+window.sysConfig.discountMaxLimit+"之间"
		});
	}
	jQuery("#yhvalue").next('span:eq(0)').html('');
}

function yhvalueKeyUp(obj){
	obj.value=obj.value.replace(/[^\d\.]/g,'');
	checkDot('yhvalue',jQuery('#yh1:checked').size()>0?window.sysConfig.moneynumber:window.sysConfig.discountDotNum);
	Calculation(1);
}

function Calculation(n){
	var m1=jQuery("#premoney");//项目总额
	var yh=jQuery("#yhvalue");
	var ma=jQuery("#moneyall");//优惠后总额	
	var m1value=m1.val();
	var yhvalue=yh.val();
	var mavalue=ma.val();
	if (m1value.length==0){m1value=0;}
	if (yhvalue.length==0){yhvalue=0;}
	if (mavalue.length==0){mavalue=0;}
	var ctype=jQuery('input[name="yhtype"]:checked').val();	//优惠类型
	if(n==1){
		if(yh.val().length>1 && yh.val().substring(0,1)=="0" && yh.val().substring(1,2)!="."){yh.val(parseFloat(yhvalue));}
		if (ctype=="0"){//优惠金额
			if (parseFloat(yhvalue)>parseFloat(m1value)){			
				yh.val(formatNumDot(0,window.sysConfig.moneynumber));
				yhvalue=formatNumDot(0,window.sysConfig.moneynumber);
				yh.next('span:eq(0)').html("不能大于项目总额");
			}else{
				yh.next('span:eq(0)').html("");
			}
			ma.val(formatNumDot(parseFloat(m1value)-parseFloat(yhvalue),window.sysConfig.moneynumber));
			if (parseFloat(m1value)==0){
				ma.val(formatNumDot(0,window.sysConfig.moneynumber));
			}
		}else{//折扣
			yh.next('span:eq(0)').html("");
			ma.val(formatNumDot(parseFloat(m1value)*parseFloat(yhvalue),window.sysConfig.moneynumber));
		}
		checkDot('moneyall',window.sysConfig.moneynumber);
		jQuery("#Inverse").val(0);
	}else if (n==2){	
		yh.val(0);
		if(ma.val().length>1 && ma.val().substring(0,1)=="0" && ma.val().substring(1,2)!="."){ma.val(parseFloat(mavalue));}
		if (parseFloat(m1value)>0){
			if (ctype=="0"){//优惠金额
				if (parseFloat(mavalue)>parseFloat(m1value)){
					yh.val(formatNumDot(0,window.sysConfig.moneynumber));
					yh.next('span:eq(0)').html("不能大于项目总额");
					ma.val(formatNumDot(parseFloat(m1value),window.sysConfig.moneynumber));
				}else{
					yh.next('span:eq(0)').html("");
					yh.val(formatNumDot(parseFloat(m1value)-parseFloat(mavalue),window.sysConfig.moneynumber));
				}
			}else{//折扣
				yh.next('span:eq(0)').html("");
				yh.val(formatNumDot((parseFloat(mavalue))/parseFloat(m1value),window.sysConfig.discountDotNum));	
			}
		}
		checkDot('yhvalue',jQuery('#yh1:checked').size()>0?window.sysConfig.moneynumber:window.sysConfig.discountDotNum);
		jQuery("#Inverse").val(1);
	}else{
		jQuery("#Inverse").val(0);
		ma.val(formatNumDot(mavalue,window.sysConfig.moneynumber));
		if(ctype=="0"){//优惠金额
			yh.val(formatNumDot(parseFloat(m1value)-parseFloat(mavalue),window.sysConfig.moneynumber));
		}else{//折扣
			yh.val(formatNumDot(parseFloat(m1value)==0?1:parseFloat(mavalue)/parseFloat(m1value),window.sysConfig.discountDotNum));
		}
	}
	if(jQuery("select[name='plan']").val()=='2'){
		frameResize1();
	}
}
