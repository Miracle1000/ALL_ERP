
function checkMoney()
{
	var invoiceMode = document.getElementById("invoiceMode").value;
	var moneyall=document.getElementById("money1");
	if (invoiceMode=="2")
	{
		setMoney();
		if (parseFloat(moneyall.value)<=0)
		{
			alert("计划开票金额必须大于0");
			return false;
		}
	}
	else 
	{
		if (parseFloat(moneyall.value)==0)
		{
			alert("计划开票金额不能等于0");
			return false;
		}
	}
	return true;
}

function setMoney()
{
	var moneyall=document.getElementById("money1");
	var money1=0;
	var money_one=0;
	$(".mxlistData").each(function()
		{
			money_one =$(this).val();
			if (money_one.replace(/\s+/g, "") != "")
			{
				money1 += parseFloat(money_one);
			}
		}
	)

	$(".mxlistData_th").each(function()
		{
			money_one =$(this).val();
			if (money_one.replace(/\s+/g, "") != "")
			{
				money1 -= parseFloat(money_one);
			}
		}
	)

	var yhmoney = document.getElementById("yhmoney");
	if (yhmoney)
	{	
		money_one = document.getElementById("yhmoney").value;
		if (money_one.replace(/\s+/g, "") != "")
		{
			money1 -= parseFloat(money_one);
		}
	}
	moneyall.value=FormatNumber(money1,window.sysConfig.moneynumber);
	//checkDot("money1",window.sysConfig.moneynumber);	
}

function setMoney2(txt){
	var txtid = txt.id;
	var txtValue = txt.value
	if (txtValue.replace(/\s+/g, "") != "") {
	    txtValue = txtValue.replace(/\s+/g, "");
		var money1 = 0;
		var ymoney1 = 0;
		var rateMoney1Divv = 0;
		var rateMoney2Divv = 0;
		var taxallmoney = 0;
		var yhmoney = $('#yhmoney').val();
		var allmoney = 0;
		var num1 = 0;
		var ynum1 = 0;
		var taxRate = 1;
		var taxMoney1 = 0; var taxMoney2 = 0;
		var num_dot = window.sysConfig.floatnumber;
		var money_dot = window.sysConfig.moneynumber;
		var mxid = txtid.split("_")[1];
		if(txtid =="money1"){
			money1 = Number(txtValue);
            taxRate = Number($("#taxRateDiv").html().replace("%", "")) / 100;
            if (isNaN(taxRate)) { taxRate=1 }
			topTaxMoney2 = FormatNumber(money1 / (1 + taxRate) * taxRate, money_dot);
			topTaxMoney1 = FormatNumber(money1 - money1 / (1 + taxRate) * taxRate, money_dot);
		}else{	
			taxRate = Number($("#mtaxRate_"+mxid).val());
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
			taxMoney2 = FormatNumber(money1 / (1 + taxRate) * taxRate, money_dot);
			taxMoney1 = FormatNumber(money1 - money1 / (1 + taxRate) * taxRate, money_dot);

			$("#mtaxMoney1_" + mxid).html(FormatNumber(taxMoney1, money_dot));
			$("#mtaxMoney2_" + mxid).html(FormatNumber(taxMoney2, money_dot));
			var topTaxMoney1 = 0;
			var topTaxMoney2 = 0;
			var money_one = 0;
			var money_two = 0;
			$(".mxlistData").each(function () {
			    var id = $(this).attr("name").replace("mx_", "");
			    money_one = $("#mtaxMoney1_" + id).html().replace(/,/g, "");
			    if (money_one.replace(/\s+/g, "") != "") {
			        if ($(this).attr("id") == "yhmoney") {
			            topTaxMoney1 -= parseFloat(money_one);
			        }
			        else {
			            topTaxMoney1 += parseFloat(money_one);
			        }
			    }
			    money_two = $("#mtaxMoney2_" + id).html().replace(/,/g, "");
			    if (money_two.replace(/\s+/g, "") != "") {
			        if ($(this).attr("id") == "yhmoney") {
			            topTaxMoney2 -= parseFloat(money_two);
			        }
			        else {
			            topTaxMoney2 += parseFloat(money_two);
			        }
			    }
			});

			$(".mxlistData_th").each(function () {
			    var id = $(this).attr("name").replace("mx_", "");
			    money_one = $("#mtaxMoney1_" + id).html().replace(/,/g, "");
			    if (money_one.replace(/\s+/g, "") != "") {
			        topTaxMoney1 -= parseFloat(money_one);
			    }
			    money_two = $("#mtaxMoney2_" + id).html().replace(/,/g, "");
			    if (money_two.replace(/\s+/g, "") != "") {
			        topTaxMoney2 -= parseFloat(money_two);
			    }
			});
			if (topTaxMoney1 == 0) { topTaxMoney1 = taxMoney1 };
			if (topTaxMoney2 == 0) { topTaxMoney2 = taxMoney2 };
		}
		$("#rateMoney1Div").html(FormatNumber(topTaxMoney1, money_dot));
		$("#rateMoney2Div").html(FormatNumber(topTaxMoney2, money_dot));
		if (txtid != "money1") {
		    setMoney();
		}
	}
}

function GetInvoiceType(ord,stype,paybackInvoiceid,jsType,bank,come){
	//http://127.0.0.1/money/paybackinvoice.asp?ord=ANR%D6%C7%B0%EEOM%D6%C7%B0%EEMR%D6%C7%B0%EEPE%D6%C7%B0%EEQM%D6%C7%B0%EEQH%D6%C7%B0%EE4&fromtype=PREBACK#
    if (typeof (bank) == "undefined") {
       bank=""
    }
    if (typeof (come) == "undefined") {
        come=""
    }
    $.ajax({
	    url: "InvoiceType.asp?ord=" + ord + "&InvoiceType=" + stype + "&paybackInvoiceid=" + paybackInvoiceid + "&bank=" + bank + "&come=" + come,
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

function GetInvoiceType_product_mx(ord,stype,paybackInvoiceid,invoiceMode,yhmoney){
	//http://127.0.0.1/money/paybackinvoice.asp?ord=ANR%D6%C7%B0%EEOM%D6%C7%B0%EEMR%D6%C7%B0%EEPE%D6%C7%B0%EEQM%D6%C7%B0%EEQH%D6%C7%B0%EE4&fromtype=PREBACK#	
	//$('#product_mxlist').html("InvoiceType_product_mx.asp?ord="+ord+"&InvoiceType="+stype+"&paybackInvoiceid="+paybackInvoiceid);
	var money_dot = window.sysConfig.moneynumber;
	if (invoiceMode==2){
		$.ajax({
			url:"InvoiceType_product_mx.asp?ord="+ord+"&InvoiceType="+stype+"&paybackInvoiceid="+paybackInvoiceid + "&yhmoney="+yhmoney,
			success:function(r){
				if (r!="")
				{			
					$('#product_mxlist').html(r);
					$("#money1").val($('#sumMoney').val());
					$("#rateMoney1Div").html(FormatNumber((parseFloat($('#sumMoney').val().replace(/,/g,""))-parseFloat($('#sumTaxMoney').val().replace(/,/g,""))),money_dot));
					$("#rateMoney2Div").html($('#sumTaxMoney').val());
				}
			}
		});
	}
}

function GetTitle(ord,stype){
	//http://127.0.0.1/money/checktitle.asp?ord=47524&InvoiceType=204
	$('#w').html('<iframe src="CheckTitle.asp?ord='+ord+'&InvoiceType='+stype+'" style="width:100%;height:100%" frameborder="0"></iframe>').window({
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

function getInvoiceRate(invoiceMode,htord,stype,fromType,kpid){
	if (invoiceMode==1){
		if(stype != ""){
			$.ajax({
				url:"paybackInvoice.asp?msgid=getInvoiceRate&htord="+htord+"&typeid="+stype+"&fromType="+fromType+"&kpid="+kpid,
				success:function(r){
					if (r!=""){		
						var arr_res = r.split("|");
						$('#taxRateDiv').html(arr_res[0]);
						$('#taxRateValue').val(arr_res[0]);
						var taxrate = arr_res[0];
						if (taxrate.length == 0) taxrate = 0;
						taxrate = taxrate.replace("%", "");
						var money1 = $("#money1").val();
						if (money1.length == 0) money1 = 0;
						var rateMoney1 = money1 / (1 + taxrate * 0.01);
						var rateMoney2 = money1 - rateMoney1
						$("#rateMoney1Div").html(FormatNumber(rateMoney1, window.sysConfig.moneynumber));
						$("#rateMoney2Div").html(FormatNumber(rateMoney2, window.sysConfig.moneynumber));
					}
				}
			});
		}else{
		        $('#taxRateDiv').html("");
		        $('#taxRateValue').html("");
		        var money1 = $("#money1").val();
		        if (money1.length == 0) money1 = 0;
		        $("#rateMoney1Div").html(FormatNumber(money1, window.sysConfig.moneynumber));
				$("#rateMoney2Div").html("");
		}
	}
}

function __DoFormate(input){
	var v = input.value;
	var v1 = v;
	var Exp = /(^\-?)|\-|[^\d\.]/g;
	var Exp1 = /(\.\d*)(\.)/g;
	v = v.replace(Exp,"$1");//--正则去掉开头之外的“-”
	while (v.match(Exp1))
	{
		v = v.replace(Exp1,"$1");//--正则，反向引用，去除后面的“.”
	}
	if (v != v1)
	{
		input.value = v;
	}
}
