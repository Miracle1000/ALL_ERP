var objCur=null;
function showSubjectDiv(typ,obj){
	objCur = obj;
	var substr = "searchSubject" ; 
	if (typ ==2 ){substr = "searchFlow" ; }
	bill.easyui.CAjaxWindow(substr, function() {
		ajax.addParam("subject", obj.value);
	});
}

function clickSearch(){
	var searchtext = $("#searchtext").val();
	var src = $("#subjectFrame").attr("src").split("&")[0] + "&searchtext="+escape(searchtext);
	$("#subjectFrame").attr("src",src);
}

function clearSearch(){
	if (objCur!=null)
	{
		var id = objCur.id;
		objCur.value = "";
		objCur.parentNode.children[0].value = "0";
		objCur = $ID(id);
	}
}

function checkSubject(typ,ord)
{
	if (objCur!= null)
	{	
		//var tr = $(objCur).parentsUntil(".lvw_cell").parent().parent();
		//var rowIndex = tr[0].rowIndex;

		//var index = $(obj).parentsUntil(".lvw_cell").last().parent().prevAll().first().text();
		//var td = $("td .lvw_index").find("");
		if (typ == 1)//选择会计科目
		{
			objCur.parentNode.children[0].value =  ord;
			//非IE兼容
			if(!window.ActiveXObject){app.lvweditor.__U_C(objCur.parentNode.children[0]);}
			//$(objCur).parent().children[0].val(ord);
			//app.Alert(ord);
		}
		else if (typ==2) //选择现金流量项目
		{
			objCur.parentNode.children[0].value = ord;
			ajax.regEvent("searchFlowSubject")
			ajax.addParam('ord', ord);
			var r = ajax.send();
			objCur.value = r ;
		}
		objCur.style.color="#000";
	}
	objCur = null;
	var substr = "searchSubject" ; 
	if (typ ==2 ){substr = "searchFlow" ; }
	bill.easyui.closeWindow(substr);
}

function bntClick(obj,typ)
{
	if (typ == 4) //草稿箱
	{
		window.location.href="../../finance/voucher/voucherlist.asp?intdel=5";
	}
	else if (typ == 5)
	{	
		var cansave = false; 
		$("input:[name=accountsubject]").each(function()
			{
				if ($(this).val()!="0" && $(this).val()!="")
				{
					cansave = true ;
				};
			}
		)
		if (cansave == true )
		{
			objCur = obj;
			bill.easyui.CAjaxWindow("setTempTitle", function() {
				ajax.addParam("typ", typ);
			});
		}
		else
		{
			app.Alert("请编辑凭证分录信息");
		}
	}
	else if (typ == 6)
	{	
		bill.easyui.CAjaxWindow("getMoban", function() {
			ajax.addParam("typ", typ);
		});
	}
	else
	{
		document.getElementsByName("@typ")[0].value=typ;		
		bill.doSave(obj);
	}
}

function setMoban(moban_ord)
{
	var lvw = new Listview("voucherFLUlist");
    lvw.beginCallBack("getMoban");
	lvw.addParam("moban_ord", moban_ord);	//产品名称
	lvw.exec();
	bill.easyui.closeWindow("getMoban");
}

function saveTemp(typ){
	if ($("#temp_title").val()=="")
	{
		$("#errmsg").html("请输入模板名称");
	}
	else{
		document.getElementsByName("@temp_bh")[0].value=$("#temp_bh").val();
		document.getElementsByName("@temp_title")[0].value=$("#temp_title").val();
		document.getElementsByName("@typ")[0].value=typ;
		bill.doSave(objCur);
	}
}


function setChangeDate(ord)
{
	var date1 = $("#date1_0").val();
	var voucherword = $("#voucherword_0").val();
	//id=bh_cel  编号cell
	ajax.regEvent("doEdit")
	ajax.addParam('ord', ord);
	ajax.addParam('date1', date1);
	ajax.addParam('voucherword', voucherword);
	ajax.send(function(r){
		if (r=="0")
		{		
			app.Alert("当前账套错误,请联系管理员！");
		}
		else {
			var resultArr = r.split("||");
			if (resultArr.length==3)
			{
				if (resultArr[0] == "1")
				{	
					$("#voucherword_0 ").empty();
					var wordArr = resultArr[1].split(",")
					for (var i=0;i<wordArr.length ;i++ )
					{	
						var vtext = returnWordStr(wordArr[i]);
						$("#voucherword_0").append("<option value='"+wordArr[i]+"'>" + vtext +"</option>");  
					}
				}
				$("#bhStr_cel").children("div").html(resultArr[2]);
			}
		}
	});
}

function returnWordStr(words)
{
	var vtext = "";
	switch (words)
	{
	case "1" :
		vtext="记";  
		break;
	case "2" :
		vtext="收";  
		break;
	case "3" :
		vtext="付";  
		break;
	case "4" :
		vtext="转";  
		break;
	case "5" :
		vtext="现金";   
		break;
	case "6" :
		vtext="银行";   
		break;
	case "7" :
		vtext="转账";  
		break;
	case "8" :
		vtext="现收";   
		break;
	case "9" :
		vtext="现付";   
		break;
	case "10" :
		vtext="银收";  
		break;
	case "11" :
		vtext="银付";  
		break;
	case "12" :
		vtext="转账";  
		break;
	}
	return vtext;
}

var isConvert = false ;
function onfocusHandle(obj,typ)
{
	isConvert = true;
	var currRow = app.lvweditor.getCurrHtmlRow(obj);
	if (typ == 1 ) //借方金额
	{
		var td = currRow.cells[5];
		var tbs = td.getElementsByTagName("table");
		var cell = tbs[0].rows[0].cells[0]; 
		var money_d = $(cell).find("input:[type=text]")[0];
		if (money_d!=undefined)
		{
			if (money_d.value.length>0)
			{
				obj.value = money_d.value;
				money_d.value = "";	
				getCellSum(money_d);
				obj.select();
				getCellSum(obj);	
			}
		}	
		
	}
	else if (typ==2)
	{
		var td = currRow.cells[4];
		var tbs = td.getElementsByTagName("table");
		var cell = tbs[0].rows[0].cells[0]; 
		var money_d = $(cell).find("input:[type=text]")[0];
		if (money_d!=undefined)
		{
			if (money_d.value.length>0)
			{
				obj.value = money_d.value;
				money_d.value = "";
				getCellSum(money_d);
				obj.select();
				getCellSum(obj);
			}
		}
		
	}
	isConvert = false;
}

function sethl(obj,typ)
{
	if(isConvert==true) {return ;}
	isConvert = true ;
	var currRow = app.lvweditor.getCurrHtmlRow(obj);
	switch (typ)
	{
	case 1://修该借贷方金额 算汇率
		var td = currRow.cells[7];
		var tbs = td.getElementsByTagName("table");
		var cell = tbs[0].rows[0].cells[0]; 
		var money_d = $(cell).find("input:[type=text]")[0];
		if (money_d!=undefined)
		{
			var money2 = money_d.value
			if (money2.length>0)
			{
				if (parseFloat(money2)!=0)
				{
					var money1 = obj.value ;
					if (money1==""){money1=0;}
					var td1 = currRow.cells[8];
					var tbs1 = td1.getElementsByTagName("table");
					var cell1 = tbs1[0].rows[0].cells[0]; 
					var money_d1 = $(cell1).find("input:[type=text]")[0];
					if (money_d1!=undefined)
					{
						money_d1.value = FormatNumber(parseFloat(money1)/parseFloat(money2),window.sysConfig.hlnumber);
					}
				}	
			}
		}
		getCellSum(obj)
		break;
	case 2: //修改汇率 计算借贷方
		var td = currRow.cells[7];
		var tbs = td.getElementsByTagName("table");
		var cell = tbs[0].rows[0].cells[0]; 
		var money_d = $(cell).find("input:[type=text]")[0];
		if (money_d!=undefined)
		{
			var money2 = money_d.value
			if (money2.length>0)
			{
				if (parseFloat(money2)!=0)
				{
					var money1 = obj.value ;
					if (money1==""){money1=0;}
					var td1 = currRow.cells[4];
					var tbs1 = td1.getElementsByTagName("table");
					var cell1 = tbs1[0].rows[0].cells[0]; 
					var money_d1 = $(cell1).find("input:[type=text]")[0];
					var td2 = currRow.cells[5];
					var tbs2 = td2.getElementsByTagName("table");
					var cell2 = tbs2[0].rows[0].cells[0]; 
					var money_d2 = $(cell2).find("input:[type=text]")[0];
					if (money_d1!=undefined){ //存在 (借方)
						if (money_d2!=undefined) //存在 (贷方)
						{
							if (money_d2.value.length>0)
							{
								money_d2.value = FormatNumber(parseFloat(money1)*parseFloat(money_d.value),window.sysConfig.moneynumber);
								getCellSum(money_d2);
							}
							else
							{
								money_d1.value = FormatNumber(parseFloat(money1)*parseFloat(money_d.value),window.sysConfig.moneynumber);
								getCellSum(money_d1);
							}
						}
						else
						{
							money_d1.value = FormatNumber(parseFloat(money1)*parseFloat(money_d.value),window.sysConfig.moneynumber);
							getCellSum(money_d1);
						}
					}
					else
					{
						if (money_d2!=undefined){
							money_d2.value = FormatNumber(parseFloat(money1)*parseFloat(money_d.value),window.sysConfig.moneynumber);
							getCellSum(money_d2);
						}
					}
				}	
			}
		}	
		break;
	case 3://修该原币金额 算借贷方
		var td = currRow.cells[8];
		var tbs = td.getElementsByTagName("table");
		var cell = tbs[0].rows[0].cells[0]; 
		var money_d = $(cell).find("input:[type=text]")[0];
		if (money_d!=undefined)
		{
			var money2 = money_d.value; //汇率
			if (money2.length>0)
			{
				if (parseFloat(money2)!=0)
				{
					var money1 = obj.value ; //原币种
					if (money1==""){money1=0;}
					var td1 = currRow.cells[4];
					var tbs1 = td1.getElementsByTagName("table");
					var cell1 = tbs1[0].rows[0].cells[0]; 
					var money_d1 = $(cell1).find("input:[type=text]")[0];
					var td2 = currRow.cells[5];
					var tbs2 = td2.getElementsByTagName("table");
					var cell2 = tbs2[0].rows[0].cells[0]; 
					var money_d2 = $(cell2).find("input:[type=text]")[0];
					if (money_d1!=undefined){ //存在 (借方)
						if (money_d2!=undefined) //存在 (贷方)
						{
							if (money_d2.value.length>0)
							{
								money_d2.value = FormatNumber(parseFloat(money1)*parseFloat(money_d.value),window.sysConfig.moneynumber);
								getCellSum(money_d2);
							}
							else
							{
								money_d1.value = FormatNumber(parseFloat(money1)*parseFloat(money_d.value),window.sysConfig.moneynumber);
								getCellSum(money_d1);
							}
						}
						else
						{
							money_d1.value = FormatNumber(parseFloat(money1)*parseFloat(money_d.value),window.sysConfig.moneynumber);
							getCellSum(money_d1);
						}
					}
					else
					{
						if (money_d2!=undefined){
							money_d2.value = FormatNumber(parseFloat(money1)*parseFloat(money_d.value),window.sysConfig.moneynumber);
							getCellSum(money_d2);
						}
					}
				}	
			}
		}	
		break;
	}
	isConvert = false;
}

function getCellSum(obj)
{
	var lvwid = app.lvweditor.getHtmlId(obj);
	var tb = $ID("lvw_dbtable_" + lvwid); //当前table
	var currRow = app.lvweditor.getCurrHtmlRow(obj);
	var currCell = app.lvweditor.getCurrHtmlCell(obj); //当前列
	var cellIndex = 0 ; 
	for (var i = 0; i < currRow.cells.length ; i++)
	{
		if(currRow.cells[i]==currCell) {
			cellIndex = i
		}
	}
	var sum = 0 ; 
	for (var i = 1; i < tb.rows.length; i++)
	{
		var cell = tb.rows[i].cells[cellIndex];
		if (i == tb.rows.length-1)
		{
			 tb.rows[i].cells[cellIndex-3].innerHTML = FormatNumber(sum,window.sysConfig.moneynumber);//window.sysConfig.moneynumber 
		}
		else
		{
			var money_d = $(cell.getElementsByTagName("table")[0].rows[0].cells[0]).find("input:[type=text]")[0];
			if (money_d!=undefined)
			{
				if (money_d.value.length>0){ sum += parseFloat(money_d.value);}
			}	
		}
	}
}


function content_bntClick(md5_ord,typ){
	switch (typ)
	{
	case 1:
		window.open("add.asp?ord=" + md5_ord,"xg","width=" + 1100 + ",height=" + 500 + ",fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=270,top=170");
		break;
	case 2 :
		window.location.href="../../finance/voucher/add.asp?ord="+ md5_ord +"&editOrd=" + md5_ord + " " ;
		break;
	case 4 : 
		window.open('../../Manufacture/inc/printerResolve.asp?formid='+md5_ord+'&sort=150&isSum=0','newwin77','width=' + 850 + ',height=' + (screen.availHeight-80) + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth-850)/2  + ',top=0')
		break;
	case 5 :
		window.location.href="../../finance/voucher/add.asp?copyOrd=" + md5_ord + "&fromType=4" ;
		break;
	case 6 :
		//冲销
		bill.easyui.CAjaxWindow("setcharge", function() {
			ajax.addParam("ord", md5_ord);
		});
		break;
 	case 7 : //导出word
		window.open('../../../SYSN/view/comm/TemplatePreview.ashx?sort=150&type=word&ord='+md5_ord,'newwin77','width=' + 850 + ',height=' + (screen.availHeight-80) + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth-850)/2  + ',top=0')
		break;
	case 8 : //导出Excel
		window.open('../../../SYSN/view/comm/TemplatePreview.ashx?sort=150&type=excel&ord='+md5_ord,'newwin77','width=' + 850 + ',height=' + (screen.availHeight-80) + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth-850)/2  + ',top=0')
		break;
	case 9 : //最新模板打印
		window.open('../../../SYSN/view/comm/TemplatePreview.ashx?sort=150&ord='+md5_ord,'newwin77','width=' + 850 + ',height=' + (screen.availHeight-80) + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth-850)/2  + ',top=0')
		break;
	}
	
}

function setChangeDate_Charge()
{
	var date1 = $("#charge_date1").val();
	var voucherword = $("#charge_word").val();
	//id=bh_cel  编号cell
	ajax.regEvent("doEdit")
	ajax.addParam('date1', date1);
	ajax.addParam('voucherword', voucherword);
	ajax.send(function(r){
		if (r=="0")
		{		
			app.Alert("当前账套错误,请联系管理员！");
		}
		else {
			var resultArr = r.split("||");
			if (resultArr.length==3)
			{
				if (resultArr[0] == "1")
				{	
					$("#charge_word").empty();
					var wordArr = resultArr[1].split(",")
					for (var i=0;i<wordArr.length ;i++ )
					{	
						var vtext = returnWordStr(wordArr[i]);
						$("#charge_word").append("<option value='"+wordArr[i]+"'>" + vtext +"</option>");  
					}
				}
				$("#charge_bh").html(resultArr[2]);
			}
		}
	});
}

//冲销
function setCharge(ord)
{
	var date1 = $("#charge_date1").val();
	if (date1.length==0)
	{
		$("#errmsg").html("请输入凭证日期");
		return;
	}
	var voucherword = $("#charge_word").val();
	ajax.regEvent("setcharge")
	ajax.addParam('ord', ord);
	ajax.addParam('voucherword', voucherword);
	ajax.addParam('date1', date1);
	ajax.send(function(r){
		 if (r == "1") {
			window.location.reload();
			if (window.opener)
			{
				window.opener.location.reload();
			}
		 }
		 else
		 {
			if (r=="0")
			{		
				app.Alert("冲销失败！");
			}
			else
			{
				app.Alert(r);
			}
		 }
	});
}

function OperateClick(typ,ord)
{
	var status = "审核";
	switch (typ)
	{
	case 2 : 
		status = "反审核" 
		break;
	case 3 :
		status = "记账" 
		break;
	case 4 :
		status = "反记账" 
		break;
	}
	var ordlist="";
	if (ord==0)
	{
		$(".lvcbox").each(
			function(){
				if($(this).attr("checked")==true)
				{
					if (ordlist.length!="")
					{
						ordlist = ordlist + ",";
					}
					ordlist = ordlist + $(this).val();
				}
			}
		)
		if (ordlist.length=="")
		{
			app.Alert("您没有选择任何凭证,请选择后再"+status+"！");
			return ;
		}
	}
	else 
	{
		ordlist = ord;
	}

	if(confirm('确认'+status+'？')){
		ajax.regEvent("doSet")
		ajax.addParam('ordlist', ordlist);
		ajax.addParam('typ', typ);
		ajax.send(function(r){
			 if (r == "1") {
				window.location.reload();
				if (window.opener)
				{
					window.opener.location.reload();
				}
			 }
			 else
			 {
				if (r=="0")
				{		
					app.Alert("没有选择可"+status+"的凭证,请重新选择后再"+status+"！");
				}
				else
				{
					app.Alert(r);
				}
			 }
		});
	}
}

window.onListViewRowUpdate = function(lvwid) {
	ajax.addParam("voucherDate", $("#date1_0").val());
}