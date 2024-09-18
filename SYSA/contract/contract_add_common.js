function frameResize(){
	try{
		var tb =  I3.document.body.getElementsByTagName("table")[0];
		document.getElementById("mxlist").style.height=$(tb).height()+20+"px";
	}catch(e){
		try{
			var h = document.getElementById("demo").offsetHeight<screen.availHeight?screen.availHeight:document.getElementById("demo").offsetHeight;
			parent.document.getElementById("cFF").style.height=h;
		}catch(e){}
	}
}

function OnSaveFrom(tag) {
    var obj = document.getElementById("demo");
	if(tag==0){
	    if(!Validator.Validate(obj, 2) || !checkhtForm() || !checkQualifications()){
			return;
		}
	} 
	if (Validator.Validate(obj, 2) && DelUnusedFilesBeforeSubmit()) {
	    obj.submit();
	}
}

//有点啰嗦，有优化的空间
function Calculation(n,fromType){
	if(typeof(fromType) == "undefined"){fromType = "contract";}
	var fromTypeName = "合同"
	var m1=jQuery("#premoney");//项目总额
	var yh=jQuery("#yhvalue");
	var ma=jQuery("#moneyall");//优惠后总额	
	var m1value=m1.val();
	var yhvalue=yh.val();
	var mavalue=ma.val();
	if (m1value.length==0){m1value=0;}
	if (yhvalue.length==0){yhvalue=0;}
	if (mavalue.length==0){mavalue=0;}
	if(fromType=="caigou"){fromTypeName="采购";}
	var ctype = "0";//jQuery('input[name="yhtype"]:checked').val();	//优惠类型
	if(n==1 || n==4){
		if(yh.val().length>1 && yh.val().substring(0,1)=="0" && yh.val().substring(1,2)!="."){yh.val(parseFloat(yhvalue));}
		if (ctype=="0"){//优惠金额
			if (parseFloat(yhvalue)>parseFloat(m1value)){			
				yh.val(formatNumDot(0,window.sysConfig.moneynumber));
				yhvalue=formatNumDot(0,window.sysConfig.moneynumber);
				yh.next('span:eq(0)').html("不能大于"+ fromTypeName +"总额");
			}else{
				yh.next('span:eq(0)').html("");
			}
			var moneyall = parseFloat(m1value) - parseFloat(yhvalue);
			if (moneyall < 0) moneyall = 0;
			ma.val(formatNumDot(moneyall, window.sysConfig.moneynumber));
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
					yh.next('span:eq(0)').html("不能大于"+ fromTypeName +"总额");
					ma.val(formatNumDot(parseFloat(m1value),window.sysConfig.moneynumber));
				}else{
				    yh.next('span:eq(0)').html("");
				    var yhmoney = parseFloat(m1value) - parseFloat(mavalue);
				    if (yhmoney < 0) yhmoney = 0;
				    yh.val(formatNumDot(yhmoney, window.sysConfig.moneynumber));
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
		if (ctype == "0") {//优惠金额
		    var yhmoney = parseFloat(m1value) - parseFloat(mavalue);
		    if (yhmoney < 0) yhmoney = 0;
		    yh.val(formatNumDot((yhvalue == 0 ? yhmoney : yhvalue), window.sysConfig.moneynumber));
		}else{//折扣
		    yh.val(formatNumDot(parseFloat(m1value) == 0 ? (yhvalue == 0 ? 1 : yhvalue) : parseFloat(mavalue) / parseFloat(m1value), window.sysConfig.discountDotNum));
		}
	}
	jQuery('#money_hk').val(ma.val());
	mavalue=ma.val();
	if(jQuery('#money_zs').size()>0){
		jQuery('#money_zs').val(FormatNumber(mavalue,window.sysConfig.moneynumber));
		var money2= jQuery("#money_hk");//实收金额
		var money3= jQuery("#money_zl");//找零
		var m3=parseFloat(money2.val())-parseFloat(mavalue); 
		if (m3<0) m3=0;
		money2.val(FormatNumber(mavalue,window.sysConfig.moneynumber));
		money3.val(FormatNumber(m3,window.sysConfig.moneynumber));
	}

	if(jQuery("select[name='plan']").val()=='2'){
		frameResize1();
	}
}


function qDDateChange(obj){
	try{
		if ($("#daysOfMonth6Pos").size()>0)
		{
			var date1 = $(obj).val();
			if (date1.length>0)
			{
				var now=new Date();
				var hours=now.getHours()+"";
				hours = (hours.length==1? "0" : "")+ hours;
				var minutes=now.getMinutes()+"";
				minutes = (minutes.length==1? "0" : "")+ minutes;
				var seconds=now.getSeconds()+"";
				seconds = (seconds.length==1? "0" : "")+ seconds;
				$("#daysOfMonth6Pos").val(date1+" "+hours+":"+minutes+":"+seconds);
			}
		}
	}catch(e){}
}

function hlCheck(){
	var result = true;
	var $bz = jQuery('#bizhong');
	var $dt = jQuery(':input[name="ret3"]');
	var dt = $dt.val().split(" ")[0];
	jQuery.ajax({
		url:'../contract/AjaxReturn.asp',
		data:{
			act:'checkHL',
			hldate:dt,
			bz:$bz.val()
		},
		cache:false,
		async:false,
		success:function(r){
			var json = eval('('+r+')');
			if (json.success == false){
				alert('币种【'+$bz.children(':selected').text()+'】在【'+dt+'】的汇率没有设置，请先设置汇率！');
				result =  false;
			}
		},
		error:function(){
			result = false;
		}
	});
	return result;
}


//根据币种ID获取收款账号
function getBankAccountByBzId(obj){
	var $o = jQuery(obj);
	var bz = $o.val();
	var s = "<option value=''>选择账号</option>";
	jQuery.ajax({
		url:"../contract/getBankAccountByBzId.asp?bz="+bz+"&r="+ Math.random(),
		type:"post",
		dataType:"json",
		success:function(json){
			for(var i=0;i<json.length;i++){
				s = s + "<option value="+json[i].id;
				s = s + ">"+json[i].name+"</option>"
			};
			jQuery("#bank").html(s);
		}
	});

	var $span = $o.nextAll("span:eq(1)");
	//alert($span.size());
	if($span.size()==0) $span=jQuery('<span class="red"/>').insertAfter($o.next("span"));
	if(bz!=''&&$span.next('span').size()>0){
		$span.next('span').remove();
	}

	if (bz=='' || bz=='14'){
		$span.html('');
		return;
	}

	var $dt = jQuery('#hldatePos');
	var dt = $dt.val().split(" ")[0];
	//window.location = '../contract/AjaxReturn.asp?act=checkHL&hldate='+dt+'&bz='+bz;return;
	jQuery.ajax({
		url:'../contract/AjaxReturn.asp',
		data:{
			act:'checkHL',
			hldate:dt,
			bz:bz
		},
		cache:false,
		success:function(r){
			//	alert(r);
			var json = eval('('+r+')');
			if (json.success == false){
				if(json.canSetBank){
					$span.html('&nbsp;<a href="#">设置</a>');
					$span.children('a').click(function(){
						window.open('../hl/edit.asp','setHTLwin','width=900,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=200');
					});
				}else{
					$span.html('&nbsp;请联系管理员设置当天汇率！');
				}
			}else {
				$span.html('');
			}
		},
		error:function(res){
			alert(res.responseText);
		}
	});
}

jQuery(function(){

	//KILLER 回款计划中默认选择分析回款 在明细下面不出 “分期回款计划”一栏
	jQuery('select[name="plan"]').trigger('change');

	jQuery('.content-split-bar').click(function(e){
		var $o=jQuery(this);
		var flg = $o.attr('flg')||"0";
		var extra = $o.attr('extra') || "";
		var src = '';
        if(window.sysConfig.BrandIndex == 1){
            src = flg=="0"?"../images/r_up.png":"../images/r_down.png";
        }else if(window.sysConfig.BrandIndex == 3){
            src = flg=="0"?"../skin/default/images/MoZihometop/content/r_up.png":"../skin/default/images/MoZihometop/content/r_down.png";
        }
		var $tr = $o.nextUntil('tr.content-split-bar,.content-split-foot',jQuery('select[name="plan"]').val()=="2"?"":"tr:not([id])");
		if (extra.length>0){
			flg=="0"?$tr.hide():$tr.each(function(t){
				var ex = jQuery(this).attr('ex') || ""; 
				if (ex=="0"){
					var s = jQuery("input[name='"+extra+"']").val();
					if (s==""){jQuery(this).hide();}else{jQuery(this).show();}
				}else{
					jQuery(this).show();
				}
			});
		}else{
			flg=="0"?$tr.hide():$tr.show();
		}
		for (var i = 0; i<$tr.length ; i++ )
		{
			var tr = $tr[i];
			if(tr.getAttribute("inithide")=="1"){
				tr.style.display = "none";
			}
		}
		$o.attr('flg',flg=="0"?"1":"0").find('.content-split-icon').attr("src",src);
	}).find(':reset,:button,:submit').click(function(e){
		e.stopPropagation();
	});
});

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

function yhvalueKeyUp(obj, fromType){
	if(typeof(fromType) == "undefined"){fromType = "contract";}
	obj.value=obj.value.replace(/[^\d\.]/g,'');
	checkDot('yhvalue',jQuery('#yh1:checked').size()>0?window.sysConfig.moneynumber:window.sysConfig.discountDotNum);
	Calculation(1, fromType);
}

function checkQualifications(){
	var telOrd ;
	if(document.getElementById('companyOrd')){
		telOrd = document.getElementById('companyOrd').value
	}else{
		telOrd = document.getElementById('company').value;
	}
	if (telOrd.length==0) return false;
	var checkResult = false;

	$.ajax({
		url:'../store/CommonReturn.asp?act=checkQualifications&company=' + telOrd ,
		async:false,
		success:function(r){
			try{
				var json = eval('('+r+')');
				checkResult = json.success;
				if (!checkResult){
					alert(json.msg);
				}
			}catch(e){
				checkResult = false;
				alert(r);
			}
		}
	});
	return checkResult;
}