window.onReportRefresh=function(){
	var strh=$ID("commfieldsBox").getAttribute("connHTML");
	if (strh!=null && strh!="")
	{
		$("#searchitemsbutton2").click();
	}
}

function selectall(obj)
{
	$(".lvcbox").attr("checked",obj.checked);
}
//ord: 单据ordlist, module: 数据类型  1 现金银行 2 开票 3 工资 4 费用   typ: 工资类型 1 财务工资 2 人资工资
function OperateAdd(ord,module , typ) {
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
			app.Alert("您没有选择任何业务数据,请选择后再生成！");
			return ;
		}
	}
	else 
	{
		ordlist = ord;
	}
	if(confirm('确认生成？')){
		setVoucherDate(module,typ,ordlist,"")
		//autoCreateVoucher(module,typ,ordlist,"")
	}
}
// module: 数据类型  1 现金银行 2 开票 3 工资 4 费用   typ: 工资类型 1 财务工资 2 人资工资
function OperateAll(module, typ)
{
	//获取页面SQL参数传递
	var mainsql = $("#mainSql").val();
	if(confirm('确认全部生成？')){
		//autoCreateVoucher(module,typ,"",mainsql)
		setVoucherDate(module,typ,"",mainsql)
	}
}

function setVoucherDate(module,typ,ordlist,mainsql){
	var win = bill.easyui.createWindow("setVoucherDate", "选择凭证日期", {width:300, height:180} );
	var strHtml
	strHtml = "<table id='content' style='height:100%;'>";
	strHtml = strHtml + "<tr height='30'><td  style='background:#ffffff;'><input type='radio' name='datetyp' id='datetyp1' checked><label for='datetyp1'>自动，默认业务单据日期</label></td></tr>";
	strHtml = strHtml + "<tr height='30'><td><input type='radio' name='datetyp' id='datetyp2'><label for='datetyp2'>手动</label> &nbsp;<input type='text' id='date1' onmousedown='datedlg.show()' readonly size='13' maxlength=10 value=''>&nbsp;<span id='showspan' class='red'></span></td></tr>" ; 
	strHtml = strHtml + "<tr height='30'><td align='center'><input type='button' class='oldbutton' value='生成' onclick=\"autoCreateVoucher(" + module + "," + typ + ", '" + ordlist + "', '"+ mainsql + "')\">&nbsp;&nbsp;<input type='button' class='oldbutton' value='取消' onclick=\"bill.easyui.closeWindow('setVoucherDate');\"></td></tr>" ; 
	strHtml = strHtml + "</table>" ; 
	win.innerHTML =strHtml;
}

function autoCreateVoucher(module,typ,ordlist,mainsql)
{
	var date1 = "";
	if ($("#datetyp2").attr("checked")==true)
	{
		date1 = $("#date1").val();
		if (date1.length==0)
		{	
			$("#showspan").html("请手动选择凭证日期");
			return false ;
		}
	}
	bill.easyui.closeWindow('setVoucherDate');
	var win = bill.easyui.createWindow("autoAddVoucher", "自动生成凭证报告", {width:600, height:400} );
	ajax.regEvent("autoAddVoucher")
	ajax.addParam('module', module);
	ajax.addParam('typ', typ);
	ajax.addParam('ordlist', ordlist);
	ajax.addParam('mainsql', mainsql);
	ajax.addParam('date1', date1);
	win.innerHTML  = ajax.send();
	lvw_refresh('mlistvw');
}