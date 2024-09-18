function go(loc) {window.location.href = loc;}
//合并收款编辑明细合同产品金额
var isSaveMx = false; //是否保存当前明细
function setMxMoney(id)
{		
	var money1 = 0;
	var isUp=false
	$(".paybackmx").find(".mxlistData").each(function(){
		if($(".paybackmx").find("#s_"+$(this).attr("name").replace("mx_","")+':checked').size()>0)
		{
			money_one =$(this).val();			
			if (money_one.replace(" ","")!="")
			{
				if($(".paybackmx").find("#s_"+$(this).attr("name").replace("mx_","")+':checked').attr("class")=="yhmoney")
				{
					money1 -= parseFloat(money_one);
				}
				else{
					money1 += parseFloat(money_one);
				}
			}
		}
		isUp = true ;
	})

	$(".paybackmx").find(".mxlistData_th").each(function(){
		if($(".paybackmx").find("#s_"+$(this).attr("name").replace("mx_","")+":checked").size()>0)
		{
			money_one =$(this).val();
			if (money_one.replace(" ","")!="")
			{
					money1 -= parseFloat(money_one);	
			}
		}
		isUp = true ;
	})
	if (isUp){
		document.getElementById("invoive_"+id).value=FormatNumber(money1,window.sysConfig.moneynumber);
		sethbMoney(id,true);
	}
}

function setMoney2(txt, ord){
	var txtid = txt.id;
	var txtValue = txt.value	
	if (txtValue.replace(" ","") != ""){
		txtValue = txtValue.replace(" ","");
		var mxid = txtid.split("_")[1];
		var money1 = 0
		var ymoney1=0;
		var num1 = 0;
		var ynum1 = 0;
		if(txtid.indexOf("num_") > -1){				//数量		本次产品数量/计划开票明细数量 * 计划开票金额 = 本次开票金额
			num1 = Number(txtValue);			
			ynum1 = Number($("#ynum_"+mxid).val());
			ymoney1 = Number($("#ymoney_"+mxid).val());
			money1 = (num1 / ynum1) * ymoney1;			
			$(".paybackmx").find("#mx_"+mxid).val(FormatNumber(money1,window.sysConfig.moneynumber));
		}else if(txtid.indexOf("mx_") > -1){		//金额	反算开票数量	 	本次开票金额 / 计划开票金额 * 计划开票明细数量 = 本次产品数量
			money1 = Number(txtValue);
			ymoney1 = Number($("#ymoney_"+mxid).val());
			ynum1 = Number($("#ynum_"+mxid).val());
			num1 = (money1 / ymoney1) * ynum1;
			$(".paybackmx").find("#num_"+mxid).val(FormatNumber(num1,window.sysConfig.floatnumber));
		}
		setMxMoney(ord);
	}
}
//合并收款编辑汇总合同金额   isEditDiv 是否计算弹出层的数据
function sethbMoney(id,isEditDiv)
{
	var money1=0;
	var money_one=0;
	$(".htlistData").each(function(){
		money_one =$(this).val();
		if (money_one.replace(" ","")!=""){money1 += parseFloat(money_one);}
	})
	document.getElementById("money1").value=FormatNumber(money1,window.sysConfig.moneynumber);
	var oldmoney =$("#invoive_"+id).attr("max");
	var newmoney = $("#invoive_"+id).val();
	var obj = null;
	if (isSaveMx || isEditDiv){
		obj = $('.paybackmx');
	}else{
		obj = $("#paybackinvoice_"+id);
	}
	//判断当前行下次数据
	var checkYh=false ;
	if (obj.find(".yhmoney").size()>0){
		var yhMoney=obj.find("#mx_"+obj.find(".yhmoney").val()).val();
		var maxMoney = obj.find("#mx_"+obj.find(".yhmoney").val()).attr("max");
		if (obj.find(".yhmoney:checked").size()==0 || parseFloat(yhMoney)!=parseFloat(maxMoney)){checkYh = true;}
	}
	if (parseFloat(oldmoney)!=parseFloat(newmoney) || checkYh ){
		document.getElementById("money3_"+id).value=FormatNumber(parseFloat(oldmoney)-parseFloat(newmoney),window.sysConfig.moneynumber);
		document.getElementById("next_"+id).style.display="";
	}else{
		document.getElementById("next_"+id).style.display="none";
		document.getElementById("money3_"+id).value="0";
	}
	isSaveMx=false;
}

//检测下次回款日期
function checkReminDate(ctype) {
    var v=0;
    var dots = v.toFixed((window.sysConfig.moneynumber-1)) + 1;
	var selectid = window.selectid;
	var isSub=true;
	var maxAmount = document.getElementById("maxAmount").value;//发票最大金额
	var maxCount = document.getElementById("maxCount").value;//发票最大行数
	//合并
	if($(".htlistData").size()==0)
	{
		alert("未选择开票单据，无法合并开票！");
		isSub = false;
	}
	$(".htlistData").each(function()
		{
			if (isSub)
			{				
				id = $(this).attr("name").replace("invoive_","");
				if ($(this).attr("invoiceMode")=="2")
				{
					var actCount = 0;
					$("#paybackinvoice_"+id).find(".mxlistselect:checked").each(function(){
						var kpid = $(this).val();
						var mxMoney = $("#mx_"+kpid).val();
						if(isNaN(mxMoney)){mxMoney = 0; }else{mxMoney = Number(mxMoney);}
                        if (mxMoney > 0) {
                            actCount += 1;
                        }
                        else {
                            alert("本次开票金额不能为0！")
                            isSub = false;
                        }
					});
					if(actCount>maxCount && maxCount>0)
					{
						alert("该票据类型最大开票明细行数为"+maxCount+"，请确认后再开票！");
						isSub= false;
					}
					else if (actCount==0)
					{						
						alert("请选择单据的开票明细后再开票！");
						isSub = false;
					}
				}
				oldmoney = $(this).attr("max");
				money_one =$(this).val();
				//if (parseFloat(money_one)==0 && isSub){
				//	alert("每个单据开票金额不能为0！")
				//	isSub= false;
				//}					
				if (parseFloat(money_one)>parseFloat(maxAmount) && parseFloat(maxAmount)!=0 && isSub)
				{
					alert("该票据类型最大开票金额为"+FormatNumber(maxAmount,window.sysConfig.moneynumber)+"，请确认后再开票！");
					isSub= false;
				}				
				if (money_one.replace(" ","")!="")
				{
					var checkYh=false ;
					if ($("#paybackinvoice_"+id).find(".yhmoney").size()>0)
					{
						var yhMoney=$("#paybackinvoice_"+id).find("#mx_"+$("#paybackinvoice_"+id).find(".yhmoney").val()).val();
						var maxMoney = $("#paybackinvoice_"+id).find("#mx_"+$("#paybackinvoice_"+id).find(".yhmoney").val()).attr("max");
						if ($("#paybackinvoice_"+id).find(".yhmoney:checked").size()==0 || parseFloat(yhMoney)!=parseFloat(maxMoney))
						{
							checkYh = true;
						}
					}
					if ((parseFloat(oldmoney) != parseFloat(money_one) || checkYh) && isSub && Math.abs((parseFloat(oldmoney) - parseFloat(money_one))) > dots)
					{
						if(document.getElementById("daysdate1_"+id+"Pos").value == "")
						{
							alert("请填写下次开票日期");
							isSub = false ;
						}
					}
				}
			}
		}
	)
	if (isSub)
	{	
		var formObj = document.getElementById("demo");
		if (Validator.Validate(formObj,2)){formObj.submit();}
	}	
}

//打开编辑明细
function editMx(id){
	var invoicemx = $("#paybackinvoice_"+id);
	var reloadmx = $("#reloadmx_"+id).val();
	reloadmx = reloadmx + "";
	if (reloadmx == "0"){
		$.ajax({
			url:"getInvoiceList.asp?invoice="+id+"&timestamp=" + new Date().getTime() ,
			success:function(r){
				$('.paybackmx').html(r);
				invoicemx.html(r);
				mxWin(id)
			}
		});
	}else if (reloadmx == "1"){
	    $('.paybackmx').html(invoicemx.html());
	    invoicemx.find("input").each(function () {
	        var v = $(this).val();
	        var dbname = $(this).attr("id");
	        if (dbname) { $('.paybackmx').find("#" + dbname)[0].value = v; }
	    })
		mxWin(id)
	}
}

function mxWin(id){
	$("#ww").window({
		title:'产品明细',
		//top : 140,
		width:750,
		height:420,
		//left: 390,
		closeable:true,
		collapsible:false,
		minimizable:false,
		maximizable:false,
		modal:true,
		onClose:function(){resetMxMoney(id);},
		onOpen:function(){
			$("#btnDiv").show();
			$("#savebtn").unbind("click");
			$("#rebtn").unbind("click");
			$("#savebtn").bind("click",function(){saveEditMx(id);});
			$("#rebtn").bind("click",function(){$("#ww").window("close");});
		}
	}).window('open').show();	
	$("#paybackinvoice_"+id).find("input[id^='isEditMx_']").val(1);
}

//还原合编辑明细合同产品金额
function resetMxMoney(id){		
	var money1 = 0;
	var obj = null;
	if (isSaveMx){
		obj = $('.paybackmx');
	}else{
		obj = $("#paybackinvoice_"+id);
	}

	obj.find(".mxlistData").each(function(){
		if(obj.find("#s_"+$(this).attr("name").replace("mx_","")+':checked').size()>0){
			money_one =$(this).val();
			if (money_one.replace(" ","")!=""){
				if (obj.find("#s_"+$(this).attr("name").replace("mx_","")+':checked').attr("class")=="yhmoney"){
					money1 -= parseFloat(money_one);
				}else{
					money1 += parseFloat(money_one);
				}
			}
		}
	})
	
	obj.find(".mxlistData_th").each(function(){
		if(obj.find("#s_"+$(this).attr("name").replace("mx_","")+":checked").size()>0){
			money_one =$(this).val();
			if (money_one.replace(" ","")!=""){
				money1 -= parseFloat(money_one);	
			}
		}
	})
	document.getElementById("invoive_"+id).value=FormatNumber(money1,window.sysConfig.moneynumber);
	$(".paybackmx").html("");
	sethbMoney(id);
}

function saveEditMx(id){
	var isSave= true ;
	$(".paybackmx").find(".mxlistData").each(function(){					
			money_one =$(this).val();
			min = $(this).attr("min");
			max = $(this).attr("max");
			if (money_one.replace(" ","")!=""){
				if (parseFloat(money_one)<parseFloat(min)||parseFloat(money_one)>parseFloat(max)){
					$(this).attr("style","color:red");
					isSave= false ;
				}
			}
	})
	isSaveMx = isSave;
	if (isSave) {
	    $(".paybackmx").find("input").each(function () {
	        var v = $(this).val();
	        var dbname = $(this).attr("id");
	        if (dbname) $("#paybackinvoice_" + id).find("#" + dbname)[0].value = v;
	    })
		$("#ww").window("close");
	}
}

function del(contract)
{
	var money =parseFloat($("#ysMoney").val())-parseFloat($("#invoive_"+contract).attr("defaultValue"));
	$("#ysMoney").val(money);
	$("#money1").val(FormatNumber(parseFloat($("#money1").val())-parseFloat($("#invoive_"+contract).val()),window.sysConfig.moneynumber));
	$("#invoice_"+contract).remove(); 
}

function selectall(obj,id)
{
	$(".paybackmx").find("input[name='selectid']").attr("checked",obj.checked);
	setMxMoney(id);
}

function GetTitle(ord,stype){
	//http://127.0.0.1/money/checktitle.asp?ord=47524&InvoiceType=204
	$('#w').html('<iframe src="CheckTitle.asp?ord='+ord+'&InvoiceType='+stype+'" style="width:100%;height:100%" frameborder="0"></iframe>')
		.window({
				title:'发票信息选择',
				top:200,
				width:340,
				height:220,
				closeable:true,
				collapsible:false,
				minimizable:false,
				maximizable:false,
				modal:true
		}).window('open');
}

function GetInvoiceType(ord,stype,paybackInvoiceid,jsType,bank,come){
	//http://127.0.0.1/money/paybackinvoice.asp?ord=ANR%D6%C7%B0%EEOM%D6%C7%B0%EEMR%D6%C7%B0%EEPE%D6%C7%B0%EEQM%D6%C7%B0%EEQH%D6%C7%B0%EE4&fromtype=PREBACK#
	$.ajax({
	    url: "InvoiceType_cell.asp?ord=" + ord + "&InvoiceType=" + stype + "&come=" + come + "&bank=" + bank + "&paybackInvoiceid=" + paybackInvoiceid,
		success:function(r){
			if (r!=""){			
				$('#InvoiceTypeDiv').html(r);
				$('#InvoiceTypeTr').show();
				if (jsType==1){$("#title").val($('#w').find('iframe').get(0).contentWindow.$("#newTitle").val());}
			}else{
				$('#InvoiceTypeTr').hide();
			}
		}
	});
}