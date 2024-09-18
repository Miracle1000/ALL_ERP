
function checkMoney(invoiceMode)
{
	var moneyall=document.getElementById("money1");
	if (invoiceMode=="2")
	{
		setMoney();
		var actCount = 0;
		var maxCount = document.getElementById("maxCount").value;//发票最大行数
		$(".mxlistselect:checked").each(function(){
			var kpid = $(this).val();
			var mxMoney = $("#mx_"+kpid).val();
			if(isNaN(mxMoney)){mxMoney = 0; }else{mxMoney = Number(mxMoney);}
			if (mxMoney > 0){
				actCount += 1;
			}
		});
		if(actCount>maxCount && maxCount>0)
		{
			alert("该票据类型最大开票明细行数为"+maxCount+"，请确认后再开票！");
			return false;
		}
		else if (actCount==0)
		{
			alert("请选择开票明细后再开票！");
			return false;
		}
		//if (parseFloat(moneyall.value)<=0)
		//{
			//alert("明细开票总额必须大于0");
			//return false;
		//}
	}
	else 
	{
		if (parseFloat(moneyall.value)==0)
		{
			alert("汇总开票金额不能等于0");
			return false;
		}
	}
	var maxAmount = document.getElementById("maxAmount").value;//发票最大金额
	if (parseFloat(moneyall.value)>parseFloat(maxAmount) && parseFloat(maxAmount)!=0)
	{
		alert("该票据类型最大开票金额为"+FormatNumber(maxAmount,window.sysConfig.moneynumber)+"，请确认后再开票！");
		return false;
	}

	var money_plan=document.getElementById("money_plan");
	var oldmoney = money_plan.defaultValue.replace(",","")
	var checkYh=false ;
	var yhmoneyObj = document.getElementById("yhmoney");
	if (yhmoneyObj)
	{
		if ($(".yhmoney:checked").size()==0 ||parseFloat(yhmoneyObj.value)!=parseFloat(yhmoneyObj.getAttribute("max")))
		{
			checkYh = true;
		}
	}
	if (parseFloat(oldmoney)!=parseFloat(moneyall.value) || checkYh)
	{		
		if(document.getElementById("daysOfMonth6Pos").value == "")
		{
			alert("请填写下次开票日期");
			return false;
		}
	}
	return true;
}

//单个收款编辑总金额
function setMoneyAll(money1) {
    var money_dot = window.sysConfig.moneynumber;
    var money_plan = document.getElementById("money_plan");
    var oldmoney = money_plan.defaultValue.replace(",", "")
    var checkYh = false;
    var taxrates = document.getElementById("taxrates");
    var taxrate = parseFloat($("#taxrates").attr("tax"));
    if (taxrates) {
        $("#rateMoney1Div").html(FormatNumber(money1 - money1 / (1 + parseFloat(taxrate)) * parseFloat(taxrate), money_dot));
        $("#rateMoney2Div").html(FormatNumber(money1 / (1 + parseFloat(taxrate)) * parseFloat(taxrate), money_dot));
    }
    var yhmoneyObj = document.getElementById("yhmoney");
    if (yhmoneyObj) {
        if ($(".yhmoney:checked").size() == 0 || parseFloat(yhmoneyObj.value) != parseFloat(yhmoneyObj.getAttribute("max"))) {
            checkYh = true;
        }
    }
    if (parseFloat(oldmoney) != money1 || checkYh) {
        document.getElementById("remainMoney").value = FormatNumber(parseFloat(oldmoney) - money1, window.sysConfig.moneynumber);
        document.getElementById("remainTr").style.display = "";
    }
    else {
        document.getElementById("remainTr").style.display = "none";
        document.getElementById("remainMoney").value = "0";
    }
}


function setMoney()
{
    var topTaxMoney1 = 0;
    var topTaxMoney2 = 0;
    var money1 = 0;
    var money_one = 0;
    var money_two = 0;
    $(".mxlistData").each(function () {
        var id = $(this).attr("name").replace("mx_", "");
        if ($("#s_" + id + ":checked").size() > 0) {
            money_one = $(this).val();
            if (money_one.replace(" ", "") != "") {
                if ($(this).attr("id") == "yhmoney") {
                    money1 -= parseFloat(money_one);
                }
                else {
                    money1 += parseFloat(money_one);
                }
            }

            money_one = $("#mtaxMoney1_" + id).html();
            if (money_one != null) {
                money_one = money_one.replace(",", "");
                if (money_one.replace(" ", "") != "") {
                    if ($(this).attr("id") == "yhmoney") {
                        topTaxMoney1 -= parseFloat(money_one);
                    }
                    else {
                        topTaxMoney1 += parseFloat(money_one);
                    }
                }
            }
            money_two = $("#mtaxMoney2_" + id).html();
            if (money_two != null) {
                money_two = money_two.replace(",", "");
                if (money_two.replace(" ", "") != "") {
                    if ($(this).attr("id") == "yhmoney") {
                        topTaxMoney2 -= parseFloat(money_two);
                    }
                    else {
                        topTaxMoney2 += parseFloat(money_two);
                    }
                }
            }
        }
    });

    $(".mxlistData_th").each(function () {
        var id = $(this).attr("name").replace("mx_", "");
        if ($("#s_" + id + ":checked").size() > 0) {
            money_one = $(this).val();
            if (money_one.replace(" ", "") != "") {
                money1 -= parseFloat(money_one);
            }

            money_one = $("#mtaxMoney1_" + id).html().replace(",", "");
            if (money_one.replace(" ", "") != "") {
                topTaxMoney1 -= parseFloat(money_one);
            }
            money_two = $("#mtaxMoney2_" + id).html().replace(",", "");
            if (money_two.replace(" ", "") != "") {
                topTaxMoney2 -= parseFloat(money_two);
            }
        }
    });

    $("#rateMoney1Div").html(FormatNumber(topTaxMoney1, window.sysConfig.moneynumber));
    $("#rateMoney2Div").html(FormatNumber(topTaxMoney2, window.sysConfig.moneynumber));
	setMoneyAll(money1);
	document.getElementById("money1").value=FormatNumber(money1,window.sysConfig.moneynumber);
}

function setMoney2(txt){
	var txtid = txt.id;
	var txtValue = txt.value	
	if (txtValue.replace(" ","") != ""){
		txtValue = txtValue.replace(" ","");
		var mxid = txtid.split("_")[1];
		var money1 = 0
		var ymoney1=0;
		var num1 = 0;
		var ynum1 = 0;	
		var taxRate = Number($("#mtaxRate_"+mxid).val());
		var taxMoney1 = 0; var taxMoney2 = 0;
		var num_dot = window.sysConfig.floatnumber;
		var money_dot = window.sysConfig.moneynumber;
		if(txtid.indexOf("num_") > -1){				//数量		本次产品数量/计划开票明细数量 * 计划开票金额 = 本次开票金额
			num1 = Number(txtValue);
			ynum1 = Number($("#ynum_"+mxid).val());
			ymoney1 = Number($("#ymoney_"+mxid).val());			
			money1 = (num1 / ynum1) * ymoney1;
			$("#mx_"+mxid).val(FormatNumber(money1,money_dot)); 			
		}else if(txtid.indexOf("mx_") > -1){		//金额	反算开票数量	 	本次开票金额 / 计划开票金额 * 计划开票明细数量 = 本次产品数量
			money1 = Number(txtValue);
			ymoney1 = Number($("#ymoney_"+mxid).val());
			ynum1 = Number($("#ynum_"+mxid).val());
			num1 = (money1 / ymoney1) * ynum1;
			$("#num_"+mxid).val(FormatNumber(num1,num_dot)); 			
		}

		taxMoney1 = FormatNumber(money1 / (1 + taxRate), money_dot);
		taxMoney2 = FormatNumber(money1 - taxMoney1, money_dot);

		$("#mtaxMoney1_" + mxid).html(taxMoney1);//金额
		$("#mtaxMoney2_" + mxid).html(taxMoney2);//税额
		setMoney();
	}
}

function GetInvoiceType(ord,stype,paybackInvoiceid,jsType,bank,come){
	//http://127.0.0.1/money/paybackinvoice.asp?ord=ANR%D6%C7%B0%EEOM%D6%C7%B0%EEMR%D6%C7%B0%EEPE%D6%C7%B0%EEQM%D6%C7%B0%EEQH%D6%C7%B0%EE4&fromtype=PREBACK#
    if (typeof (bank) == "undefined") {
        bank =""
    }
    if (typeof (come) == "undefined") {
        come = ""
    }
    $.ajax({
	    url: "InvoiceType_cell.asp?ord=" + ord + "&InvoiceType=" + stype + "&paybackInvoiceid=" + paybackInvoiceid + "&bank=" + bank + "&come=" + come,
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

function selectall(obj)
{
	$("input[name='selectid']").attr("checked",obj.checked);
	setMoney();
}
